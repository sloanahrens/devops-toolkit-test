import json

from django.db.utils import ProgrammingError
from django.utils.timezone import now
from django.conf import settings

from celery.exceptions import TimeoutError

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import AllowAny

from api.tasks import celery_worker_health_check
from api.models import Ledger


class LedgersView(APIView):

    def get(self, request, *args, **kwargs):
        ledger = Ledger.objects.first()
        return Response({'data': json.loads(ledger.raw_json if ledger else '{}'), 
                         'timestamp': str(ledger.timestamp if ledger else '')})


class AppHealthCheckView(APIView):

    def get(self, request, *args, **kwargs):
        return Response({'status': 'healthy'})


def postgres_error_response(err):
    return Response(data={'status': 'unhealthy',
                          'reason': 'database query failed (ProgrammingError)',
                          'exception': str(err)},
                    status=HTTP_412_PRECONDITION_FAILED)


class DatabaseHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            return Response({'status': 'healthy',
                             'ledger_count': Ledger.objects.count()})
        except ProgrammingError as e:
            return postgres_error_response(e)


class CeleryHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

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
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            if Ledger.objects.count() > 0:
                return Response({'status': 'healthy',
                                 'ledger_count': Ledger.objects.count()})
            else: 
                return Response(
                    data={'status': 'unhealthy',
                          'reason': 'no data loaded'},
                    status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            return postgres_error_response(e)
