# Generated by Django 3.1.4 on 2022-01-03 21:21

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='BoilerPlate',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField(auto_now=True, db_index=True)),
                ('last_updated', models.DateTimeField(auto_now=True, db_index=True)),
                ('raw_json', models.TextField(default='{}')),
            ],
        ),
        migrations.CreateModel(
            name='WorkerLogLine',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField(auto_now=True, db_index=True)),
                ('entry', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='Asset',
            fields=[
                ('boilerplate_ptr', models.OneToOneField(auto_created=True, on_delete=django.db.models.deletion.CASCADE, parent_link=True, primary_key=True, serialize=False, to='api.boilerplate')),
                ('asset_code', models.TextField()),
                ('asset_issuer', models.TextField()),
                ('asset_type', models.TextField()),
                ('amount', models.FloatField(default=0.0)),
                ('num_accounts', models.IntegerField(default=0)),
                ('trade_count', models.IntegerField(default=0)),
                ('volume', models.FloatField(default=0.0)),
                ('price', models.FloatField(default=0.0)),
                ('whitelisted', models.BooleanField(default=False)),
            ],
            bases=('api.boilerplate',),
        ),
        migrations.CreateModel(
            name='Ledger',
            fields=[
                ('boilerplate_ptr', models.OneToOneField(auto_created=True, on_delete=django.db.models.deletion.CASCADE, parent_link=True, primary_key=True, serialize=False, to='api.boilerplate')),
            ],
            bases=('api.boilerplate',),
        ),
        migrations.CreateModel(
            name='AssetPair',
            fields=[
                ('boilerplate_ptr', models.OneToOneField(auto_created=True, on_delete=django.db.models.deletion.CASCADE, parent_link=True, primary_key=True, serialize=False, to='api.boilerplate')),
                ('trade_count', models.IntegerField(default=0)),
                ('base_volume', models.FloatField(default=0.0)),
                ('counter_volume', models.FloatField(default=0.0)),
                ('avg', models.FloatField(default=0.0)),
                ('high', models.FloatField(default=0.0)),
                ('low', models.FloatField(default=0.0)),
                ('open', models.FloatField(default=0.0)),
                ('close', models.FloatField(default=0.0)),
                ('recent_direct_market', models.BooleanField(default=False)),
                ('paths_exist', models.BooleanField(default=False)),
                ('srbc_raw_json', models.TextField(default='{}')),
                ('srbc_path_count', models.IntegerField(default=0)),
                ('srbc_min_base_spend', models.FloatField(default=0.0)),
                ('sscb_raw_json', models.TextField(default='{}')),
                ('sscb_path_count', models.IntegerField(default=0)),
                ('sscb_max_base_buy', models.FloatField(default=0.0)),
                ('counter_asset_tx_amt', models.FloatField(default=1.0)),
                ('base_price_abs_error', models.FloatField(default=0.0)),
                ('base_price_rel_error', models.FloatField(default=0.0)),
                ('base_price_xlm_error', models.FloatField(default=0.0)),
                ('base_asset', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='base_asset_pairs', to='api.asset')),
                ('counter_asset', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='counter_asset_pairs', to='api.asset')),
            ],
            bases=('api.boilerplate',),
        ),
    ]
