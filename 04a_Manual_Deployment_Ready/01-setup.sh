#!/bin/bash

# ----------------------------------------------------------------------------
# 01-setup.sh: GCP Environment Setup
#
# This script authenticates with GCP, configures the project, and enables
# all necessary APIs for the StoryGen application.
# ----------------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# Source environment variables
source ./load-env.sh

# --- Authenticate and Configure GCP ---

echo "
🚀 Step 1: Authenticating with Google Cloud..."
gcloud auth login
gcloud config set project "${PROJECT_ID}"

# --- Enable Required GCP Services ---

echo "
🚀 Step 2: Enabling necessary GCP APIs..."

SERVICES_TO_ENABLE=(
  "iam.googleapis.com"            # IAM for service accounts
  "run.googleapis.com"            # Cloud Run for hosting
  "containerregistry.googleapis.com" # Google Container Registry for Docker images
  "aiplatform.googleapis.com"     # Vertex AI for Imagen
  "storage-component.googleapis.com" # Cloud Storage for buckets
  "cloudresourcemanager.googleapis.com" # To allow Terraform to manage resources
)

for SERVICE in "${SERVICES_TO_ENABLE[@]}"; do
  echo "   - Enabling ${SERVICE}..."
  gcloud services enable "${SERVICE}" --project="${PROJECT_ID}"
done

# --- Create Service Account ---

echo "
🚀 Step 3: Creating Service Account..."

if gcloud iam service-accounts describe "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" >/dev/null 2>&1; then
  echo "   - Service account '${SERVICE_ACCOUNT_NAME}' already exists. Skipping creation."
else
  gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --display-name="StoryGen Application Service Account" \
    --project="${PROJECT_ID}"
  echo "   - Service account '${SERVICE_ACCOUNT_NAME}' created."
fi

# --- Grant IAM Roles to Service Account ---

echo "
🚀 Step 4: Granting IAM Roles to Service Account..."

# Roles needed for Cloud Run, Vertex AI (Imagen), and Cloud Storage
ROLES_TO_GRANT=(
  "roles/run.admin"             # Full control over Cloud Run services
  "roles/storage.admin"         # Full control over Cloud Storage buckets
  "roles/aiplatform.user"       # To use Vertex AI services like Imagen
  "roles/iam.serviceAccountUser" # To allow Cloud Run to act as the service account
)

SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

for ROLE in "${ROLES_TO_GRANT[@]}"; do
  echo "   - Granting ${ROLE} to ${SA_EMAIL}..."
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="${ROLE}" \
    --condition=None >/dev/null
done

echo "
✅ GCP setup complete!"
