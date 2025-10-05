
# Terraform configuration for the StoryGen application
#
# This file defines the GCP infrastructure for the frontend and backend
# services, including Cloud Run, Cloud Storage, and IAM permissions.

# --- Backend Cloud Run Service ---
module "backend-service" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2?ref=v0.20.1"
  project_id   = var.project_id
  location     = var.region
  service_name = "storygen-backend"
  service_account = var.service_account_email

  containers = [{
    container_image = var.backend_image_url
    env_vars = [
      { name = "GOOGLE_CLOUD_PROJECT", value = var.project_id },
      { name = "FRONTEND_URL", value = module.frontend-service.service_url },
      { name = "GOOGLE_GENAI_USE_VERTEXAI", value = "TRUE" }
    ]
  }]

  template_scaling = {
    max_instance_count = 2
    min_instance_count = 0 # Set to 0 for cost-saving, 1 for faster responses
  }
}

# --- Frontend Cloud Run Service ---
module "frontend-service" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2?ref=v0.20.1"
  project_id   = var.project_id
  location     = var.region
  service_name = "storygen-frontend"
  service_account = var.service_account_email

  # Allow unauthenticated access to the frontend
  iam_policy = {
    "roles/run.invoker" = ["allUsers"]
  }

  containers = [{
    container_image = var.frontend_image_url
    env_vars = [{
      name  = "NEXT_PUBLIC_BACKEND_URL"
      value = module.backend-service.service_url
    }]
  }]

  template_scaling = {
    max_instance_count = 2
    min_instance_count = 0
  }

  depends_on = [module.backend-service]
}

# --- Cloud Storage Bucket for Generated Images ---
module "generated-images-bucket" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket?ref=v10.0.2"
  project_id = var.project_id
  location   = var.region
  name       = var.storage_bucket_name

  iam_members = [{
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:${var.service_account_email}"
  }]
}

