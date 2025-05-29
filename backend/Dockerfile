FROM python:3.9-slim

WORKDIR /app

# Install system dependencies for python-magic
RUN apt-get update && apt-get install -y \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Create log directory
RUN mkdir -p /var/log/gunicorn

# Command to run the application using gunicorn with improved logging
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--log-level", "info", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
