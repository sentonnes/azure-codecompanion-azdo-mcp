# Identity running Terraform – used as owner of the created objects.
data "azuread_client_config" "current" {}
