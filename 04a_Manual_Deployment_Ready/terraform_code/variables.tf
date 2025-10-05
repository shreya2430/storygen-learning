variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for deployment."
  type        = string
  default     = "us-central1"
}

variable "frontend_image_url" {
  description = "The full URL of the frontend container image in GCR."
  type        = string
}

variable "backend_image_url" {
  description = "The full URL of the backend container image in GCR."
  type        = string
}

variable "storage_bucket_name" {
  description = "The globally unique name for the Cloud Storage bucket."
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to be used by Cloud Run."
  type        = string
}
