---
name: terraform
description: Write, refactor, review and validate the Terraform (azuread provider) in this repo, which manages an Entra ID app registration for the Azure DevOps MCP Server. Use for any change to files in src/ or questions about plan output.
---

# Terraform skill

## When to use

- Adding or changing resources, variables, outputs or locals in `src/`.
- Changing requested Azure DevOps MCP scopes or the redirect URI.
- Reviewing `terraform plan` output a user pastes in.
- Upgrading Terraform or the `azuread` provider.

## Workflow

1. **Understand.** Read `AGENTS.md` and the relevant files in `src/`. Check the
   resource docs for the pinned provider major (`hashicorp/azuread ~> 3.0`).
2. **Edit.** Make the smallest change that works and follow the conventions below.
3. **Format:** `terraform fmt -recursive` (from `src/`).
4. **Validate:** `terraform init -backend=false -input=false`, then `terraform validate`.
5. **Document.** Update the `README.md` tables, `terraform.tfvars.example`, and
   `AGENTS.md` if the layout changed.
6. **Hand over.** Tell the user to run `terraform plan -out tfplan` and review it.
   Never run `plan` with real credentials, `apply` or `destroy` yourself.

## Conventions

| Topic | Rule |
| --- | --- |
| File layout | `versions.tf`, `providers.tf`, `data.tf`, `locals.tf`, `main.tf`, `variables.tf`, `outputs.tf` |
| Naming | `snake_case`. Name by role (`client`, `azdo_mcp`), not by type |
| Variables | Always `description` and `type`. `validation` for ranges or formats. Optional values default to `null` or `[]` |
| Outputs | Always `description`. `sensitive = true` for anything secret |
| Providers | `~> major.minor` constraint. Commit `.terraform.lock.hcl` |
| State | Local, git-ignored. Don't add a backend unless asked |
| Refactors | Renaming or moving resources requires a `moved {}` block |
| Count/for_each | Prefer `for_each` over keyed collections. `count` only for 0/1 toggles |

## Entra ID / azuread guidance

- **Public client only.** Keep `fallback_public_client_enabled = true` and the
  `public_client` redirect URIs. Never add `password`/`azuread_application_password`
  or certificates.
- **Delegated permissions only.** `resource_access.type` must be `"Scope"`, never
  `"Role"`.
- **Least privilege.** Use read scopes unless write is truly needed. Explain any
  scope you add.
- **Scope IDs** come from `azuread_service_principal.azdo_mcp.oauth2_permission_scope_ids`,
  never hard-coded GUIDs.
- **Admin consent** (`azuread_service_principal_delegated_permission_grant`) needs
  Cloud Application Administrator or a higher role. Plans may fail for users without it.
- **`use_existing = true`** on the Azure DevOps MCP service principal lets Terraform use
  it if it already exists in the tenant. Don't remove it.
- **Replacement risk.** Changing `azuread_application.client` in a way that replaces it
  gives it a new client ID. Every client then needs the new `AZDO_MCP_CLIENT_ID`.
  Point this out.
- The redirect URI port must match the MCP client's callback port.

## Reviewing a plan

Look for and report:

- Any `-/+` (replace) or `-` (destroy) on `azuread_application.client` or its
  service principal.
- Changes to `claim_values` on the consent grant, which change scopes for every user
  in the tenant.
- Unexpected changes to `owners`. These happen if a different identity runs Terraform.

## Don'ts

- Don't run `apply`, `destroy`, `import`, `state`, `taint` or `force-unlock`.
- Don't read, print or commit `terraform.tfvars`, state or plan files.
- Don't add CI, linters, pre-commit or modules unless the user asks.
