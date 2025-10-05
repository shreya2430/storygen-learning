#!/bin/bash

# ----------------------------------------------------------------------------
# Load Environment Variables for StoryGen Deployment
#
# This script exports all necessary environment variables for the deployment
# scripts. Source this file before running the deployment scripts.
#
# Usage: source ./load-env.sh
# ----------------------------------------------------------------------------

# --- GCP Project Configuration ---
# Replace with your Google Cloud Project ID
export PROJECT_ID="your-gcp-project-id"

# Replace with your desired GCP region
export REGION="us-central1"

# --- Application Configuration ---
# A unique name for your storage bucket (must be globally unique)
export STORAGE_BUCKET_NAME="storygen-assets-${PROJECT_ID}"

# The name for the service account that will be created
export SERVICE_ACCOUNT_NAME="storygen-service-account"

# --- Docker Image Configuration ---
# The names for your Docker images
export FRONTEND_IMAGE_NAME="storygen-frontend"
export BACKEND_IMAGE_NAME="storygen-backend"

# The full image path in Google Container Registry
export FRONTEND_IMAGE_URL="gcr.io/${PROJECT_ID}/${FRONTEND_IMAGE_NAME}:latest"
export BACKEND_IMAGE_URL="gcr.io/${PROJECT_ID}/${BACKEND_IMAGE_NAME}:latest"

# --- API Keys and Secrets ---
# Your Google AI API Key for the StoryAgent
# Keep this secret and do not commit it to version control.
export GOOGLE_API_KEY="your-google-api-key"

# --- Terraform Variables ---
# These variables are passed to the Terraform scripts.
export TF_VAR_project_id=${PROJECT_ID}
export TF_VAR_region=${REGION}
export TF_VAR_frontend_image_url=${FRONTEND_IMAGE_URL}
export TF_VAR_backend_image_url=${BACKEND_IMAGE_URL}
export TF_VAR_storage_bucket_name=${STORAGE_BUCKET_NAME}

# --- Frontend Build-time Environment Variable ---
# This will be set to the backend URL after deployment.
# We initialize it as empty here.
export NEXT_PUBLIC_BACKEND_URL=""


echo "✅ Environment variables loaded."
echo "   Project ID: ${PROJECT_ID}"
echo "   Region: ${REGION}"
echo "   Frontend Image: ${FRONTEND_IMAGE_URL}"
echo "   Backend Image: ${BACKEND_IMAGE_URL}"
