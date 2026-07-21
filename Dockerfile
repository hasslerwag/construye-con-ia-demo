FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.8.3 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /app

RUN pip install --no-cache-dir "poetry==${POETRY_VERSION}"

# Copy only dependency metadata first for better layer caching.
COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root --without dev

COPY app ./app

EXPOSE 8000
# --reload + the mounted ./app volume (see docker-compose.yml) = edit code, refresh browser.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
