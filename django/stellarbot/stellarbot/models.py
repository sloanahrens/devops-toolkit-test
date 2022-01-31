import json

from django.db import models
from django.conf import settings
from django.utils.safestring import mark_safe

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

    def fmt_num(self, num, precision=6):
        format_str = '{:,.' + str(precision) + 'f}'
        return format_str.format(round(num, precision))


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
    def name(self):
        return self.asset_code

    @property
    def asset_desc(self):
        return ''.join([
            f'{self.asset_code} ->',
            f'  P:{self.price}  V:{self.volume}',
            f'  A: {self.amount}  N:{self.num_accounts}'
        ])


class AssetTuple(BoilerPlate):

    description = models.TextField(null=False, blank=False, default='')

    asset_set = models.ManyToManyField(Asset)

    bridge_asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='bridge_asset_set')

    left_buy_amount = models.FloatField(default=0.0, null=False, blank=False) 
    right_spend_amount = models.FloatField(default=0.0, null=False, blank=False)

    price_diff = models.FloatField(default=0.0, null=False, blank=False)
    rel_error = models.FloatField(default=0.0, null=False, blank=False)
    diff_in_xlm = models.FloatField(default=0.0, null=False, blank=False)

    left_tx_string = models.TextField(null=False, blank=False, default='{}')
    right_tx_string = models.TextField(null=False, blank=False, default='{}')

    @property
    def desc_list(self):
        return [
            f'diff_in_xlm: {self.fmt_num(self.diff_in_xlm, precision=16)} XLM',
            f'left_buy_amount: {self.fmt_num(self.left_buy_amount, precision=4)} {self.bridge_asset.asset_code}',
            f'right_spend_amount: {self.fmt_num(self.right_spend_amount, precision=4)} {self.bridge_asset.asset_code}',
            f'price_diff: {self.fmt_num(self.price_diff)} {self.bridge_asset.asset_code} (rel_error: {self.fmt_num(100 * self.rel_error, precision=2)}%)',
            f'left_txs: {self.left_tx_string}',
            f'right_txs: {self.right_tx_string}',
            f'timestamp: {self.timestamp}',
            f'admin_href: /admin/api/assettuple/{self.pk}/change/'
        ]

    def __str__(self):
        return f'{self.pk}'

    @property
    def name(self):
        return f'{self.pk}'


class Accumlation(BoilerPlate):

    asset_tuple = models.ForeignKey(AssetTuple, on_delete=models.CASCADE)
    amount = models.FloatField(default=0.0, null=False, blank=False)
    amount_in_xlm = models.FloatField(default=0.0, null=False, blank=False)

    @property
    def asset(self):
        return self.asset_tuple.bridge_asset

    @property
    def asset_name(self):
        return self.asset.asset_code

    @property
    def desc(self):
        return [f'{self.amount_in_xlm} XLM ({self.amount} {self.asset_name})',
                f'timestamp: {self.timestamp}',
                f'at_admin_href: /admin/api/assettuple/{self.asset_tuple.pk}/change/']
    @property
    def name(self):
        return f'{self.pk}'

class ErrorLog(BoilerPlate):

    @property
    def name(self):
        return f'{self.pk}'


class WorkerLogLine(models.Model):

    timestamp = models.DateTimeField(auto_now=True, db_index=True)
    entry = models.TextField(null=False, blank=False)
    
    def __str__(self):
        return f'{self.timestamp} {self.entry}'

    @property
    def name(self):
        return f'{self.pk}'

