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
  error_exit "Stack $STACK_NAME does not exist. Skipping destruction..."
else
  pulumi destroy --yes --stack "$STACK_NAME" -C "$STACK_PATH" || error_exit "Failed to destroy stack $STACK_NAME."
fi

# Remove the stack
echo "Removing stack $STACK_NAME..."
pulumi stack rm "$STACK_NAME" --yes -C "$STACK_PATH" || error_exit "Failed to remove stack $STACK_NAME."
