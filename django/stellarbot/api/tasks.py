import json
from random import choice
from time import sleep
import requests
from datetime import datetime, timedelta

from django.db.utils import ProgrammingError
from django.conf import settings

from stellarbot.celery import app

from api.models import Ledger, Asset, AssetPair, WorkerLogLine


# health-check
@app.task(bind=True, hard_time_limit=5)
def celery_worker_health_check(self, timestamp):
    try:
        Ledger.objects.all().count()
    except ProgrammingError as e:
        log_print(e)
        return None
    return timestamp


LOGS_TABLE_LIMIT = 10 * settings.OBJECTS_RETURN_LIMIT

# clean DB
@app.task()
def clear_old_event_logs():
    logs_count = WorkerLogLine.objects.all().count()
    if logs_count > LOGS_TABLE_LIMIT:
        delete_count = logs_count - LOGS_TABLE_LIMIT
        log_print(f'{logs_count} log entries found, limit is {LOGS_TABLE_LIMIT}, deleting {delete_count}...')
        for log in WorkerLogLine.objects.all().order_by('timestamp')[:delete_count]:
            log.delete()


# utility

def log_print(line):
    print(line)
    WorkerLogLine(entry=line).save()

def make_api_request(href):
    return requests.get(href).json()


def get_latest_asset_aggregation(counter_asset, base_asset=None):

    # everything is in milliseconds
    resolution = 60 * 1000  # one minute
    end_time = int(datetime.utcnow().timestamp()) * 1000  # end_time is now
    start_time = end_time - settings.API_HISTORY_HOURS * 3600 * 1000  # start_time is 48 hours ago

    if base_asset:
        request_string = ''.join([f'https://horizon.stellar.org/trade_aggregations?base_asset_type={counter_asset.asset_type}',
                                  f'&counter_asset_code={counter_asset.asset_code}',
                                  f'&counter_asset_issuer={counter_asset.asset_issuer}',
                                  f'&counter_asset_type=credit_alphanum4',
                                  f'&base_asset_code={base_asset.asset_code}',
                                  f'&base_asset_issuer={base_asset.asset_issuer}',
                                  f'&resolution={resolution}&start_time={start_time}&end_time={end_time}',
                                  f'&limit=1&order=desc'])
    else:
        request_string = ''.join(['https://horizon.stellar.org/trade_aggregations?base_asset_type=native',
                                 f'&counter_asset_code={counter_asset.asset_code}',
                                 f'&counter_asset_issuer={counter_asset.asset_issuer}',
                                 f'&counter_asset_type=credit_alphanum4',
                                 f'&resolution={resolution}&start_time={start_time}&end_time={end_time}',
                                 '&limit=1&order=desc'])
    response = make_api_request(request_string)

    if '_embedded' in response and len(response['_embedded']['records']) > 0:
        num_records = len(response['_embedded']['records'])
        log_print(f"{num_records} aggregation record{'s' if num_records > 1 else ''} found for: {base_asset.asset_code if base_asset else 'XLM'} -> {counter_asset.asset_code}")
        return response['_embedded']['records'][0]
    log_print(f'No aggregation-data found for: {base_asset.asset_code if base_asset else "XLM"} -> {counter_asset.asset_code}')
    return None

def get_path_result(href, path_type, path_note):
    response = make_api_request(href)
    if '_embedded' in response and len(response['_embedded']['records']) > 0:
        num_records = len(response['_embedded']['records'])
        log_print(f"{num_records} {path_type} path record{'s' if num_records > 1 else ''} found for: {path_note}")
        return response['_embedded']['records']
    log_print(f'No {path_type} path-data found for: {path_note}')
    return None

def make_strict_send_path_request(source_asset, destination_asset, source_amount):
    href = ''.join([f'https://horizon.stellar.org/paths/strict-send',
                    f'?source_asset_type={source_asset.asset_type}',
                    f'&source_asset_code={source_asset.asset_code}',
                    f'&source_asset_issuer={source_asset.asset_issuer}',
                    f'&source_amount={source_amount}',
                    f'&destination_assets={destination_asset.asset_code}:{destination_asset.asset_issuer}'])
    path_note = f'{source_amount} {source_asset.asset_code} -> {destination_asset.asset_code}'
    return get_path_result(href, 'strict_send', path_note)

