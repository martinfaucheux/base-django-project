# Accept build argument for ENVIRONMENT
ARG PYTHON_VERSION

# Build stage
FROM python:${PYTHON_VERSION:-3.13.2}-slim-bullseye AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PDM_CHECK_UPDATE=false

WORKDIR /app

# install PDM
RUN pip install -U --no-cache-dir pdm

# copy files
COPY pyproject.toml pdm.lock README.md /app/

# install dependencies and project into the local packages directory
RUN pdm install --prod --no-lock --no-editable;

# Run stage
FROM python:${PYTHON_VERSION:-3.13.2}-slim-bullseye AS final

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/app/.venv/bin:$PATH

WORKDIR /app

# retrieve packages from build stage
COPY --from=builder /app/.venv/ /app/.venv
COPY . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]