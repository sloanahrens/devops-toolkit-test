from django.contrib import admin

from api.models import Ledger, Asset, AssetPair, WorkerLogLine


# class LedgerAdmin(admin.ModelAdmin):

#     model = Ledger

#     fields = ['raw_json']

#     list_display = [
#           'id',
#           'timestamp'
#         ]

# admin.site.register(Ledger, LedgerAdmin)

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


class AssetPairAdmin(admin.ModelAdmin):

    model = AssetPair

    list_display = [
          '__str__',
          'id',
          'whitelisted',
          'counter_price_xlm_error',
          # 'counter_price_abs_error',
          # 'counter_price_rel_error',
          # 'base_price_xlm_error',
          # 'base_price_abs_error',
          # 'base_price_rel_error',
          # 'base_asset',
          # 'counter_asset',
          'srbc_path_count',
          'srbc_min_base_spend',
          'sscb_path_count',
          'sscb_max_base_buy',
          'srcb_path_count',
          'srcb_min_counter_spend',
          'ssbc_path_count',
          'ssbc_max_counter_buy',
          # 'inverse_min_base_spend',
          # 'inverse_max_counter_buy',
          # 'inverse_min_counter_spend',
          # 'inverse_max_base_buy',
          'recent_direct_market',
          # 'direct_market_error',
          # 'forward_close',
          # 'backward_close',
          'timestamp',
        ]

    # def srbc_desc(self, instance):
    #   return f'min_base_spend (sr, bc, pc)'


    readonly_fields = [
          'timestamp',
          'whitelisted',
          'raw_json',
          'base_asset',
          'counter_asset',
          'recent_direct_market',
          # 'inverse_max_base_buy',
          # 'inverse_min_base_spend',
          # 'inverse_min_counter_spend',
          # 'inverse_max_counter_buy',
          'srbc_raw_json',
          'srbc_path_count',
          'srbc_min_base_spend',
          'sscb_raw_json',
          'sscb_path_count',
          'sscb_max_base_buy',
          'srcb_raw_json',
          'srcb_path_count',
          'srcb_min_counter_spend',
          'ssbc_raw_json',
          'ssbc_path_count',
          'ssbc_max_counter_buy',
          'srbc_min_base_spend_desc',
          'sscb_max_base_buy_desc',
          'base_price_abs_error',
          'base_price_rel_error',
          'srcb_min_counter_spend_desc',
          'ssbc_max_counter_buy_desc',
          'counter_price_abs_error',
          'counter_price_rel_error',
          'counter_price_xlm_error',
          'base_price_xlm_error',
        ]

    ordering = (
          '-counter_price_xlm_error',
          '-base_price_xlm_error',
          '-last_updated',
          '-timestamp',
          'whitelisted',
          'base_asset',
          'counter_asset',
          'counter_price_rel_error', 
          'base_price_rel_error',
          'srbc_path_count',
          'srbc_min_base_spend',
          'sscb_path_count',
          'sscb_max_base_buy',
          'srcb_path_count',
          'srcb_min_counter_spend',
          'ssbc_path_count',
          'ssbc_max_counter_buy'
        )

    list_filter = (
          'timestamp',
          'whitelisted',
          'counter_price_xlm_error',
          'base_price_xlm_error',
          'srbc_path_count',
          'sscb_path_count',
          'srcb_path_count',
          'ssbc_path_count',
          'base_asset',
          'counter_asset'
        )

admin.site.register(AssetPair, AssetPairAdmin)


