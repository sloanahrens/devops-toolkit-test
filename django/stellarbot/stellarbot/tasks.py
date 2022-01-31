import math
import json
from random import choice, randint
from time import sleep
import requests
from datetime import datetime, timedelta
from pprint import pprint
from itertools import permutations

from django.db.utils import ProgrammingError
from django.conf import settings

from stellarbot.celery import app

from stellarbot.models import Asset, AssetTuple, Accumlation, WorkerLogLine, ErrorLog


# utility
#####

def make_api_request(href):
    return requests.get(href).json()


def log_print(line):
    print(line)
    WorkerLogLine(entry=line).save()


def log_error(errors_list):
    for line in errors_list:
        log_print(line)
    ErrorLog(raw_json=json.dumps({'errors': errors_list}, indent=2))


def get_latest_asset_aggregation(counter_asset, base_asset=None):

    # everything is in milliseconds
    resolution = 60 * 1000  # one minute
    end_time = int(datetime.utcnow().timestamp()) * 1000  # end_time is now
    start_time = end_time - settings.AGG_HISTORY_HOURS * \
        3600 * 1000  # start_time is 48 hours ago

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
    log_print(
        f'No aggregation-data found for: {base_asset.asset_code if base_asset else "XLM"} -> {counter_asset.asset_code}')
    return None


def get_path_result(href, path_type, path_note):
    response = make_api_request(href)
    if '_embedded' in response and len(response['_embedded']['records']) > 0:
        num_records = len(response['_embedded']['records'])
        log_print(
            f"{num_records} {path_type} path record{'s' if num_records > 1 else ''} found for: {path_note}")
        return response['_embedded']['records']
    log_print(f'No {path_type} path-data found for: {path_note}')
    return None


def make_strict_send_path_request(source_asset, destination_asset, source_amount):
    if source_asset.asset_code == 'XLM':
        href = ''.join([f'https://horizon.stellar.org/paths/strict-send',
                        f'?source_asset_type=native',
                        f'&source_amount={source_amount}',
                        f'&destination_assets={destination_asset.asset_code}:{destination_asset.asset_issuer}'])
    else:
        href = ''.join([f'https://horizon.stellar.org/paths/strict-send',
                        f'?source_asset_type={source_asset.asset_type}',
                        f'&source_asset_code={source_asset.asset_code}',
                        f'&source_asset_issuer={source_asset.asset_issuer}',
                        f'&source_amount={source_amount}',
                        f'&destination_assets={destination_asset.asset_code}:{destination_asset.asset_issuer}'])
    return get_path_result(
        href,
        'strict_send',
        f'{source_amount} {source_asset.asset_code} -> {destination_asset.asset_code}'
    )


def make_strict_receive_path_request(source_asset, destination_asset, destination_amount):
    if destination_asset.asset_code == 'XLM':
        href = ''.join([f'https://horizon.stellar.org/paths/strict-receive',
                        f'?source_assets={source_asset.asset_code}:{source_asset.asset_issuer}',
                        f'&destination_asset_type=native',
                        f'&destination_amount={destination_amount}'])
    else:
        href = ''.join([f'https://horizon.stellar.org/paths/strict-receive',
                        f'?source_assets={source_asset.asset_code}:{source_asset.asset_issuer}',
                        f'&destination_asset_type={destination_asset.asset_type}',
                        f'&destination_asset_code={destination_asset.asset_code}',
                        f'&destination_asset_issuer={destination_asset.asset_issuer}',
                        f'&destination_amount={destination_amount}'])
    return get_path_result(
        href,
        'strict_receive',
        f'{source_asset.asset_code} <- {destination_amount} {destination_asset.asset_code}'
    )


def get_price_rel_error(a, b):
    if not a or not b:
        return 0, ''
    sign = 1 if a >= b else -1
    arith = (2 * abs(a - b) / (a + b)) * sign
    geo = (math.sqrt((a - b)**2 / (a * b))) * sign
    geo_log = (math.exp(math.log(abs(a - b)) -
               (math.log(a) + math.log(b)) / 2)) * sign
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


