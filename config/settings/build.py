from django.core.management.utils import get_random_secret_key

from .base import *  # noqa
from .base import env


DEBUG = False
# https://docs.djangoproject.com/en/dev/ref/settings/#secret-key
SECRET_KEY = env("DJANGO_SECRET_KEY", default=get_random_secret_key())
