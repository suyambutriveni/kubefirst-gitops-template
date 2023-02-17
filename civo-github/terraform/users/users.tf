terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/users/tfstate.tf"
    endpoint = "https://objectstore.<CLOUD_REGION>.civo.com"

    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.17.0"
    }
  }
}

data "github_team" "admins" {
  slug = "admins"
}

data "github_team" "developers" {
  slug = "developers"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}

data "vault_identity_group" "admins" {
  group_name = "admins"
}

variable "initial_password" {
  type    = string
  default = ""
}


module "admins" {
  source = "./admins"
}

resource "vault_identity_group_member_entity_ids" "admins_membership" {
  member_entity_ids = [
    module.admins[*].vault_identity_entity_id
  ]

  group_id = data.vault_identity_group.admins.group_id
}


# # after you add your first developer to the platform be sure to 
# # uncomment everything below this comment to initialize the 
# # developers module

# data "vault_identity_group" "developers" {
#   group_name = "developers"
# }

# module "developers" {
#   source = "./developers"
# }

# resource "vault_identity_group_member_entity_ids" "developers_membership" {
#   member_entity_ids = [
#     module.developers[*].vault_identity_entity_id
#   ]
#   group_id = data.vault_identity_group.developers.group_id
# }