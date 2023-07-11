variable "abbey_token" {
  type = string
  sensitive = true
  description = "Abbey API Token"
}

variable "databricks_host" {
  type = string
  description = "Databricks host name"
  sensitive = true
}

variable "databricks_token" {
  type = string
  description = "Databricks token"
  sensitive = true
}
