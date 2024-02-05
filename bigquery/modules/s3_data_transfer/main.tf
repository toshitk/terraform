variable "s3_access_key" {
  description = "Amazon S3 Access Key"
  type        = string
}
variable "s3_secret_key" {
  description = "Amazon S3 Secret Key"
  type        = string
}

resource "google_bigquery_data_transfer_config" "s3_data_transfer" {
  destination_dataset_id = "data_transfer_test"
  display_name           = "tf_from_s3"
  data_source_id         = "amazon_s3"
  schedule               = "every day 00:00"
  location               = "asia-northeast1"

  params = {
    destination_table_name_template = "tf_users"
    file_format                     = "JSON"
    max_bad_records                 = "0"
    data_path                       = "s3://test-bq-data-transfer/transfer-data.json"
    access_key_id                   = var.s3_access_key
    secret_access_key               = var.s3_secret_key
  }
}