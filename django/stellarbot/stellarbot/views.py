import json
from datetime import datetime

from django.db.utils import ProgrammingError
from django.utils.timezone import now
from django.conf import settings
from django.db.models import Q
from django.conf import settings
from django.contrib.auth.models import User

from celery.exceptions import TimeoutError

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

from stellarbot.tasks import celery_worker_health_check
from stellarbot.models import Asset, AssetTuple, Accumlation, WorkerLogLine, ErrorLog


class LedgersView(APIView):

    def get(self, request, *args, **kwargs):

        whitelisted_assets = Asset.objects.filter(whitelisted=True).order_by('asset_code')

        asset_tuples_query = AssetTuple.objects.order_by('-diff_in_xlm')

        asset_tuples_list = [t.desc_list for t in asset_tuples_query[:settings.OBJECTS_RETURN_LIMIT]]

        accumlations = Accumlation.objects.order_by('-amount_in_xlm')

        logs = WorkerLogLine.objects.all().order_by('-timestamp')[:settings.LOGS_RETURN_LIMIT]

        error_count = ErrorLog.objects.all().count()

        return Response({
            'accumlations': [t.desc for t in accumlations[:settings.OBJECTS_RETURN_LIMIT]],
            'accumlations_count': accumlations.count(),
            'accumlations_sum': sum([a.amount_in_xlm for a in accumlations]),

            'asset_tuples': asset_tuples_list,
            'asset_tuples_total_count': asset_tuples_query.count(),
            'asset_tuples_returned': len(asset_tuples_list),

            'wl_assets_count': len(whitelisted_assets),
            'wl_assets': [a.asset_desc for a in whitelisted_assets[:settings.OBJECTS_RETURN_LIMIT]],

            'logs': [l.entry for l in logs],
            'latest_log': max(l.timestamp for l in logs) if len(logs) > 0 else 'no logs found',

            'target_tx_in_xlm': settings.TARGET_TX_AMT_IN_XLM,

            'error_count': error_count,

            'n': settings.NUM_ASSETS_IN_TUPLE,

            'timestamp': str(datetime.utcnow())[:-7]
        })


class AppHealthCheckView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        return Response({'status': 'healthy'})


class DatabaseHealthCheckView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            return Response({'status': 'healthy',
                             'worker_log_count': WorkerLogLine.objects.count()})
        except ProgrammingError as e:
            return Response(data={'status': 'unhealthy',
                                  'reason': 'database query failed (ProgrammingError)'},
                            status=HTTP_412_PRECONDITION_FAILED)


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
            return Response(data={'status': 'unhealthy',
                                  'reason': 'celery job failed (AssertionError)'},
                            status=HTTP_412_PRECONDITION_FAILED)
        return Response({'status': 'healthy'})

class DataLoadedCheckView(APIView):
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            if User.objects.count() > 0:
                return Response({'status': 'healthy'})
            else: 
                return Response(
                    data={'status': 'unhealthy',
                          'reason': 'no data loaded'},
                    status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            return Response(data={'status': 'unhealthy',
                                  'reason': 'database query failed (ProgrammingError)'},
                            status=HTTP_412_PRECONDITION_FAILED)
