provider "abbey" {
  bearer_auth = var.abbey_token
}

provider "databricks" {
  host = var.databricks_host
  token = var.databricks_token
}
