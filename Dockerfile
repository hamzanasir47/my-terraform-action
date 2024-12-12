# Use a lightweight base image
FROM hashicorp/terraform:1.5.7

# Install additional tools if needed (e.g., AWS CLI, Azure CLI)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# Set up Terraform plugins if required
# (For example, install a specific version of a provider plugin)

# Add a script for running Terraform commands
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]