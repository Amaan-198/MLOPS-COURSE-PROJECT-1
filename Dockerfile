# Use a lightweight Python image (Based on Debian)
FROM python:3.13-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies required for building wheels of some packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Install Python dependencies using pip
# Pin pyarrow to a version with prebuilt wheels to avoid compilation issues
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir pyarrow==12.0.0 \
    && pip install --no-cache-dir -e .

# Train the model
RUN python pipeline/training_pipeline.py

# Expose the application port
EXPOSE 5000

# Command to run the application
CMD ["python", "application.py"]
