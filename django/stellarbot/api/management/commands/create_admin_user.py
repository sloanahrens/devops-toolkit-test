import os
from django.core.management import BaseCommand
from django.contrib.auth.models import User


class Command(BaseCommand):

    def handle(self, *args, **options):

        if User.objects.filter(username='admin').count() == 0:

            User.objects.create_superuser('admin',
                                          os.getenv('SUPERUSER_EMAIL', 'admin@nowhere.com'),
                                          os.getenv('SUPERUSER_PASSWORD', 'blare-ardent-oyster-parlay'))
            print('Useruser "admin" created.')
        else:
            print('Useruser "admin" exists.')