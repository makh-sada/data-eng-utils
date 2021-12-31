terraform {
  backend "gcs" {
    prefix  = "terraform/state/remove-old-blobs"
  }
}