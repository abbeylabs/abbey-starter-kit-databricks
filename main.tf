terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.2"
    }

    databricks = {
      source = "databricks/databricks"
      version = "1.14.3"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

provider "databricks" {
  host = var.databricks_host
  token = var.databricks_token
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
          one_of = ["replace-me@example.com", "replace-me@example.com"]
        }
      }
    ]
  }

  policies = [
    {
      query = <<-EOT
        package main

        import data.abbey.functions

        allow[msg] {
          true; functions.expire_after("72h")
          msg := "granting access for 3 days"
        }
      EOT
    }
  ]

  output = {
    location = "github://organization/repo/access.tf"
    append = <<-EOT
      resource "databricks_group_member" "group_member_{{ .data.system.abbey.secondary_identities.databricks.tf_resource_id }}" {
        group_id  = ${databricks_group.pii_group.id}
        member_id = {{ .data.system.abbey.secondary_identities.databricks.tf_resource_id }}
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  name = "replace-me"

  linked = jsonencode({
    abbey = [
      {
        type  = "AuthId"
        value = "replace-me@example.com"
      }
    ]

    databricks = [
      {
        tf_resource_id = databricks_user.replace_me_user.id
        tf_state_name = "databricks_playground_1"
        user_name = databricks_user.replace_me_user.user_name
      }
    ]
  })
}