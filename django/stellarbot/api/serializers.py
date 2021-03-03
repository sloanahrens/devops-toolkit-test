from rest_framework import serializers

from api.models import Ledger

class LedgerSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = Ledger

        fields = [
          'id',
          'timestamp',
          'raw_json',
        ]