FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Create non-root user first
RUN groupadd -r app && useradd -r -g app -d /app -s /bin/bash app

# Install system dependencies with security updates
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy requirements first for better caching
COPY requirements-simple.txt ./requirements.txt

# Install Python dependencies with security updates
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create evidence directories and set permissions
RUN mkdir -p evidence/screenshots evidence/logs evidence/reports evidence/videos && \
    chown -R app:app /app

# Switch to non-root user
USER app

# Expose port
EXPOSE 2020

# Set environment variables
ENV PYTHONPATH=/app
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=2020
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:2020/ || exit 1

# Run the application
CMD ["python", "main.py", "--host", "0.0.0.0"]