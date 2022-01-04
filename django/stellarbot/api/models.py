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

    trade_count = models.IntegerField(default=0, null=False, blank=False)
    base_volume = models.FloatField(default=0.0, null=False, blank=False)
    counter_volume = models.FloatField(default=0.0, null=False, blank=False)
    avg = models.FloatField(default=0.0, null=False, blank=False)
    high = models.FloatField(default=0.0, null=False, blank=False)
    low = models.FloatField(default=0.0, null=False, blank=False)
    open = models.FloatField(default=0.0, null=False, blank=False)
    close = models.FloatField(default=0.0, null=False, blank=False)

    recent_direct_market = models.BooleanField(default=False, null=False, blank=False)

    paths_exist = models.BooleanField(default=False, null=False, blank=False)

    # strict-receive paths, base-to-counter
    srbc_raw_json = models.TextField(null=False, blank=False, default='{}')
    srbc_path_count = models.IntegerField(default=0, null=False, blank=False)
    srbc_min_base_spend = models.FloatField(default=0.0, null=False, blank=False)

    # strict-send paths, counter-to-base
    sscb_raw_json = models.TextField(null=False, blank=False, default='{}')
    sscb_path_count = models.IntegerField(default=0, null=False, blank=False)
    sscb_max_base_buy = models.FloatField(default=0.0, null=False, blank=False)

    counter_asset_tx_amt = models.FloatField(default=1.0, null=False, blank=False)

    base_price_abs_error = models.FloatField(default=0.0, null=False, blank=False)
    base_price_rel_error = models.FloatField(default=0.0, null=False, blank=False)
    base_price_xlm_error = models.FloatField(default=0.0, null=False, blank=False)

    def __str__(self):
        return f'{self.base_asset.asset_code}-{self.counter_asset.asset_code}'

    # strict-receive, base-to-counter
    @property
    def srbc_min_base_spend_desc(self):
        return f'{round(self.srbc_min_base_spend, 6)} {self.base_asset.asset_code} -> {self.counter_asset_tx_amt} {self.counter_asset.asset_code}'

    # strict-send, counter-to-base
    @property
    def sscb_max_base_buy_desc(self):
        return f'{self.counter_asset_tx_amt} {self.counter_asset.asset_code} -> {round(self.sscb_max_base_buy, 6)} {self.base_asset.asset_code}'

    @property
    def pair_desc_list(self):
        return [
            f'1 XLM -> {self.counter_asset.price} {self.counter_asset.asset_code} -> {self.base_asset.price} {self.base_asset.asset_code}',
            '-----',
            f'{self.srbc_min_base_spend_desc} (strict_receive, {self.srbc_path_count} paths)',
            f'{self.sscb_max_base_buy_desc} (strict_send, {self.sscb_path_count} paths)',
            '-----',
            ''.join([
                f"{'GAIN' if self.base_price_abs_error > 0 else 'LOSS'}: ",
                f"{round(self.base_price_abs_error, 6)} {self.base_asset.asset_code} ",
                f"({round(100 * self.base_price_rel_error)}%): ",
                f"{round(self.base_price_xlm_error, 8)} XLM"]),
        ]


class WorkerLogLine(models.Model):

    timestamp = models.DateTimeField(auto_now=True, db_index=True)
    entry = models.TextField(null=False, blank=False)
    
    def __str__(self):
        return f'{self.timestamp} {self.entry}'

