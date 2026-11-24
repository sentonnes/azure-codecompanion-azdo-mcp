# Microsoft's first-party "Azure DevOps MCP" app. Creates the service principal
# in the tenant if missing; adopts it if it already exists.
resource "azuread_service_principal" "azdo_mcp" {
  client_id    = local.azdo_mcp_app_id
  use_existing = true
}

# The client app that CodeCompanion (via mcp-remote) signs in as.
resource "azuread_application" "client" {
  display_name     = var.display_name
  description      = local.description
  notes            = local.notes
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]

  # "Allow public client flows" – no client secret needed.
  fallback_public_client_enabled = true

  public_client {
    redirect_uris = [local.redirect_uri]
  }

  required_resource_access {
    resource_app_id = local.azdo_mcp_app_id

    dynamic "resource_access" {
      for_each = var.scopes
      content {
        id   = local.scope_ids[resource_access.value]
        type = "Scope"
      }
    }
  }
}

resource "azuread_service_principal" "client" {
  client_id = azuread_application.client.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Tenant-wide admin consent ("Grant admin consent" button).
# Needs Cloud Application Administrator / Privileged Role Administrator or similar.
resource "azuread_service_principal_delegated_permission_grant" "consent" {
  count                                = length(var.scopes) > 0 ? 1 : 0
  service_principal_object_id          = azuread_service_principal.client.object_id
  resource_service_principal_object_id = azuread_service_principal.azdo_mcp.object_id
  claim_values                         = var.scopes
}
