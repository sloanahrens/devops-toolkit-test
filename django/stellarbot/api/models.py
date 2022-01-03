from django.db import models

from datetime import datetime


class BoilerPlate(models.Model):

    timestamp = models.DateTimeField(auto_now=True, db_index=True)
    last_updated = models.DateTimeField(auto_now=True, db_index=True)
    raw_json = models.TextField(null=False, blank=False, default='{}')

    @property
    def name(self):
        return '_'
    
    def __str__(self):
        return f'{self.__class__.__name__}_{self.name}_{self.timestamp}'

    def save(self, *args, **kwargs):
        last_updated = datetime.utcnow()
        super(BoilerPlate, self).save(*args, **kwargs)


class Ledger(BoilerPlate):

    pass


class Asset(BoilerPlate):

    asset_code = models.TextField(null=False, blank=False)
    asset_issuer = models.TextField(null=False, blank=False)
    asset_type = models.TextField(null=False, blank=False)

    amount = models.FloatField(default=0.0, null=False, blank=False)
    num_accounts = models.IntegerField(default=0, null=False, blank=False)

    trade_count = models.IntegerField(default=0, null=False, blank=False)
    volume = models.FloatField(default=0.0, null=False, blank=False)
    price = models.FloatField(default=0.0, null=False, blank=False)

    whitelisted = models.BooleanField(default=False, null=False, blank=False)

    def __str__(self):
        return f'{self.asset_code}'

    @property
    def asset_desc(self):
        return ''.join([
            f'{self.asset_code} ->',
            f'  P:{self.price}  V:{self.volume}',
            f'  A: {self.amount}  N:{self.num_accounts}'
        ])


