# Use Jenkins LTS as base
FROM jenkins/jenkins:lts

# Switch to root user
USER root

# Install prerequisites
RUN apt-get update -y && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        lsb-release \
        build-essential \
        cmake \
        python3-dev \
        git \
        libssl-dev \
        libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Add Docker official GPG key and repo
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker packages
RUN apt-get update -y && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to Docker group
RUN groupadd -f docker && usermod -aG docker jenkins

# Create Docker directory and volume for DinD
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker

# Switch back to Jenkins user
USER jenkins