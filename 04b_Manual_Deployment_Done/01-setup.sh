#!/bin/bash
#
# 01-setup.sh: Environment Setup and Authentication
#
# This script prepares your local environment for deploying the StoryGen app.
# It handles:
#   - Loading environment variables
#   - Authenticating with Google Cloud
#   - Enabling necessary Google Cloud services
#   - Configuring Docker to work with Google Container Registry
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Change to the script's directory ---
cd "$(dirname "$0")"

# --- Load Environment Variables ---
source ./load-env.sh

# --- Welcome Message ---
echo "--- Starting GCP Setup for Project: $PROJECT_ID ---"

# --- GCP Authentication ---
echo "Step 1: Authenticating with Google Cloud..."
gcloud auth login
gcloud auth application-default login
echo "Authentication successful."

# --- GCP Configuration ---
echo "Step 2: Configuring gcloud CLI..."
gcloud config set project "$PROJECT_ID"
gcloud config set compute/region "$REGION"
echo "gcloud configured for project '$PROJECT_ID' and region '$REGION'."

# --- Enable GCP Services ---
echo "Step 3: Enabling required Google Cloud services..."
services=(
  "run.googleapis.com"
  "iam.googleapis.com"
  "containerregistry.googleapis.com"
  "cloudbuild.googleapis.com"
  "aiplatform.googleapis.com" # For Vertex AI / Imagen
  "storage-component.googleapis.com"
)

for service in "${services[@]}"; do
  if ! gcloud services list --enabled | grep -q "$service"; then
    echo "Enabling $service..."
    gcloud services enable "$service"
  else
    echo "$service is already enabled."
  fi
done
echo "All required services are enabled."

# --- Configure Docker ---
echo "Step 4: Configuring Docker for Google Container Registry..."
gcloud auth configure-docker "$REGION-docker.pkg.dev"
echo "Docker configured successfully."

# --- Create Service Account ---
echo "Step 5: Creating service account..."
if ! gcloud iam service-accounts list --filter="email~$SERVICE_ACCOUNT_NAME" --format="value(email)" | grep -q "."; then
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --display-name="StoryGen Service Account"
else
  echo "Service account '$SERVICE_ACCOUNT_NAME' already exists."
fi

SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --filter="email~$SERVICE_ACCOUNT_NAME" --format="value(email)")
echo "Using service account: $SERVICE_ACCOUNT_EMAIL"

# --- Grant IAM Roles to Service Account ---
echo "Step 6: Granting IAM roles to the service account..."
roles=(
  "roles/run.invoker"
  "roles/storage.admin"
  "roles/aiplatform.user"
)

for role in "${roles[@]}"; do
  echo "Adding role $role..."
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="$role" \
    --condition=None >/dev/null # Suppress verbose output
done
echo "IAM roles granted successfully."


echo "--- Setup Complete! ---"
echo "Your environment is now configured for deployment."