def make_strict_receive_path_request(source_asset, destination_asset, destination_amount):
    href = ''.join([f'https://horizon.stellar.org/paths/strict-receive',
                    f'?source_assets={source_asset.asset_code}:{source_asset.asset_issuer}',
                    f'&destination_asset_type={destination_asset.asset_type}',
                    f'&destination_asset_code={destination_asset.asset_code}',
                    f'&destination_asset_issuer={destination_asset.asset_issuer}',
                    f'&destination_amount={destination_amount}'])
    path_note = f'{source_asset.asset_code} -> {destination_amount} {destination_asset.asset_code}'
    return get_path_result(href, 'strict_receive', path_note)

import math
def get_price_rel_error(a, b):
    if not a or not b:
        return 0, ''
    sign = 1 if a > b else -1
    arith = (2 * abs(a - b) / (a + b)) * sign
    geo = (math.sqrt((a - b)**2 / (a * b))) * sign
    geo_log = (math.exp(math.log(abs(a - b)) - (math.log(a) + math.log(b)) / 2)) * sign
    report = {
        'price_errors': {
            'arithmetic': arith,
            'geometric': geo,
            'geo_log': geo_log,
            'diffs': {
                'geo_log': abs(geo - geo_log),
                'arith_geo': abs(arith - geo),
                'arith_geo_log': abs(arith - geo_log)
            }
        }
    }
    return geo_log, report


# chained, randomized asset-pair scan
@app.task()
def random_asset_pair_scan():

    # ids for all assets in database
    asset_primary_key_list = list(Asset.objects.filter(whitelisted=True).values_list('pk', flat=True))

    if len(asset_primary_key_list) < 2:
        log_print(f"*** Not enough assets. Let's wait {settings.TICK_SECONDS} seconds.")
        random_asset_pair_scan.apply_async(countdown=settings.TICK_SECONDS)
        return

    # pick two (different) random assets
    base_id = choice(asset_primary_key_list)
    asset_primary_key_list.remove(base_id)

    base_asset = Asset.objects.get(pk=base_id)
    counter_asset = Asset.objects.get(pk=choice(asset_primary_key_list))

    asset_pair = AssetPair.objects.filter(counter_asset=counter_asset, base_asset=base_asset).first()
    # if not asset_pair:
    #     asset_pair = AssetPair.objects.filter(counter_asset=base_asset, base_asset=counter_asset).first()
    if asset_pair:
        if asset_pair.timestamp.timestamp() > (datetime.now() - timedelta(seconds=settings.TICK_SECONDS)).timestamp():
            log_print(f'*** {asset_pair} last updated {asset_pair.timestamp}. Let\'s wait {settings.TICK_SECONDS} seconds.')
            random_asset_pair_scan.apply_async(countdown=settings.TICK_SECONDS)
            return
    else:
        asset_pair, _ = AssetPair.objects.get_or_create(counter_asset=counter_asset, base_asset=base_asset)
    
    random_asset_pair_scan.apply_async(countdown=settings.API_REQUEST_DELAY)

    asset_pair.raw_json = ''

    # market data for pair, if it exists
    agg = get_latest_asset_aggregation(counter_asset=asset_pair.counter_asset,
                                       base_asset=asset_pair.base_asset)
    if agg:
        asset_pair.raw_json += json.dumps(agg, indent=2)
        asset_pair.trade_count = int(agg['trade_count'])
        asset_pair.base_volume = float(agg['base_volume'])
        asset_pair.counter_volume = float(agg['counter_volume'])
        asset_pair.avg = float(agg['avg'])
        asset_pair.high = float(agg['high'])
        asset_pair.low = float(agg['low'])
        asset_pair.open = float(agg['open'])
        asset_pair.close = float(agg['close'])

    asset_pair.recent_direct_market = True if asset_pair.close else False

    # PATHS (base -> counter -> base)
    #####
    # we want to look for transactions ~ TARGET_TX_AMT_IN_XLM
    asset_pair.counter_asset_tx_amt = settings.TARGET_TX_AMT_IN_XLM / asset_pair.counter_asset.price

    # strict-receive, buy x counter-asset
    # min base I have to spend to buy x counter
    srbc = make_strict_receive_path_request(source_asset=asset_pair.base_asset,
                                            destination_asset=asset_pair.counter_asset,
                                            destination_amount=asset_pair.counter_asset_tx_amt)
    asset_pair.srbc_raw_json = json.dumps(srbc, indent=2)
    asset_pair.srbc_path_count = len(srbc) if srbc else 0
    asset_pair.srbc_min_base_spend = min(float(r['source_amount']) for r in srbc) if srbc else 0.0

    #####
    # strict-send, sell x counter-asset
    # max base I can buy for x counter
    sscb = make_strict_send_path_request(source_asset=asset_pair.counter_asset,
                                         destination_asset=asset_pair.base_asset,
                                         source_amount=asset_pair.counter_asset_tx_amt)
    asset_pair.sscb_raw_json = json.dumps(sscb, indent=2)
    asset_pair.sscb_path_count = len(sscb) if sscb else 0
    asset_pair.sscb_max_base_buy = max(float(r['destination_amount']) for r in sscb) if sscb else 0.0

    #####
    # absolute error
    asset_pair.base_price_abs_error = asset_pair.sscb_max_base_buy - asset_pair.srbc_min_base_spend
    
    #####
    # relative error
    asset_pair.base_price_rel_error, base_error_report = get_price_rel_error(
                                                            asset_pair.sscb_max_base_buy, 
                                                            asset_pair.srbc_min_base_spend)
    #####
    # absolute error, in XLM
    asset_pair.base_price_xlm_error = asset_pair.base_price_abs_error / asset_pair.base_asset.price

    if asset_pair.srbc_path_count > 0 and asset_pair.sscb_path_count > 0:
        asset_pair.paths_exist = True

    asset_pair.raw_json += json.dumps({'base_price_errors': base_error_report}, indent=2)

    asset_pair.save()

    log_print('-----')
    log_print(asset_pair.srbc_min_base_spend_desc)
    log_print(asset_pair.sscb_max_base_buy_desc)
    log_print('-----')


