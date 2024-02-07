provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_glue_catalog_database" "example" {
  name = "example_database"
}

resource "aws_glue_catalog_table" "example" {
  name          = "example_table"
  database_name = aws_glue_catalog_database.example.name

  parameters = {
    "classification"  = "csv"
    "compressionType" = "none"
  }

  storage_descriptor {
    location      = "s3://toshitk-appflow-test/glue/schemaVersion_2/e1f772a0-9c27-4340-8f24-5a5f2d740ac7-2024-02-02T01:39:49/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "age"
      type = "string"
    }
    columns {
      name = "name"
      type = "string"
    }
  }
}
