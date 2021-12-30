import os
from datetime import datetime, timezone, timedelta
from google.cloud import storage


def remove_old_blobs(request):
  ''' Removes blobs older than provided TTL_DAYS parameter'''

  storage_client = storage.Client()

  bucket_name = os.environ.get('BLOB_BUCKET')
  prefix = os.environ.get('BLOB_PATH')

  if not (bucket_name and prefix):
    raise ValueError("Environment variables BLOB_BUCKET and BLOB_PATH must be set to run this function.")

  content_type = request.headers['content-type']
  if content_type == 'application/json':
      request_json = request.get_json(silent=True)
      if request_json and 'ttl_days' in request_json:
          ttl_days = request_json['ttl_days']
      else:
          ttl_days = int(os.environ.get('TTL_DAYS', 30))

  if not (ttl_days and isinstance(ttl_days, int)):
    raise ValueError("Invalid or missing TTL_DAYS parameter.")

  cutoff_day = datetime.now(tz=timezone.utc) - timedelta(days = ttl_days)
  print(f"cutoff_day: {cutoff_day}")

  # Note: Client.list_blobs requires at least package version 1.17.0.
  blobs = storage_client.list_blobs(bucket_name, prefix=prefix)
  blobs_to_delete = [b for b in blobs if b.updated < cutoff_day]
  print(f"Blobs to delete: {len(blobs_to_delete)}")

  if len(blobs_to_delete) > 0:
    
    #remove batch due to https://github.com/googleapis/python-storage/issues/86
    with storage_client.batch():
      for blob in blobs_to_delete:
        print(f"blob:{blob.name}, size:{blob.size}, updated:{blob.updated}")
        # blob.delete()

  return 'Done.'