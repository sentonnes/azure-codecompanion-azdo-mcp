---
applyTo: "**/*.tf,**/*.tfvars.example,**/.terraform.lock.hcl"
---

# Terraform file rules

- Follow `.github/skills/terraform/SKILL.md` and `AGENTS.md`.
- Put each kind of block in its own file: `versions.tf`, `providers.tf`, `data.tf`,
  `locals.tf`, `main.tf`, `variables.tf`, `outputs.tf`.
- Names use `snake_case`. Don't repeat the resource type in the name.
- Every `variable` has `description` and `type`. Add `validation` where it helps.
  Every `output` has `description`. Mark secrets as `sensitive = true`.
- Use pessimistic provider constraints (`~> X.Y`). Don't edit `.terraform.lock.hcl`
  by hand; update it with `terraform init -upgrade`.
- Use 2-space indentation and keep the code `terraform fmt` clean.
- No hard-coded tenant, organization or user values. Use variables.
  The only exception is the well-known Azure DevOps MCP app ID in `locals.tf`.
- When you add a variable, add it to `terraform.tfvars.example` and the README too.
