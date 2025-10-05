#!/bin/bash

# ----------------------------------------------------------------------------
# 03-deploy-infrastructure.sh: Deploy Infrastructure with Terraform
#
# This script runs Terraform to provision the Cloud Run services, storage
# bucket, and all related configurations.
# ----------------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# Source environment variables
source ./load-env.sh

# --- Prepare Terraform Variables ---

# The service account email is needed by Terraform to assign IAM roles.
export TF_VAR_service_account_email="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# --- Run Terraform ---

echo "
🚀 Step 1: Initializing Terraform in ./terraform_code..."
# The -upgrade flag ensures modules are updated to the versions specified in the configuration.
terraform -chdir=./terraform_code init -upgrade


echo "
🚀 Step 2: Applying Terraform configuration..."
echo "   - This will provision the infrastructure on GCP."
echo "   - Terraform will ask for confirmation before proceeding."

# The -auto-approve flag can be added to skip the interactive confirmation.
# For manual deployment, it's safer to review the plan first.
terraform -chdir=./terraform_code apply

# --- Output Service URLs ---

echo "
🚀 Step 3: Fetching deployed service URLs..."

FRONTEND_URL=$(terraform -chdir=./terraform_code output -raw frontend_service_url)
BACKEND_URL=$(terraform -chdir=./terraform_code output -raw backend_service_url)


echo "
✅ Deployment Complete!"
echo "   -  Frontend URL: ${FRONTEND_URL}"
echo "   - Backend URL: ${BACKEND_URL}"

echo "
To see the status of your services, run:"
echo "   gcloud run services list --platform managed --project ${PROJECT_ID}"