def get_transaction_string(tx):
    return ''.join([
        f"[{tx['spend']['amount']} {tx['spend']['asset']}",
        f" {'-SS->' if tx['tx_type'] == 'SS' else '<-SR-'} ",
        f"{tx['buy']['amount']} {tx['buy']['asset']}]"
    ])


def get_transaction(tx_type, buy_amount, buy_asset, spend_amount, spend_asset, path_key):
    return {
        'tx_type': tx_type,
        'path_key': path_key,
        'buy': {
            'amount': buy_amount,
            'asset': buy_asset
        },
        'spend': {
            'amount': spend_amount,
            'asset': spend_asset
        }
    }


def do_strict_send(path_key, path_dict, spend_asset, spend_amount, buy_asset):
    if spend_asset.pk == buy_asset.pk:
        log_list = ['(SS) right spend==buy',
                    f'spend_asset: {spend_asset}',
                    f'spend_amount:{spend_amount}',
                    f'buy_asset: {buy_asset}']
        log_error(log_list)
        raise Exception("nope: " + str(log_list))
    if path_key in path_dict:
        ss = path_dict[path_key]
        # log_print(f'Using cached path: {path_key}')
    else:
        ss = make_strict_send_path_request(
            source_asset=spend_asset,
            destination_asset=buy_asset,
            source_amount=spend_amount
        )
        path_dict[path_key] = ss
    if not ss:
        return None
    buy_amount = max(float(r['destination_amount']) for r in ss)
    return get_transaction('SS', buy_amount, buy_asset, spend_amount, spend_asset, path_key)


def do_strict_receive(path_key, path_dict, spend_asset, buy_asset, buy_amount):
    if spend_asset.pk == buy_asset.pk:
        log_list = ['(SR) right spend==buy',
                    f'spend_asset: {spend_asset}',
                    f'buy_asset: {buy_asset}',
                    f'buy_amount:{buy_amount}']
        log_error(log_list)
        raise Exception("nope: " + str(log_list))
        sr = path_dict[path_key]
        # log_print(f'Using cached path: {path_key}')
    else:
        sr = make_strict_receive_path_request(
            source_asset=spend_asset,
            destination_asset=buy_asset,
            destination_amount=buy_amount
        )
        path_dict[path_key] = sr
    if not sr:
        return None
    spend_amount = min(float(r['source_amount']) for r in sr)
    return get_transaction('SR', buy_amount, buy_asset, spend_amount, spend_asset, path_key)

#####


