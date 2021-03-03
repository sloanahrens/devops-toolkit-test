from django.core.management import call_command
from django.db.utils import ProgrammingError

from stellarbot.celery import app
from api.models import Ledger


@app.task(bind=True, hard_time_limit=5)
def celery_worker_health_check(self, timestamp):
    try:
        Ledger.objects.all().count()
    except ProgrammingError:
        return None
    return timestamp


@app.task()
def load_data():
    call_command("load_data")
