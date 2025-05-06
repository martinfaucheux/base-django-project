ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION:-3.13}-slim-bullseye AS build
COPY --from=ghcr.io/astral-sh/uv:0.7 /uv /bin/uv

ENV LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY pyproject.toml uv.lock /app/

FROM build AS dev_builder

RUN --mount=type=cache,target=/root/.cache/uv uv sync


FROM python:${PYTHON_VERSION:-3.13}-slim-bullseye AS base

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/app/.venv/bin:$PATH

RUN useradd -ms /bin/sh -u 1001 app

USER app
WORKDIR /app

FROM build AS prod_builder

RUN uv sync --no-dev

FROM base AS collect_static

COPY --from=prod_builder --chown=app /app/.venv/ /app/.venv
COPY --chown=app manage.py /app/
# Uncomment and put the folder with django apps
#COPY --chown=app my_project /app/my_project
COPY --chown=app config /app/config

# Setup "dumb" values to not fail during collectstatic
ENV DJANGO_SETTINGS_MODULE=config.settings.build
ENV DATABASE_URL=postgres://user:password@postgres/mydb
ENV CACHE_URL=rediscache://redis:6380/1
ENV GH_API_CACHE_URL=rediscache://redis:6380/2
ENV CELERY_BROKER_URL=redis://redis:6380/2

RUN python manage.py collectstatic --no-input

FROM base AS dev

COPY --chown=app manage.py /app/
# Uncomment and put the folder with django apps
#COPY --chown=app my_project /app/my_project
#COPY --chown=app templates /app/templates

COPY --from=dev_builder --chown=app /app/.venv/ /app/.venv
COPY --from=collect_static --chown=app /app/staticfiles /app/staticfiles/


FROM base AS prod

COPY --chown=app manage.py /app/
# Uncomment and put the folder with django apps
#COPY --chown=app my_project /app/my_project
#COPY --chown=app templates /app/templates
COPY --chown=app config /app/config

COPY --from=prod_builder --chown=app /app/.venv/ /app/.venv
COPY --from=collect_static --chown=app /app/staticfiles /app/staticfiles/

WORKDIR /app
