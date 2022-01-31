from django.contrib import admin

from stellarbot.models import Asset, AssetTuple, Accumlation, WorkerLogLine, ErrorLog


class ErrorLogAdmin(admin.ModelAdmin):

    model = ErrorLog

    fields = [
          'id',
          'timestamp',
          'raw_json'
      ]

    list_display = [
          'id',
          'timestamp'
        ]

    readonly_fields = [
          'id',
          'timestamp',
          'raw_json'
      ]

    ordering = ['-timestamp',]

    list_filter = ['timestamp',]

admin.site.register(ErrorLog, ErrorLogAdmin)


class AssetTupleAdmin(admin.ModelAdmin):

    model = AssetTuple

    fields = [
          'timestamp',
          'asset_set',
          'bridge_asset',
          'left_tx_string',
          'right_tx_string',
          'diff_in_xlm',
          'price_diff',
          'rel_error',
          'id',
          'raw_json'
      ]

    list_display = [
          'bridge_asset',
          'diff_in_xlm',
          'price_diff',
          'rel_error',
          'id',
          'timestamp'
        ]

    readonly_fields = [
          'timestamp',
          'asset_set',
          'bridge_asset',
          'left_tx_string',
          'right_tx_string',
          'diff_in_xlm',
          'price_diff',
          'rel_error',
          'id',
          'raw_json'
      ]

    ordering = [
      '-diff_in_xlm'
      ]

    list_filter = (
          'timestamp',
          'bridge_asset'
        )
admin.site.register(AssetTuple, AssetTupleAdmin)


class WorkerLogLineAdmin(admin.ModelAdmin):

  model = WorkerLogLine

  list_display = ['timestamp', 'entry']

  readonly_fields = ['timestamp', 'entry']

  ordering = ['-timestamp']

  list_filter = ['timestamp']

admin.site.register(WorkerLogLine, WorkerLogLineAdmin)


class AssetAdmin(admin.ModelAdmin):

    model = Asset

    list_display = [
          'asset_code',
          'whitelisted',
          'id',
          'asset_issuer',
          'asset_type',
          'amount',
          'num_accounts',
          'trade_count',
          'volume',
          'price',
          'timestamp',
          'last_updated'
        ]

    readonly_fields = [
          'asset_code',
          'whitelisted',
          'id',
          'timestamp',
          'asset_issuer',
          'asset_type',
          'amount',
          'num_accounts',
          'trade_count',
          'volume',
          'price',
          'raw_json'
    ]

    ordering = ['-last_updated']

admin.site.register(Asset, AssetAdmin)
