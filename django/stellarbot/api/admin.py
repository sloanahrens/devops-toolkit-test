from django.contrib import admin

from api.models import Ledger

class LedgerAdmin(admin.ModelAdmin):

    model = Ledger

    fields = [
          'id',
          'timestamp',
          'raw_json',
        ]

    list_display = [
          'id',
          'timestamp',
          'raw_json',
        ]

admin.site.register(Ledger, LedgerAdmin)