# chained task for querying stellar network asset list
@app.task()
def handle_asset_api_sync(href='https://horizon.stellar.org/assets?limit=200&order=desc'):
    
    response = make_api_request(href)

    if '_embedded' not in response or len(response['_embedded']['records']) == 0:
        log_print('*** No records found!')
        raise Exception('No Horizon API records found!')

    # async recursion!
    if 'next' in response['_links'] and response['_links']['next']['href']:
        handle_asset_api_sync.apply_async(args=(response['_links']['next']['href'],), 
                                          countdown=2*settings.API_REQUEST_DELAY)
    else:
        # we went all the way through the assets, let's wait a few minutes and start over
        handle_asset_api_sync.apply_async(countdown=settings.TICK_SECONDS)

    # log_print(response)
    for asset in response['_embedded']['records']:

        amount = float(asset['amount'])
        num_accounts = int(asset['num_accounts'])

        # basic asset threshold requirements to even save to db:
        if amount > settings.ASSET_AMOUNT_THRESHOLD:
            if num_accounts > settings.ASSET_NUM_ACCOUNTS_THRESHOLD:
                agg = get_latest_asset_aggregation(Asset(asset_code=asset['asset_code'], 
                                                         asset_issuer=asset['asset_issuer']))
                if agg:
                    trade_count = int(agg['trade_count'])
                    volume = float(agg['counter_volume'])
                    if volume > settings.ASSET_VOLUME_THRESHOLD:
                        if trade_count >  settings.ASSET_TRADE_THRESHOLD:
                            asset_obj, _ = Asset.objects.get_or_create(asset_code=asset['asset_code'], 
                                                                       asset_issuer=asset['asset_issuer'])
                            asset_obj.asset_type = asset['asset_type']
                            asset_obj.amount = amount
                            asset_obj.num_accounts = num_accounts
                            asset_obj.trade_count = trade_count
                            asset_obj.volume = volume
                            asset_obj.price = float(agg['close'])
                            asset_obj.raw_json = json.dumps(asset, indent=2) + json.dumps(agg, indent=2)
                            asset_obj.whitelisted = True
                            asset_obj.save()
                            log_print(f'{asset_obj} whitelisted and saved.')
                else:
                    asset_obj = Asset.objects.filter(asset_code=asset['asset_code'], 
                                                 asset_issuer=asset['asset_issuer']).first()
                    if asset_obj:
                        asset_obj.whitelisted = False
                        asset_obj.save()
                        log_print(f'{asset_obj} UN-whitelisted and saved.')


@app.task()
def start_data_sync():
    # give things time to spin up
    handle_asset_api_sync.apply_async(countdown=60)
    random_asset_pair_scan.apply_async(countdown=60)
