#!/bin/bash

# Function to print an error message and exit
function error_exit {
    echo "$1" >&2
    exit 1
}

# Get stack info
STACK_NAME=$(grep '^STACK_NAME=' .env | cut -d '=' -f 2-)
STACK_PATH="serverless_fastapi/stacks/azure"

# Check if STACK_NAME is set
if [ -z "$STACK_NAME" ]; then
  error_exit "STACK_NAME is not set in the .env file."
fi

# Attempt to select the Pulumi stack
pulumi stack select "$STACK_NAME" -C "$STACK_PATH" 2>/dev/null

# Check the exit code to determine if the stack exists
if [ $? -ne 0 ]; then
  echo "Stack $STACK_NAME does not exist. Initializing..."
  pulumi stack init "$STACK_NAME" -C "$STACK_PATH" || error_exit "Failed to initialize stack $STACK_NAME."
else
  echo "Stack $STACK_NAME already exists. Skipping initialization."
fi

# Azure CLI login and set the subscription
az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
az account set --subscription "$ARM_SUBSCRIPTION_ID"

# Deploy the stack
echo "Deploying stack $STACK_NAME..."
pulumi up --yes --stack "$STACK_NAME" -C "$STACK_PATH" || error_exit "Failed to deploy stack $STACK_NAME."
