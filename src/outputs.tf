output "client_id" {
  description = "Client (application) ID of the app registration. Set it for the MCP client, e.g. `setx AZDO_MCP_CLIENT_ID <value>` on Windows."
  value       = azuread_application.client.client_id
}

output "available_scopes" {
  description = "Delegated scopes exposed by the Azure DevOps MCP app – pick from these for var.scopes."
  value       = sort(keys(azuread_service_principal.azdo_mcp.oauth2_permission_scope_ids))
}

output "redirect_uri" {
  description = "Public client redirect URI registered on the app (used by mcp-remote)."
  value       = local.redirect_uri
}
