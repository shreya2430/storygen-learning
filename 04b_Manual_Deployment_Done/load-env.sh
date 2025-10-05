#!/bin/bash
#
# Loads environment variables from the .env file in the parent directory.
# This script is designed to be sourced by other scripts.
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Load Environment Variables ---
# The .env file is expected to be in the root of the storygen-learning directory
if [ -f "../.env" ]; then
  echo "Loading environment variables from ../.env"
  export $(grep -v '^#' ../.env | xargs)
else
  echo "Error: .env file not found in the parent directory (../.env)."
  echo "Please ensure a .env file exists in the 'storygen-learning' root with required variables."
  exit 1
fi

# --- Validate Required Variables ---
required_vars=("PROJECT_ID" "REGION" "SERVICE_ACCOUNT_NAME")
missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "Error: The following required environment variables are not set in .env:"
  for var in "${missing_vars[@]}"; do
    echo "  - $var"
  done
  exit 1
fi

echo "Environment variables loaded successfully."
