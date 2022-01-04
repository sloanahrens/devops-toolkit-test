import json
from datetime import datetime

from django.db.utils import ProgrammingError
from django.utils.timezone import now
from django.conf import settings
from django.db.models import Q

from celery.exceptions import TimeoutError

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.permissions import AllowAny

from api.tasks import celery_worker_health_check
from api.models import Ledger, WorkerLogLine, AssetPair, Asset


class LedgersView(APIView):

    def get(self, request, *args, **kwargs):

        whitelisted_assets = list(
            Asset.objects.filter(whitelisted=True).order_by('asset_code')[:settings.OBJECTS_RETURN_LIMIT])

        whitelisted_asset_pairs = list(
            AssetPair.objects.filter(paths_exist=True).order_by('-last_updated')[:settings.OBJECTS_RETURN_LIMIT])

        positive_cycle_asset_pairs = sorted(list(AssetPair.objects.filter(
                                                base_price_xlm_error__gt=settings.XLM_VAL_ERROR_THRESHOLD,
                                                paths_exist=True
                                            )), 
                                            key=lambda x : x.base_price_xlm_error,
                                            reverse=True
                                        )
        logs = list(
            WorkerLogLine.objects.all().order_by('-timestamp')[:settings.OBJECTS_RETURN_LIMIT])

        return Response({

            'positive_cycle_asset_pairs': [ap.pair_desc_list for ap in positive_cycle_asset_pairs],
            'wl_asset_pairs': [ap.pair_desc_list for ap in whitelisted_asset_pairs],
            'wl_assets': [a.asset_desc for a in whitelisted_assets],

            'positive_cycle_asset_pairs_count': len(positive_cycle_asset_pairs),
            'wl_asset_pairs_count': len(whitelisted_asset_pairs),
            'wl_assets_count': len(whitelisted_assets),

            'logs': [l.entry for l in logs],
            'latest_log': max(l.timestamp for l in logs),

            'timestamp': str(datetime.utcnow())
        })


class AppHealthCheckView(APIView):

    def get(self, request, *args, **kwargs):
        return Response({'status': 'healthy'})


def postgres_error_response(err):
    return Response(data={'status': 'unhealthy',
                          'reason': 'database query failed (ProgrammingError)',
                          'exception': str(err)},
                    status=HTTP_412_PRECONDITION_FAILED)


class DatabaseHealthCheckView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            return Response({'status': 'healthy',
                             'ledger_count': Ledger.objects.count()})
        except ProgrammingError as e:
            return postgres_error_response(e)


class CeleryHealthCheckView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        current_datetime = now().strftime('%c')
        try:
            # trigger a health check job (run db query from the worker).
            task = celery_worker_health_check.delay(current_datetime)
            result = task.get(timeout=6)
        except TimeoutError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'celery job failed (TimeoutError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        try:
            assert result == current_datetime
        except AssertionError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'celery job failed (AssertionError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        return Response({'status': 'healthy'})

class DataLoadedCheckView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        try:
            # TODO: do something more interesting here
            # # run a DB query (from the app node)
            # if Ledger.objects.count() > 0:
            return Response({'status': 'healthy',
                             'ledger_count': Ledger.objects.count()})
            # else: 
            #     return Response(
            #         data={'status': 'unhealthy',
            #               'reason': 'no data loaded'},
            #         status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            return postgres_error_response(e)
