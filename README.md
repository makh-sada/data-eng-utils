# data-eng-utils
Reusable artifacts for data migration

## Cloud Function remove-old-blobs installation instructions
Cloud Function remove-old-blobs removes blobs older than days in provided ttl_days parameter

1. Change location to `terraform/remove-old-blobs`  
2. Create a new or select an existing terraform workspace
> `terraform workspace new <workspace>` or
> `terraform workspace select <workspace>`

3. Create workspace properties file `terraform/env/<workspace>/remove_old_blobs.tfvars`
4. Run 
> `terraform plan -var-file=../env/<workspace>/remove_old_blobs.tfvars -out <workspace>.tfplan`
5. Verify terraform plan
6. Run the following command to create Cloud Function and all required resource
> `terraform apply "<workspace>.tfplan"`
