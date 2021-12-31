variable "staging_bucket" {
  description = "GCP Bucket name where deployment code is stored"
  type        = string
}

variable "blob_bucket" {
  description = "GCP Bucket name where blobs are located"
  type        = string
}

variable "blob_path" {
  description = "Blob location path in the bucket"
  type        = string
}

variable "ttl_days" {
  description = "Number of days to keep blobs. Blobs older than this will be removed."
  type        = number
  default     = 30
}

variable "invoker_service_account" {
  description = "Service Account used to invoke Cloud Function"
  type        = string
}

variable "cloud_function_region" {
  description = "Region where Cloud Function will be deployed"
  type        = string
  default = "us-central1"
}
