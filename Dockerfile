# Use a lightweight Python image
FROM python:slim

# Set environment variables to prevent Python from writing .pyc files & ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies needed for pyarrow, LightGBM, and other compiled packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    build-essential \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all project files
COPY . .

# Install the Python package in editable mode
RUN pip install --no-cache-dir -e .

# Train the model before running the application
RUN python pipeline/training_pipeline.py

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "application.py"]