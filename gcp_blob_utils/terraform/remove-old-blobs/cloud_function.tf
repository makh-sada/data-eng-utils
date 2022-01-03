data "google_storage_bucket" "staging_bucket" {
  name = var.staging_bucket
}

data "archive_file" "archive_remove_old_blobs" {
  type        = "zip"
  source_dir  = "${path.module}/../../src"
  output_path = "${path.module}/../../bin/remove_old_blobs.zip"
}

resource "google_storage_bucket_object" "gcs_remove_old_blobs" {
  name                = format("tmp/cloud-functions/remove-old-blobs.zip#%s", data.archive_file.archive_remove_old_blobs.output_md5)
  bucket              = data.google_storage_bucket.staging_bucket.name
  source              = data.archive_file.archive_remove_old_blobs.output_path
  content_disposition = "attachment"
  content_encoding    = "gzip"
  content_type        = "application/zip"
}

resource "google_cloudfunctions_function" "fn_remove_old_blobs" {
  name        = "fn-remove-old-blobs"
  description = "Removes blobs older than provided TTL"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = data.google_storage_bucket.staging_bucket.name
  source_archive_object = google_storage_bucket_object.gcs_remove_old_blobs.name
  trigger_http          = true
  entry_point           = "remove_old_blobs"
  region                = var.cloud_function_region

  environment_variables = {
    BLOB_BUCKET = var.blob_bucket
    BLOB_PATH   = var.blob_path
    TTL_DAYS    = var.ttl_days
  }
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.fn_remove_old_blobs.project
  region         = google_cloudfunctions_function.fn_remove_old_blobs.region
  cloud_function = google_cloudfunctions_function.fn_remove_old_blobs.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.invoker_service_account}"
}
