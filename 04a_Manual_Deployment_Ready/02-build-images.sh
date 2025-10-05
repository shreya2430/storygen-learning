#!/bin/bash

# ----------------------------------------------------------------------------
# 02-build-images.sh: Build and Push Docker Images
#
# This script builds the Docker images for the frontend and backend, tags
# them, and pushes them to Google Container Registry (GCR).
# ----------------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# Source environment variables
source ./load-env.sh

# --- Configure Docker for GCR ---

echo "
🚀 Step 1: Configuring Docker to authenticate with GCR..."
gcloud auth configure-docker gcr.io

# --- Build and Push Backend Image ---

echo "
🚀 Step 2: Building and pushing the Backend image..."
echo "   - Image URL: ${BACKEND_IMAGE_URL}"

docker build -t "${BACKEND_IMAGE_URL}" ./backend
docker push "${BACKEND_IMAGE_URL}"

echo "   - Backend image pushed successfully."

# --- Build and Push Frontend Image ---

echo "
🚀 Step 3: Building and pushing the Frontend image..."
echo "   - Image URL: ${FRONTEND_IMAGE_URL}"

# Note: The NEXT_PUBLIC_BACKEND_URL will be passed as an environment variable
# during the Cloud Run deployment, so we don't need to build it into the image here.
docker build -t "${FRONTEND_IMAGE_URL}" ./frontend
docker push "${FRONTEND_IMAGE_URL}"

echo "   - Frontend image pushed successfully."

echo "
✅ Docker images built and pushed to GCR!"
