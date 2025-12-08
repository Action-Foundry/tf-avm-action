# Enterprise-Grade Terraform + Azure CLI + GitHub CLI Docker Action
# This Dockerfile creates a minimal, secure runtime environment

# Use Alpine as the base image for minimal footprint
FROM alpine:3.23.0

# Labels for image metadata (OCI Image Specification)
LABEL org.opencontainers.image.title="tf-avm-action"
LABEL org.opencontainers.image.description="Enterprise-grade GitHub Action with Terraform, Azure CLI, and GitHub CLI"
LABEL org.opencontainers.image.vendor="Action-Foundry"
LABEL org.opencontainers.image.source="https://github.com/Action-Foundry/tf-avm-action"
LABEL org.opencontainers.image.licenses="MIT"

# Install essential dependencies in a single layer to minimize image size
# hadolint ignore=DL3018
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
    openssl

# Copy installation scripts (including lib directory)
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh /scripts/lib/*.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
