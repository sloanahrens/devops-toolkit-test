from django.contrib import admin
from django.urls import path, include

from rest_framework import routers, serializers, viewsets

from stellarbot.views import (AppHealthCheckView,
                              CeleryHealthCheckView,
                              DatabaseHealthCheckView,
                              DataLoadedCheckView,
                              LedgersView)

# from api.models import Ledger
# from api.serializers import LedgerSerializer


# class LedgerViewSet(viewsets.ModelViewSet):
#     queryset = Ledger.objects.all()
#     serializer_class = LedgerSerializer


# router = routers.DefaultRouter()
# router.register(r'ledgers', LedgerViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),

    # path('data/', include(router.urls)),

    path('data/ledgers/', LedgersView.as_view()),

    path('health/app/', AppHealthCheckView.as_view()),
    path('health/celery/', CeleryHealthCheckView.as_view()),
    path('health/database/', DatabaseHealthCheckView.as_view()),
    path('health/data/', DataLoadedCheckView.as_view()),
]
