import json

from django.core.management import BaseCommand
from stellar_sdk import Server

from api.models import Ledger


class Command(BaseCommand):

    def handle(self, *args, **options):

        server = Server(horizon_url="https://horizon-testnet.stellar.org")
        ledgers = server.ledgers().order(desc=True).call()

        Ledger.objects.all().delete()
        Ledger(raw_json=json.dumps(ledgers)).save()

