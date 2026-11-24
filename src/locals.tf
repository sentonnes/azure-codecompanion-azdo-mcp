locals {
  # Well-known client ID of Microsoft's first-party "Azure DevOps MCP" application.
  azdo_mcp_app_id = "2a72489c-aab2-4b65-b93a-a91edccf33b8"

  # Map of delegated scope value => scope ID exposed by the Azure DevOps MCP app.
  scope_ids = azuread_service_principal.azdo_mcp.oauth2_permission_scope_ids

  redirect_uri = "http://localhost:${var.callback_port}/oauth/callback"

  project_text = length(var.projects) > 0 ? " in ${join(", ", var.projects)}" : ""

  description = coalesce(
    var.description,
    "Public client used by Neovim CodeCompanion (via mcp-remote) to access the remote Azure DevOps MCP Server for the ${var.organization} organization."
  )

  notes = coalesce(var.notes, <<-EOT
    Owner: ${var.owner}
    Purpose: Personal developer tooling - lets Neovim/CodeCompanion use the Azure DevOps
    remote MCP Server (https://mcp.dev.azure.com/${var.organization}) to read/comment on work items,
    list and trigger pipelines, and read/write wiki pages${local.project_text}.
    Access: Delegated permissions only; acts as the signed-in user, no client secret.
  EOT
  )
}
