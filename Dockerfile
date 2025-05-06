# Accept build argument for ENVIRONMENT
ARG PYTHON_BASE=3.13.2-slim

# build stage
FROM python:$PYTHON_BASE AS builder

# install PDM
RUN pip install -U --no-cache-dir pdm
# disable update check
ENV PDM_CHECK_UPDATE=false

# copy files
WORKDIR /app
COPY pyproject.toml pdm.lock README.md ./

# install dependencies and project into the local packages directory
RUN pdm install --prod --no-lock --no-editable;

# run stage
FROM python:$PYTHON_BASE AS final

WORKDIR /app

# retrieve packages from build stage
COPY --from=builder /app/.venv /app/.venv
COPY . .

# Set env to use the .venv's python and pip
ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]