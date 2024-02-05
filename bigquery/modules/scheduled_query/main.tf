resource "google_bigquery_data_transfer_config" "scheduled_query" {
  destination_dataset_id = "dataset"
  display_name           = "tf_scheduled_query1"
  data_source_id         = "scheduled_query"
  schedule               = "every day 10:00"
  location               = "asia-northeast1"
  disabled               = true
  params = {
    query                 = "select * from dataset.sample limit 1;"
    destination_table_name_template = "tf_scheduled_query1_{run_date}"
    write_disposition     = "WRITE_TRUNCATE"
  }
}
