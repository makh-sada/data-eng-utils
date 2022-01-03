

resource "google_cloud_scheduler_job" "remove-old-notebook-output" {
  name             = "remove-old-notebook-output"
  description      = "Removes output of the older Zeppelin notebook run"
  schedule         = "5 4 * * *"
  time_zone        = "Etc/UTC"
  attempt_deadline = "320s"
  region           = var.cloud_function_region

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.fn_remove_old_blobs.https_trigger_url
    body        = base64encode("{\"ttl_days\":${var.ttl_days}}")

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = var.invoker_service_account
      audience              = google_cloudfunctions_function.fn_remove_old_blobs.https_trigger_url
    }
  }
}
