# azure-codecompanion-azdo-mcp

Terraform that creates the **Microsoft Entra ID app registration** that lets
[CodeCompanion](https://github.com/olimorris/codecompanion.nvim) in Neovim talk to the
**remote Azure DevOps MCP Server** (`https://mcp.dev.azure.com/<organization>`) through
[`mcp-remote`](https://www.npmjs.com/package/mcp-remote).

## How it fits together

```text
Neovim / CodeCompanion
        │  (stdio)
        ▼
   mcp-remote  ── OAuth (auth code + PKCE, public client) ──►  Entra ID
        │          redirect: http://localhost:<callback_port>/oauth/callback
        ▼
Azure DevOps remote MCP Server  (resource app: "Azure DevOps MCP")
```

What gets created:

| Resource | Purpose |
| --- | --- |
| `azuread_service_principal.azdo_mcp` | Service principal for Microsoft's first-party **Azure DevOps MCP** app (`2a72489c-aab2-4b65-b93a-a91edccf33b8`). If it already exists in the tenant, Terraform uses it instead of creating a new one. |
| `azuread_application.client` | Single-tenant **public client** app (no secret) with a localhost redirect URI, requesting the delegated scopes in `var.scopes`. |
| `azuread_service_principal.client` | Enterprise application for the client app. |
| `azuread_service_principal_delegated_permission_grant.consent` | Tenant-wide admin consent for the chosen scopes. Only created when `scopes` is not empty. |

The app only uses **delegated** permissions, so it acts as the signed-in user and never
has more access than that user does.

## Prerequisites

- Terraform `>= 1.5`
- Azure CLI, signed in to the right tenant: `az login --tenant <tenant-id>`
- An Entra role that can create app registrations **and** grant admin consent
  (e.g. *Cloud Application Administrator* or *Privileged Role Administrator*).

## Usage

All commands run from `src/`.

```powershell
cd src
Copy-Item terraform.tfvars.example terraform.tfvars   # then edit values
terraform init
```

### 1. First apply: find the available scopes

Keep `scopes = []` on the first apply. This creates the app with no permissions and
shows you which scopes the Azure DevOps MCP app offers:

```powershell
terraform plan -out tfplan
terraform apply tfplan
terraform output available_scopes
```

### 2. Second apply: request scopes and grant consent

Copy the scopes you need into `scopes` in `terraform.tfvars`. Only add what you need,
and prefer read-only scopes unless you really need write access. Then plan and apply again.

### 3. Configure the client

```powershell
setx AZDO_MCP_CLIENT_ID (terraform output -raw client_id)
```

Make sure the callback port in your Neovim/CodeCompanion MCP config matches
`callback_port` (default `3334`).

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `tenant_id` | Entra tenant backing the Azure DevOps organization. | – (required) |
| `organization` | Azure DevOps organization name. | – (required) |
| `owner` | Owner contact recorded in the app's notes. | – (required) |
| `projects` | Projects the client is used with (documentation only). | `[]` |
| `display_name` | App registration display name. | `Neovim CodeCompanion - Azure DevOps MCP` |
| `description` | App description. `null` = generated automatically. | `null` |
| `notes` | App management notes. `null` = generated automatically. | `null` |
| `callback_port` | Localhost OAuth callback port used by mcp-remote. | `3334` |
| `scopes` | Delegated scopes to request and consent. | `[]` |

## Outputs

| Name | Description |
| --- | --- |
| `client_id` | Client ID to give to mcp-remote (`AZDO_MCP_CLIENT_ID`). |
| `available_scopes` | Scopes the Azure DevOps MCP app offers. |
| `redirect_uri` | The registered redirect URI. |

## State and secrets

- State is kept **locally** in `src/terraform.tfstate`, and git ignores it. Keep it
  safe: if you lose it, Terraform no longer knows it manages these objects.
- `terraform.tfvars` holds tenant and personal details, and git ignores it. Only
  `terraform.tfvars.example` is committed.
- No client secrets are created. The app is a public client.

## Removing everything

```powershell
cd src
terraform destroy
```

This removes the client app, its service principal and the consent grant. It also
removes the Azure DevOps MCP service principal *if this configuration created it*.

## Repository layout

```text
.github/
  copilot-instructions.md            # GitHub Copilot repo instructions
  instructions/terraform.instructions.md
  skills/terraform/SKILL.md          # Terraform skill for AI agents
docs/                                # Extra documentation
src/                                 # Terraform root module
AGENTS.md                            # Instructions for AI coding agents
```
