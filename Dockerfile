# Use Python 3.11 slim image (compatible with pyarrow prebuilt wheel)
FROM python:3.11-slim

# Set environment variables to prevent Python from writing .pyc files & ensure unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies needed for some Python packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install PyArrow from prebuilt wheel
RUN pip install --no-cache-dir pyarrow==12.0.0

# Copy the project files
COPY . .

# Install project dependencies
RUN pip install --no-cache-dir -e .

# Expose the port
EXPOSE 5000

# Start the Flask app
CMD ["python", "application.py"]
