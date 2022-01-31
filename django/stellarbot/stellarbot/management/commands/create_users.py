import os
from django.core.management import BaseCommand
from django.contrib.auth.models import User, Group, Permission
from django.conf import settings


class Command(BaseCommand):

    def handle(self, *args, **options):
        TESTERUSER_PASSWORD = os.getenv('TESTERUSER_PASSWORD', 'blare-ardent-oyster')
        VIEWERUSER_PASSWORD = os.getenv('VIEWERUSER_PASSWORD', 'tress-catcher-creepy')
        if User.objects.filter(username='admin').count() == 0:
            User.objects.create_superuser('admin',
                                          'admin@nowhere.com',
                                          os.getenv('SUPERUSER_PASSWORD', 'avon-pipeful-sill-pibroch-hunk'))
            print('Superuser "admin" created.')
        else:
            print('Superuser "admin" exists.')
        if User.objects.filter(username='stacktester').count() == 0:
            User.objects.create_user(username='stacktester',
                                     password=TESTERUSER_PASSWORD,
                                     email='stacktester@nowhere.com')
            print('User "stacktester" created.')
        else:
            print('User "stacktester" exists.')
        group, _ = Group.objects.get_or_create(name='read-only-users')
        group.permissions.set([
            Permission.objects.filter(codename='view_asset').first(),
            Permission.objects.filter(codename='view_assettuple').first(),
            Permission.objects.filter(codename='view_workerlogline').first(),
            Permission.objects.filter(codename='view_errorlog').first(),
        ])
        group.save()
        for username in settings.VIEWERUSERS:  
            if User.objects.filter(username=username).count() == 0:
                user = User.objects.create_user(username=username,
                                                password=VIEWERUSER_PASSWORD,
                                                is_staff=True)
                user.groups.set([group])
                user.save()
                print(f'User "{username}" created.')
            else:
                print(f'User "{username}" exists.')