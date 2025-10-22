# Use a lightweight Python image (Based on Debian)
FROM python:slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# ---- START: Add Apache Arrow Repository ----
# Step 1: Install prerequisites for adding custom apt repositories and HTTPS transport
#         'gnupg' for key management, 'lsb-release' to identify the Debian version,
#         'wget' or 'curl' to download the key, 'ca-certificates' for HTTPS.
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Download and add the Apache Arrow GPG key to trusted keys
RUN wget -O /usr/share/keyrings/apache-arrow-keyring.gpg https://downloads.apache.org/arrow/debian/apache-arrow-keyring.gpg

# Step 3: Add the Apache Arrow repository to apt sources.
#         Uses 'lsb_release -cs' to automatically get the Debian codename (e.g., bullseye, bookworm, trixie).
RUN echo "deb [signed-by=/usr/share/keyrings/apache-arrow-keyring.gpg] https://downloads.apache.org/arrow/debian $(lsb_release -cs) main" > /etc/apt/sources.list.d/apache-arrow.list
# ---- END: Add Apache Arrow Repository ----

# Step 4: Update apt package list again to include packages from the new Arrow repository,
#         then install the required build tools and Arrow C++ development libraries.
#         'build-essential' (includes C/C++ compilers, make), 'cmake', and 'libarrow-dev'.
#         Also include 'libgomp1' which was needed by LightGBM or another dependency.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libarrow-dev \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Step 5: Copy your project files into the image
COPY . .

# Step 6: Install Python dependencies using pip.
#         'pip install -e .' will now find the system-installed libarrow-dev
#         and should successfully build pyarrow.
RUN pip install --no-cache-dir -e .

# Step 7: Train the model (if this is part of your build process)
RUN python pipeline/training_pipeline.py

# Step 8: Expose the application port
EXPOSE 5000

# Step 9: Define the command to run the application
CMD ["python", "application.py"]