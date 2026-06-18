FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/app/ ./app/

EXPOSE 8080

CMD ["uvicorn", "app.asgi:application", "--host", "0.0.0.0", "--port", "8080"]
