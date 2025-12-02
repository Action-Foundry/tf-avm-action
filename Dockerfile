# Enterprise-Grade Terraform + Azure CLI + GitHub CLI Docker Action
# This Dockerfile creates a minimal, secure runtime environment

# Use Alpine as the base image for minimal footprint
FROM alpine:3.19

# Build arguments for tool versions
ARG TERRAFORM_VERSION=latest
ARG AZURE_CLI_VERSION=latest
ARG GH_CLI_VERSION=latest

# Labels for image metadata
LABEL org.opencontainers.image.title="tf-avm-action"
LABEL org.opencontainers.image.description="Enterprise-grade GitHub Action with Terraform, Azure CLI, and GitHub CLI"
LABEL org.opencontainers.image.vendor="Action-Foundry"
LABEL org.opencontainers.image.source="https://github.com/Action-Foundry/tf-avm-action"

# Environment variables
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
ENV AZURE_CLI_VERSION=${AZURE_CLI_VERSION}
ENV GH_CLI_VERSION=${GH_CLI_VERSION}

# Install essential dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    openssh-client \
    unzip \
    python3 \
    py3-pip \
    libffi \
    openssl \
    && rm -rf /var/cache/apk/*

# Copy installation scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
