# Use a lightweight Python image (Based on Debian)
FROM python:slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# ---- START: Add Apache Arrow Repository (Corrected Method) ----
# Step 1: Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Download the Apache Arrow repository setup package
# Uses 'lsb_release -cs' to get the Debian codename (e.g., bullseye, bookworm, trixie)
RUN DISTRO=$(lsb_release --codename --short) && \
    wget "https://apache.jfrog.io/artifactory/arrow/debian/apache-arrow-apt-source-latest-${DISTRO}.deb"

# Step 3: Install the setup package (this adds the key and repo source list)
#         Allow untrusted because we just downloaded it; apt update later verifies signatures.
RUN apt-get update && apt-get install -y --allow-unauthenticated ./apache-arrow-apt-source-latest-*.deb

# ---- END: Add Apache Arrow Repository ----

# Step 4: Update apt package list again (now includes Arrow repo) and install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libarrow-dev \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm ./apache-arrow-apt-source-latest-*.deb # Clean up the downloaded .deb file

# Step 5: Copy your project files into the image
COPY . .

# Step 6: Install Python dependencies using pip
RUN pip install --no-cache-dir -e .

# Step 7: Train the model
RUN python pipeline/training_pipeline.py

# Step 8: Expose the application port
EXPOSE 5000

# Step 9: Define the command to run the application
CMD ["python", "application.py"]