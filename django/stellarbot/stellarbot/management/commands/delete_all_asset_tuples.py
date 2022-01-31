import os
from django.core.management import BaseCommand

from stellarbot.models import AssetTuple, Accumlation


class Command(BaseCommand):

    def handle(self, *args, **options):

        Accumlation.objects.all().delete()
        AssetTuple.objects.all().delete()
