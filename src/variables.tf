variable "tenant_id" {
  description = "Entra tenant backing the Azure DevOps organization."
  type        = string
}

variable "organization" {
  description = "Azure DevOps organization name (the part after dev.azure.com/)."
  type        = string
}

variable "projects" {
  description = "Azure DevOps projects the client is used with (documentation only)."
  type        = list(string)
  default     = []
}

variable "owner" {
  description = "Owner contact (e.g. email) recorded in the app registration notes."
  type        = string
}

variable "display_name" {
  description = "Display name of the client app registration."
  type        = string
  default     = "Neovim CodeCompanion - Azure DevOps MCP"
}

variable "description" {
  description = "Short description on the app registration (max 1024 chars). Null = generated from organization."
  type        = string
  default     = null
}

variable "notes" {
  description = "Management notes on the app registration's Branding & properties page. Null = generated from owner/organization/projects."
  type        = string
  default     = null
}

variable "callback_port" {
  description = "Localhost port mcp-remote listens on for the OAuth callback. Must match the callback port configured in the Neovim/CodeCompanion MCP client config."
  type        = number
  default     = 3334

  validation {
    condition     = var.callback_port >= 1024 && var.callback_port <= 65535
    error_message = "callback_port must be between 1024 and 65535."
  }
}

variable "scopes" {
  description = <<-EOT
    Delegated scope values on the Azure DevOps MCP app to request + consent.
    Leave empty on the first apply, then read the `available_scopes` output
    and fill this in (least privilege – read scopes unless you need writes).
  EOT
  type        = list(string)
  default     = []
}
