variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}
variable "s3_access_key" {
  description = "Amazon S3 Access Key"
  type        = string
}
variable "s3_secret_key" {
  description = "Amazon S3 Secret Key"
  type        = string
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
}

resource "google_bigquery_data_transfer_config" "scheduled_query" {
  destination_dataset_id = "dataset"
  display_name           = "tf_scheduled_query1"
  data_source_id         = "scheduled_query"
  schedule               = "every day 10:00"
  location               = "asia-northeast1" 
  params = {
    query                 = "select * from dataset.sample limit 1;"
    destination_table_name_template = "tf_scheduled_query1_{run_date}"
    write_disposition     = "WRITE_TRUNCATE"
  }
}

resource "google_bigquery_data_transfer_config" "s3_data_transfer" {
  destination_dataset_id = "data_transfer_test"
  display_name           = "tf_from_s3"
  data_source_id         = "amazon_s3"
  schedule               = "every 24 hours"
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