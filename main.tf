locals {
  account_name = ""
  repo_name = ""

  project_path = "github://${local.account_name}/${local.repo_name}"
  policies_path = "${local.project_path}/policies"
}

resource "databricks_group" "pii_group" {
  display_name               = "PII Group"
  allow_cluster_create       = true
  allow_instance_pool_create = true
}

resource "databricks_user" "replace_me_user" {
  user_name    = "replace-me@example.com"
}

resource "abbey_grant_kit" "databricks_pii_group" {
  name = "Databricks PII Group"
  description = "Databricks PII group"

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = ["replace-me@example.com"]
        }
      }
    ]
  }

  policies = [
    { bundle = local.policies_path }
  ]

  output = {
    location = "${local.project_path}/access.tf"
    append = <<-EOT
      resource "databricks_group_member" "group_member_{{ .user.databricks.tf_resource_id }}" {
        group_id  = databricks_group.pii_group.id
        member_id = {{ .user.databricks.tf_resource_id }}
      }
    EOT
  }
}
