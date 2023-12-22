terraform {
  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "~> 0.2.6"
    }

    databricks = {
      source = "databricks/databricks"
      version = "~> 1.14.3"
    }
  }
}
