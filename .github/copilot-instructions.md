# Copilot instructions

This repo is a small Terraform root module in `src/`. It manages an Entra ID public
client app registration that lets Neovim/CodeCompanion (through `mcp-remote`) use the
remote Azure DevOps MCP Server.

**Read [`AGENTS.md`](../AGENTS.md) first.** It is the main source of repo rules.
For any `.tf` change, follow [`skills/terraform/SKILL.md`](skills/terraform/SKILL.md).

Key points:

- Only validate (`terraform fmt`, `terraform init -backend=false`, `terraform validate`).
  Never run `apply`, `destroy`, `import` or state commands.
- Never commit or show `*.tfvars`, `*.tfstate*` or `.terraform/`.
- Delegated permissions only, no secrets, least-privilege scopes.
- Don't rename resources without a `moved {}` block.
- Keep `README.md` input and output tables in sync with `variables.tf` and `outputs.tf`.
