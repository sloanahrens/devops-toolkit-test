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
            print('Superuser "admin" exists.')

        if User.objects.filter(username='stacktester').count() == 0:

            User.objects.create_user(username='stacktester',
                                     email='stacktester@nowhere.com',
                                     password=os.getenv('TESTERUSER_PASSWORD', 'avon-pipeful-sill-pibroch-hunk'))
            print('Useruser "stacktester" created.')
        else:
            print('Useruser "stacktester" exists.')