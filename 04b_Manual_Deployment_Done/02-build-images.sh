#!/bin/bash
#
# 02-build-images.sh: Build and Push Docker Images
#
# This script builds Docker images for the frontend and backend services
# and pushes them to the Google Container Registry (GCR).
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Change to the script's directory ---
cd "$(dirname "$0")"

# --- Load Environment Variables ---
source ./load-env.sh

# --- Define Image Variables ---
# Using gcr.io for Container Registry
GCR_HOSTNAME="gcr.io"
FRONTEND_IMAGE_NAME="storygen-frontend"
BACKEND_IMAGE_NAME="storygen-backend"
IMAGE_TAG="latest"

FRONTEND_IMAGE_URL="${GCR_HOSTNAME}/${PROJECT_ID}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG}"
BACKEND_IMAGE_URL="${GCR_HOSTNAME}/${PROJECT_ID}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG}"

echo "--- Starting Docker Image Build & Push ---"
echo "Project: $PROJECT_ID"
echo "Frontend Image URL: $FRONTEND_IMAGE_URL"
echo "Backend Image URL: $BACKEND_IMAGE_URL"

# --- Build and Push Frontend Image ---
echo ""
echo "Step 1: Building Frontend Docker Image..."
if [ -f "./frontend/Dockerfile" ]; then
  docker build -t "$FRONTEND_IMAGE_URL" ./frontend
  echo "Frontend image built successfully."
else
  echo "Error: ./frontend/Dockerfile not found."
  exit 1
fi

echo ""
echo "Step 2: Pushing Frontend Image to GCR..."
docker push "$FRONTEND_IMAGE_URL"
echo "Frontend image pushed successfully."


# --- Build and Push Backend Image ---
echo ""
echo "Step 3: Building Backend Docker Image..."
if [ -f "./backend/Dockerfile" ]; then
  docker build -t "$BACKEND_IMAGE_URL" ./backend
  echo "Backend image built successfully."
else
  echo "Error: ./backend/Dockerfile not found."
  exit 1
fi

echo ""
echo "Step 4: Pushing Backend Image to GCR..."
docker push "$BACKEND_IMAGE_URL"
echo "Backend image pushed successfully."

echo ""
echo "--- Image Build & Push Complete! ---"