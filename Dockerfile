# Use a lightweight Python image
FROM python:slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# ---- START: Add Apache Arrow Repository ----
# Install prerequisites for adding custom apt repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    lsb-release \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Import Apache Arrow GPG key
RUN wget -O /usr/share/keyrings/apache-arrow-keyring.gpg https://downloads.apache.org/arrow/debian/apache-arrow-keyring.gpg

# Add Apache Arrow repository
# Need to evaluate lsb_release -cs inside the RUN command
RUN echo "deb [signed-by=/usr/share/keyrings/apache-arrow-keyring.gpg] https://downloads.apache.org/arrow/debian $(lsb_release -cs) main" > /etc/apt/sources.list.d/apache-arrow.list
# ---- END: Add Apache Arrow Repository ----

# Install system dependencies including libarrow-dev FROM the Arrow repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    build-essential \
    cmake \
    libarrow-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all project files
COPY . .

# Install the Python package in editable mode
# This should now succeed as libarrow-dev is installed
RUN pip install --no-cache-dir -e .

# Train the model before running the application
RUN python pipeline/training_pipeline.py

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "application.py"]