@app.task()
def random_asset_tuplet_scan(chain=False):
    try:

        n = settings.NUM_ASSETS_IN_TUPLE

        base_xlm_transaction_amount = settings.TARGET_TX_AMT_IN_XLM
        # base_xlm_transaction_amount = 10 + randint(1,9) * 10

        paths_found = 0
        paths_tried = 0

        # ids for all assets in database
        asset_primary_key_list = list(Asset.objects.filter(
            whitelisted=True).values_list('pk', flat=True))
        if len(asset_primary_key_list) < n:
            log_print(f"*** Not enough assets for {n}-tuples.")
            if chain:
                log_print(f"*** Let's wait {settings.TICK_SECONDS} seconds.")
                random_asset_tuplet_scan.apply_async(
                    countdown=settings.TICK_SECONDS)
            return

        asset_list = list()
        for _ in range(n):
            a = Asset.objects.get(pk=choice(asset_primary_key_list))
            asset_primary_key_list.remove(a.pk)
            asset_list.append(a)

        xlm = Asset(asset_code='XLM')

        path_dict = dict()

        max_path = None
        max_xlm_diff = None

        for m in range(1, n + 1):
            for k in range(m + 1):
                # print(f'n:{n} m:{m} k:{k}')

                # left loop
                left_assets_perms = permutations(asset_list, k)
                for left_perm in left_assets_perms:

                    abandon_left_perm = False

                    # right loop
                    right_asset_perms = permutations(
                        [a for a in asset_list if a not in left_perm], m - k)
                    for right_perm in right_asset_perms:

                        # print('-----')
                        # print(f'left: {left_perm}')
                        # print(f'right: {right_perm}')

                        paths_tried += 1

                        abandon_right_perm = False

                        # (TODO: why can't I put the left-perm part outside the right-perm loop for better efficiency)?
                        left_spend_asset = xlm
                        left_spend_amount = base_xlm_transaction_amount

                        left_buy_asset = None
                        left_buy_amount = None

                        # strict-send txs from the left
                        left_txs = list()
                        for left_asset in left_perm:
                            left_buy_asset = left_asset
                            # print(f'left_buy_asset: {left_buy_asset}')
                            path_key = f"SS-{left_spend_amount}-{left_spend_asset.asset_code}->{left_buy_asset.asset_code}"
                            # #####
                            # # the work happens here (uses cached paths for repeated work)
                            left_ss = do_strict_send(
                                path_key=path_key,
                                path_dict=path_dict,
                                spend_asset=left_spend_asset,
                                spend_amount=left_spend_amount,
                                buy_asset=left_buy_asset)
                            if not left_ss:
                                log_print(
                                    f'No path available for: {path_key}. Abandoning left_perm: {list(a.asset_code for a in left_perm)}')
                                abandon_left_perm = True
                                break
                            left_txs.append(left_ss)
                            #####
                            left_buy_amount = left_ss['buy']['amount']
                            # for next iteration of loop:
                            left_spend_asset = left_buy_asset
                            left_spend_amount = left_buy_amount
                        if abandon_left_perm:
                            break

                        right_buy_asset = xlm
                        right_buy_amount = base_xlm_transaction_amount

                        right_spend_asset = None
                        right_spend_amount = None

                        # strict-recieve txs from the right
                        right_txs = list()
                        for right_asset in right_perm:
                            right_spend_asset = right_asset
                            if right_spend_asset.pk == right_buy_asset.pk:
                                log_list = [f'spend==buy== {right_spend_asset}',
                                            f'right_buy_amount: {right_buy_amount}'
                                            f'left_txs: {left_txs}',
                                            f'right_txs: {right_txs}',
                                            f'left_perm:{left_perm}',
                                            f'right_perm: {right_perm}']
                                log_error(log_list)
                                raise Exception("nope: " + str(log_list))
                            path_key = f"SR-{right_spend_asset.asset_code}<-{right_buy_amount}{right_buy_asset.asset_code}"
                            # #####
                            # # the work happens here
                            right_sr = do_strict_receive(
                                path_key=path_key,
                                path_dict=path_dict,
                                spend_asset=right_spend_asset,
                                buy_asset=right_buy_asset,
                                buy_amount=right_buy_amount)
                            if not right_sr:
                                log_print(
                                    f'No path available for: {path_key}. Abandoning right_perm: {list(a.asset_code for a in right_perm)}')
                                abandon_right_perm = True
                                break
                            right_txs.append(right_sr)
                            right_spend_amount = right_sr['spend']['amount']
                            # for next iteration of loop:
                            right_buy_asset = right_spend_asset
                            right_buy_amount = right_spend_amount

                        if abandon_right_perm:
                            continue

                        # last step, either buy in or sell out
                        if left_spend_asset.pk == xlm.pk:
                            path_key = f"SS-{left_spend_amount}-{xlm.asset_code}->{right_buy_asset.asset_code}"
                            left_ss = do_strict_send(
                                path_key=path_key,
                                path_dict=path_dict,
                                spend_asset=xlm,
                                spend_amount=base_xlm_transaction_amount,
                                buy_asset=right_buy_asset)
                            if not left_ss:
                                log_print(
                                    f'No path available for: {path_key}. Abandoning left_perm: {list(a.asset_code for a in left_perm)}')
                                break
                            left_txs.append(left_ss)
                            left_buy_amount = left_ss['buy']['amount']
                            left_spend_asset = left_buy_asset
                            left_spend_amount = left_buy_amount
                        else:
                            path_key = f"SR-{left_spend_asset.asset_code}<-{right_buy_amount}{right_buy_asset.asset_code}"
                            if left_spend_asset.pk == right_buy_asset.pk:
                                log_list = [f'spend==buy== {left_spend_asset}',
                                            f'right_buy_amount: {right_buy_amount}'
                                            f'left_txs: {left_txs}',
                                            f'right_txs: {right_txs}',
                                            f'left_perm:{left_perm}',
                                            f'right_perm: {right_perm}']
                                log_error(log_list)
                                raise Exception("nope: " + str(log_list))
                            right_sr = do_strict_receive(
                                path_key=path_key,
                                path_dict=path_dict,
                                spend_asset=left_spend_asset,
                                buy_asset=(xlm if right_buy_asset.pk ==
                                           xlm.pk else right_buy_asset),
                                buy_amount=(base_xlm_transaction_amount if right_buy_asset.pk == xlm.pk else right_buy_amount))
                            if not right_sr:
                                log_print(
                                    f'No path available for: {path_key}. Abandoning right_perm: {list(a.asset_code for a in right_perm)}')
                                break
                            right_txs.append(right_sr)
                            right_spend_amount = right_sr['spend']['amount']
                            right_buy_asset = right_spend_asset
                            right_buy_amount = right_spend_amount

                        #####
                        bridge_asset = left_buy_asset if left_buy_asset else right_spend_asset

                        price_diff = left_buy_amount - right_spend_amount
                        rel_error, _ = get_price_rel_error(
                            left_buy_amount, right_spend_amount)
                        diff_in_xlm = price_diff / bridge_asset.price

                        left_tx_string = ' --- '.join(
                            [get_transaction_string(tx) for tx in left_txs])
                        right_tx_string = ' --- '.join(
                            [get_transaction_string(tx) for tx in reversed(right_txs)])

                        log_print('-----')
                        log_print(left_tx_string)
                        log_print(right_tx_string)
                        log_print('-----')
                        log_print(f'bridge_asset: {bridge_asset}')
                        log_print(f'left_buy_amount: {left_buy_amount}')
                        log_print(f'right_spend_amount: {right_spend_amount}')
                        log_print(f'diff: {price_diff}')
                        log_print(f'rel_error: {rel_error}')
                        log_print('-----')
                        log_print(f'diff_in_xlm: {diff_in_xlm}')
                        log_print('-----')

                        if not max_path or diff_in_xlm > max_xlm_diff:
                            max_xlm_diff = diff_in_xlm
                            for tx in left_txs + right_txs:
                                tx['buy']['asset'] = tx['buy']['asset'].asset_code
                                tx['spend']['asset'] = tx['spend']['asset'].asset_code
                            max_path = AssetTuple(
                                diff_in_xlm=diff_in_xlm,
                                rel_error=rel_error,
                                price_diff=price_diff,
                                left_buy_amount=left_buy_amount,
                                right_spend_amount=right_spend_amount,
                                bridge_asset=bridge_asset,
                                left_tx_string=left_tx_string,
                                right_tx_string=right_tx_string,
                                raw_json=json.dumps({
                                    'left_txs': [{
                                        'desc': get_transaction_string(tx),
                                        'tx': tx,
                                        'path': path_dict[tx['path_key']]
                                    } for tx in left_txs],
                                    'right_txs': [{
                                        'desc': get_transaction_string(tx),
                                        'tx': tx,
                                        'path': path_dict[tx['path_key']]
                                    } for tx in reversed(right_txs)]
                                }, indent=2)
                            )
                            if max_xlm_diff > 0:
                                max_path.save()
                                max_path.asset_set.set(asset_list)
                                max_path.save()
                                Accumlation(
                                    asset_tuple=max_path,
                                    amount=max_path.price_diff,
                                    amount_in_xlm=max_path.diff_in_xlm
                                ).save()

                        paths_found += 1

                    if abandon_left_perm:
                        break

        log_print(f'{paths_tried} paths tried, {paths_found} paths found.')

        if chain:
            random_asset_tuplet_scan.apply_async(
                countdown=settings.API_TUPLE_TASK_REQUEST_DELAY)

    except Exception as e:
        log_print(e)
        raise e


