from django.contrib import admin
from django.urls import path, include

from rest_framework import routers, serializers, viewsets

from stellarbot.views import (AppHealthCheckView,
                              CeleryHealthCheckView,
                              DatabaseHealthCheckView,
                              DataLoadedCheckView,
                              LedgersView)

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)


urlpatterns = [
    path('admin/', admin.site.urls),

    path('api/token', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh', TokenRefreshView.as_view(), name='token_refresh'),
    # path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),

    # path('data/', include(router.urls)),

    path('data/ledgers', LedgersView.as_view()),

    path('health/app/', AppHealthCheckView.as_view()),
    path('health/celery/', CeleryHealthCheckView.as_view()),
    path('health/database/', DatabaseHealthCheckView.as_view()),
    path('health/data/', DataLoadedCheckView.as_view()),
]
