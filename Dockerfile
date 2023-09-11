# Use an official Ubuntu as a base image
FROM ubuntu:20.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Run package updates and install packages
RUN apt-get update && \
    apt-get install -y \
    rsync \
    openssh-client \
    git \
    vim \
    curl \
    wget \
    gnupg \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    apt-get update && \
    apt-get install -y mongodb-org

# Install 'drive' for Google Drive command-line interaction
RUN go get -u github.com/odeke-em/drive/cmd/drive

# Temporary add SSH key and clone the repo
COPY id_rsa /tmp/
RUN chmod 600 /tmp/id_rsa && \
    ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts && \
    GIT_SSH_COMMAND="ssh -i /tmp/id_rsa" git clone git@github.com:trilloc/workspace_config.git /tmp/workspace_config && \
    mv /tmp/workspace_config/push_to_drive.sh /usr/local/bin/ && \
    mv /tmp/workspace_config/pull_from_drive.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/push_to_drive.sh /usr/local/bin/pull_from_drive.sh && \
    rm -rf /tmp/id_rsa /tmp/workspace_config

# Create a working directory
WORKDIR /workspace

# Set the pull script as the default command
CMD ["/usr/local/bin/pull_from_drive.sh"]

