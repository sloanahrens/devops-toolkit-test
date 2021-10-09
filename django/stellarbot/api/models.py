from django.db import models


class Ledger(models.Model):

    timestamp = models.DateTimeField(auto_now=True)
    raw_json = models.TextField(null=False, blank=False)

    def __str__(self):
        return str(self.timestamp)
