#!/bin/bash
#
# 03-deploy-infrastructure.sh: Deploy Infrastructure with Terraform
#
# This script uses Terraform to provision the cloud infrastructure required
# for the StoryGen application, including Cloud Run services, storage buckets,
# and IAM policies.
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Change to the script's directory ---
cd "$(dirname "$0")"

# --- Load Environment Variables ---
source ./load-env.sh

# --- Navigate to Terraform directory ---
if [ ! -d "./terraform_code" ]; then
  echo "Error: terraform_code directory not found."
  exit 1
fi
cd ./terraform_code

echo "--- Starting Terraform Deployment ---"
echo "Project: $PROJECT_ID"
echo "Region: $REGION"

# --- Initialize Terraform ---
echo ""
echo "Step 1: Initializing Terraform..."
terraform init
echo "Terraform initialized successfully."

# --- Apply Terraform Configuration ---
echo ""
echo "Step 2: Applying Terraform configuration..."
echo "This will provision the infrastructure. Review the plan carefully."

# Pass environment variables to Terraform
export TF_VAR_project_id="$PROJECT_ID"
export TF_VAR_region="$REGION"
export TF_VAR_service_account_name="$SERVICE_ACCOUNT_NAME"
# The image URLs from the previous step are needed for the Cloud Run services.
GCR_HOSTNAME="gcr.io"
FRONTEND_IMAGE_NAME="storygen-frontend"
BACKEND_IMAGE_NAME="storygen-backend"
IMAGE_TAG="latest"
export TF_VAR_frontend_image_url="${GCR_HOSTNAME}/${PROJECT_ID}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG}"
export TF_VAR_backend_image_url="${GCR_HOSTNAME}/${PROJECT_ID}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG}"

terraform apply -auto-approve

echo ""
echo "--- Terraform Deployment Complete! ---"

# --- Output Service URLs ---
echo ""
echo "Fetching service URLs..."
FRONTEND_URL=$(terraform output -raw frontend_url)
BACKEND_URL=$(terraform output -raw backend_url)

echo "Deployment successful!"
echo "--------------------------------------------------"
echo "Frontend URL: $FRONTEND_URL"
echo "Backend URL:  $BACKEND_URL"
echo "--------------------------------------------------"