# terraform-remote-state action

This is one of a suite of Terraform related actions - find them at [dflook/terraform-github-actions](https://github.com/dflook/terraform-github-actions).

Retrieves the root-level outputs from a Terraform remote state.

## Inputs

* `backend_type`

  The name of the Terraform plugin used for backend state

  - Type: string
  - Required

* `workspace`

  Terraform workspace to get the outputs for

  - Type: string
  - Optional
  - Default: `default`

* `backend_config`

  List of Terraform backend config values, one per line.

  ```yaml
  with:
    backend_config: token=${{ secrets.BACKEND_TOKEN }}
  ```

  - Type: string
  - Optional

* `backend_config_file`

  List of Terraform backend config files to use, one per line.
  Paths should be relative to the GitHub Actions workspace

  ```yaml
  with:
    backend_config_file: prod.backend.tfvars
  ```

  - Type: string
  - Optional

## Environment Variables

* `GITHUB_DOT_COM_TOKEN`

  This is used to specify a token for GitHub.com when the action is running on a GitHub Enterprise instance.
  This is only used for downloading OpenTofu binaries from GitHub.com.
  If this is not set, an unauthenticated request will be made to GitHub.com to download the binary, which may be rate limited.

  - Type: string
  - Optional

* `TERRAFORM_CLOUD_TOKENS`

  API tokens for cloud hosts, of the form `<host>=<token>`. Multiple tokens may be specified, one per line.
  These tokens may be used with the `remote` backend.

  e.g:
  ```yaml
  env:
    TERRAFORM_CLOUD_TOKENS: app.terraform.io=${{ secrets.TF_CLOUD_TOKEN }}
  ```

  With other registries:
  ```yaml
  env:
    TERRAFORM_CLOUD_TOKENS: |
      app.terraform.io=${{ secrets.TF_CLOUD_TOKEN }}
      terraform.example.com=${{ secrets.TF_REGISTRY_TOKEN }}
  ```

  - Type: string
  - Optional

## Outputs

An output will be created for each root-level output in the Terraform remote state.

For example, with a remote state that has an output created using:
```hcl
output "service_hostname" {
  value = "example.com"
}
```
Running this action will produce a `service_hostname` output with the same value.
See [terraform-output](https://github.com/dflook/terraform-github-actions/tree/main/terraform-output) for details.

## Example usage

This example sends a request to a url that has previously been provisioned by Terraform, by fetching the url from the remote state in S3.

```yaml
name: Send request

on:
  push:
    branches:
      - main

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

jobs:
  get_remote_state:
    runs-on: ubuntu-latest
    name: Run Test
    steps:
      - name: Get remote state
        uses: dflook/terraform-remote-state@v1
        id: remote-state
        with:
          backend_type: s3
          backend_config: |
            bucket=terraform-github-actions
            key=terraform-remote-state
            region=eu-west-2

      - name: Send request
        run: |
          curl "${{ steps.remote-state.outputs.url }}"
```