# chained task for querying stellar network asset-list
@app.task()
def chained_asset_api_sync(href='https://horizon.stellar.org/assets?limit=200&order=desc'):
    try:
        response = make_api_request(href)

        if '_embedded' not in response or len(response['_embedded']['records']) == 0:
            log_error('*** No Horizon-API records found!')
            raise Exception('No Horizon API records found!')

        # async recursion! (sort of)
        if 'next' in response['_links'] and response['_links']['next']['href']:
            chained_asset_api_sync.apply_async(args=(response['_links']['next']['href'],),
                                               countdown=settings.API_ASSET_TASK_REQUEST_DELAY)
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
                            if trade_count > settings.ASSET_TRADE_THRESHOLD:
                                asset_obj, _ = Asset.objects.get_or_create(asset_code=asset['asset_code'],
                                                                           asset_issuer=asset['asset_issuer'])
                                asset_obj.asset_type = asset['asset_type']
                                asset_obj.amount = amount
                                asset_obj.num_accounts = num_accounts
                                asset_obj.trade_count = trade_count
                                asset_obj.volume = volume
                                asset_obj.price = float(agg['close'])
                                asset_obj.raw_json = json.dumps(
                                    asset, indent=2) + json.dumps(agg, indent=2)
                                asset_obj.whitelisted = True
                                asset_obj.last_updated = datetime.utcnow()
                                asset_obj.save()
                                log_print(
                                    f'{asset_obj} whitelisted and saved.')
                    else:
                        asset_obj = Asset.objects.filter(asset_code=asset['asset_code'],
                                                         asset_issuer=asset['asset_issuer']).first()
                        if asset_obj:
                            asset_obj.whitelisted = False
                            asset_obj.last_updated = datetime.utcnow()
                            asset_obj.save()
                            log_print(f'{asset_obj} UN-whitelisted and saved.')
    except Exception as e:
        log_print(e)
        raise e


