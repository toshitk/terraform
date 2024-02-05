provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
}

module "sample_query" {
  source = "./modules/scheduled_query"
}

# resource "google_bigquery_data_transfer_config" "s3_data_transfer" {
#   destination_dataset_id = "data_transfer_test"
#   display_name           = "tf_from_s3"
#   data_source_id         = "amazon_s3"
#   schedule               = "every day 00:00"
#   location               = "asia-northeast1"

#   params = {
#     destination_table_name_template = "tf_users"
#     file_format                     = "JSON"
#     max_bad_records                 = "0"
#     data_path                       = "s3://test-bq-data-transfer/transfer-data.json"
#     access_key_id                   = var.s3_access_key
#     secret_access_key               = var.s3_secret_key
#   }
# }
module "sample_transfer" {
  source = "./modules/s3_data_transfer"
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}