class AssetPair(BoilerPlate):

    base_asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='base_asset_pairs')
    counter_asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='counter_asset_pairs')

    forward_trade_count = models.IntegerField(default=0, null=False, blank=False)
    forward_base_volume = models.FloatField(default=0.0, null=False, blank=False)
    forward_counter_volume = models.FloatField(default=0.0, null=False, blank=False)
    forward_avg = models.FloatField(default=0.0, null=False, blank=False)
    forward_high = models.FloatField(default=0.0, null=False, blank=False)
    forward_low = models.FloatField(default=0.0, null=False, blank=False)
    forward_open = models.FloatField(default=0.0, null=False, blank=False)
    forward_close = models.FloatField(default=0.0, null=False, blank=False)

    backward_trade_count = models.IntegerField(default=0, null=False, blank=False)
    backward_base_volume = models.FloatField(default=0.0, null=False, blank=False)
    backward_counter_volume = models.FloatField(default=0.0, null=False, blank=False)
    backward_avg = models.FloatField(default=0.0, null=False, blank=False)
    backward_high = models.FloatField(default=0.0, null=False, blank=False)
    backward_low = models.FloatField(default=0.0, null=False, blank=False)
    backward_open = models.FloatField(default=0.0, null=False, blank=False)
    backward_close = models.FloatField(default=0.0, null=False, blank=False)

    whitelisted = models.BooleanField(default=False, null=False, blank=False)

    recent_direct_market = models.BooleanField(default=False, null=False, blank=False)
    direct_market_error = models.FloatField(default=0.0, null=False, blank=False)

    # strict-receive, base-to-counter
    srbc_raw_json = models.TextField(null=False, blank=False, default='{}')
    srbc_path_count = models.IntegerField(default=0, null=False, blank=False)
    srbc_min_base_spend = models.FloatField(default=0.0, null=False, blank=False)

    # strict-send, counter-to-base
    sscb_raw_json = models.TextField(null=False, blank=False, default='{}')
    sscb_path_count = models.IntegerField(default=0, null=False, blank=False)
    sscb_max_base_buy = models.FloatField(default=0.0, null=False, blank=False)

    # strict-receive, counter-to-base
    srcb_raw_json = models.TextField(null=False, blank=False, default='{}')
    srcb_path_count = models.IntegerField(default=0, null=False, blank=False)
    srcb_min_counter_spend = models.FloatField(default=0.0, null=False, blank=False)

    # strict-send, base-to-counter
    ssbc_raw_json = models.TextField(null=False, blank=False, default='{}')
    ssbc_path_count = models.IntegerField(default=0, null=False, blank=False)
    ssbc_max_counter_buy = models.FloatField(default=0.0, null=False, blank=False)

    inverse_min_base_spend = models.FloatField(default=0.0, null=False, blank=False)
    inverse_max_base_buy = models.FloatField(default=0.0, null=False, blank=False)
    inverse_min_counter_spend = models.FloatField(default=0.0, null=False, blank=False)
    inverse_max_counter_buy = models.FloatField(default=0.0, null=False, blank=False)

    base_price_abs_error = models.FloatField(default=0.0, null=False, blank=False)
    base_price_rel_error = models.FloatField(default=0.0, null=False, blank=False)
    base_price_xlm_error = models.FloatField(default=0.0, null=False, blank=False)

    counter_price_abs_error = models.FloatField(default=0.0, null=False, blank=False)
    counter_price_rel_error = models.FloatField(default=0.0, null=False, blank=False)
    counter_price_xlm_error = models.FloatField(default=0.0, null=False, blank=False)

    def __str__(self):
        return f'{self.base_asset.asset_code}-{self.counter_asset.asset_code}'

    @property
    def srbc_min_base_spend_desc(self):
        return f'{round(self.srbc_min_base_spend, 6)} {self.base_asset.asset_code} -> 1 {self.counter_asset.asset_code}'

    @property
    def sscb_max_base_buy_desc(self):
        return f'1 {self.counter_asset.asset_code} -> {round(self.sscb_max_base_buy, 6)} {self.base_asset.asset_code}'

    @property
    def srcb_min_counter_spend_desc(self):
        return f'{round(self.srcb_min_counter_spend, 6)} {self.counter_asset.asset_code} -> 1 {self.base_asset.asset_code}'

    @property
    def ssbc_max_counter_buy_desc(self):
        return f'1 {self.base_asset.asset_code} -> {round(self.ssbc_max_counter_buy, 6)} {self.counter_asset.asset_code}'

    @property
    def pair_desc_list(self):
        return [
            f'1 XLM -> {self.counter_asset.price} {self.counter_asset.asset_code} -> {self.base_asset.price} {self.base_asset.asset_code}',
            '-----',
            f'{self.sscb_max_base_buy_desc} (strict_send, {self.sscb_path_count} paths)',
            f'{self.srbc_min_base_spend_desc} (strict_receive, {self.srbc_path_count} paths)',
            ''.join([
                f"{'GAIN' if self.base_price_abs_error > 0 else 'LOSS'}: ",
                f"{round(self.base_price_abs_error, 6)} {self.base_asset.asset_code} ",
                f"({round(100 * self.base_price_rel_error)}%): ",
                f"{round(self.base_price_xlm_error, 8)} XLM"]),
            '-----',
            f'{self.ssbc_max_counter_buy_desc} (strict_send, {self.ssbc_path_count} paths)' ,
            f'{self.srcb_min_counter_spend_desc} (strict_receive, {self.srcb_path_count} paths)',
            ''.join([
                f"{'GAIN' if self.counter_price_abs_error > 0 else 'LOSS'}: ",
                f"{round(self.counter_price_abs_error, 6)} {self.counter_asset.asset_code} ",
                f"({round(100 * self.counter_price_rel_error)}%): ",
                f"{round(self.counter_price_xlm_error, 8)} XLM"]),
        ]


class WorkerLogLine(models.Model):

    timestamp = models.DateTimeField(auto_now=True, db_index=True)
    entry = models.TextField(null=False, blank=False)
    
    def __str__(self):
        return f'{self.timestamp} {self.entry}'