@app.task()
def clean_database():
    try:
        # clean asset-tuples by age
        history_limit = datetime.utcnow() - timedelta(days=settings.ASSET_TUPLE_KEEP_DAYS)
        delete_set = AssetTuple.objects.filter(timestamp__lt=history_limit)
        delete_count = delete_set.count()
        if delete_count > 0:
            log_print(
                f'Deleting {delete_count} Tuples/Accumlations more than {settings.ASSET_TUPLE_KEEP_DAYS} days old...')
            Accumlation.objects.filter(timestamp__lt=history_limit)
            delete_set.delete()

        # clean all tables by row-count
        for model in [Asset, AssetTuple, Accumlation, WorkerLogLine, ErrorLog]:
            object_count = model.objects.all().count()
            log_print(f'Current {model} object-count: {object_count}')
            if object_count > settings.TABLE_ROW_LIMIT:
                delete_count = object_count - settings.TABLE_ROW_LIMIT
                log_print(''.join([f'{object_count} entries found, limit is {settings.TABLE_ROW_LIMIT}, ',
                                   f'deleting {delete_count} from table {model}...']))
                delete_set_pk_list = model.objects.all().order_by(
                    'timestamp')[:delete_count].values_list('pk', flat=True)
                model.objects.filter(pk__in=delete_set_pk_list).delete()
            log_print(
                f'Current {model} object-count: {model.objects.all().count()}')

    except Exception as e:
        log_print(e)
        raise e


# health-check
@app.task(bind=True, hard_time_limit=5)
def celery_worker_health_check(self, timestamp):
    try:
        Asset.objects.all().count()
    except ProgrammingError as e:
        log_print(e)
    except Exception as e:
        log_print(e)
        raise e
    return timestamp
