from .base import *  # noqa
from .base import INSTALLED_APPS, env


DEBUG = True
# https://docs.djangoproject.com/en/dev/ref/settings/#secret-key
SECRET_KEY = env(
    "DJANGO_SECRET_KEY",
    default="!!!SET DJANGO_SECRET_KEY!!!",
)


ALLOWED_HOSTS = ["localhost", "0.0.0.0", "127.0.0.1", ".orb.local", ".localhost"]

CSRF_TRUSTED_ORIGINS = [
    "https://*.orb.local",
    "https://*.localhost",
]

INSTALLED_APPS = ["whitenoise.runserver_nostatic"] + INSTALLED_APPS
