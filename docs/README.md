# Documentation

Extra documentation for this repository. Start with the [root README](../README.md).

## Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `Insufficient privileges` creating the consent grant | The identity running Terraform needs *Cloud Application Administrator* or a higher role. |
| `Invalid index` on `local.scope_ids[...]` | A value in `scopes` isn't in `terraform output available_scopes`. Check spelling and case. |
| Browser sign-in ends with a redirect URI mismatch | The `callback_port` doesn't match the port mcp-remote is using. |
| Users still get a consent prompt | `scopes` was empty when you applied. Add scopes and apply again to create the grant. |
