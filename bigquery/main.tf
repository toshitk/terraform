provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
}

module "sample_query" {
  source = "./modules/scheduled_query"
}

module "sample_transfer" {
  source = "./modules/s3_data_transfer"
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}
