# AGENTS.md

Instructions for AI coding agents working in this repository. This is the main
guidance file. `.github/copilot-instructions.md` points here.

## What this repo is

A single Terraform root module (`src/`) that manages a Microsoft Entra ID
**public client app registration** used by Neovim/CodeCompanion (through
`mcp-remote`) to reach the remote **Azure DevOps MCP Server**. It also sets up
Microsoft's first-party "Azure DevOps MCP" service principal and grants
tenant-wide admin consent for the delegated scopes. See `README.md`.

## Layout

| Path | Contents |
| --- | --- |
| `src/versions.tf` | `terraform {}` block, version and provider constraints |
| `src/providers.tf` | Provider configuration |
| `src/data.tf` | Data sources |
| `src/locals.tf` | Local values (well-known app ID, generated text) |
| `src/main.tf` | Resources |
| `src/variables.tf` | Input variables |
| `src/outputs.tf` | Outputs |
| `src/terraform.tfvars.example` | Committed example inputs |
| `docs/` | Extra documentation |
| `.github/skills/terraform/SKILL.md` | Terraform workflow and conventions (read before editing `.tf`) |

## Commands (run from `src/`)

```powershell
terraform fmt -recursive
terraform init -backend=false     # offline, enough for validate
terraform validate
```

`terraform plan` needs Azure credentials and a real `terraform.tfvars`, so only a
human runs it.

## Hard rules

1. **Never run `terraform apply`, `destroy`, `import`, `state *` or `taint`.**
   Suggest the command; a human runs it.
2. **Never commit or print** `*.tfvars` (except `*.tfvars.example`), `*.tfstate*`,
   `.terraform/` or plan files. Don't read `src/terraform.tfvars` unless asked.
3. **State is local by design.** Don't add a remote backend unless asked.
4. **Least privilege.** Don't add scopes, application permissions (`type = "Role"`),
   client secrets or certificates. The app must stay a public client with delegated
   permissions only.
5. **Don't change `local.azdo_mcp_app_id`.** It's Microsoft's well-known client ID.
6. **Don't rename resources** without a `moved {}` block, or Terraform will destroy and
   recreate the app (which gives it a new client ID).
7. `callback_port` must match the Neovim/CodeCompanion client config. Mention this
   whenever the port or redirect URI changes.
8. Keep it minimal. Don't add CI, pre-commit, tflint or modules unless asked.

## Before finishing a change

- `terraform fmt -check -recursive` and `terraform validate` both pass.
- Every variable and output has a `description` (and variables have a `type`).
- `README.md` input and output tables match any variable or output changes.
- Point out anything that would replace or destroy existing Entra objects.
