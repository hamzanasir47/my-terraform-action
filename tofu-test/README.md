# tofu-test action

This is one of a suite of OpenTofu related actions - find them at [dflook/terraform-github-actions](https://github.com/dflook/terraform-github-actions).

Execute automated tests on an OpenTofu module using the built-in `tofu test` command.
If the tests fail, the job will stop with a failure status.

## Inputs

* `path`

  Path to the OpenTofu module under test

  - Type: string
  - Optional
  - Default: The action workspace

* `test_directory`

  The directory within the module path that contains the test files.

  ```yaml
  with:
    test_directory: tf_tests
  ```

  - Type: string
  - Optional
  - Default: `tests`

* `test_filter`

  The test files to run, one per line.
  
  If not specified, all test files in the `test_directory` will be run.
  The are paths relative to the module path.

  ```yaml
  with:
    test_filter: |
      tests/main.tftest.hcl
      tests/other.tftest.hcl
  ```

  - Type: string
  - Optional
  - Default: All test files in the `test_directory`

* `variables`

  Variables to set for the tests. This should be valid OpenTofu syntax - like a [variable definition file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files).

  ```yaml
  with:
    variables: |
      image_id = "${{ secrets.AMI_ID }}"
      availability_zone_names = [
        "us-east-1a",
        "us-west-1c",
      ]
  ```

  Variables set here override any given in `var_file`s.

  - Type: string
  - Optional

* `var_file`

  List of tfvars files to use, one per line.
  Paths should be relative to the GitHub Actions workspace
  
  ```yaml
  with:
    var_file: |
      common.tfvars
      prod.tfvars
  ```

  - Type: string
  - Optional

## Outputs

* `failure-reason`

  When the job outcome is `failure`, this output may be set. The value may be one of:

  - `no-tests` - No tests were found to run.
  - `tests-failed` - One or more tests failed.

  If the job fails for any other reason this will not be set.
  This can be used with the Actions expression syntax to conditionally run steps.

## Environment Variables

* `GITHUB_DOT_COM_TOKEN`

  This is used to specify a token for GitHub.com when the action is running on a GitHub Enterprise instance.
  This is only used for downloading OpenTofu binaries from GitHub.com.
  If this is not set, an unauthenticated request will be made to GitHub.com to download the binary, which may be rate limited.

  - Type: string
  - Optional

* `TERRAFORM_CLOUD_TOKENS`

  API tokens for cloud hosts, of the form `<host>=<token>`. Multiple tokens may be specified, one per line.
  These tokens may be used with the `remote` backend and for fetching required modules from the registry.

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
      tofu.example.com=${{ secrets.TF_REGISTRY_TOKEN }}
  ```

  - Type: string
  - Optional

* `TERRAFORM_SSH_KEY`

  A SSH private key that OpenTofu will use to fetch git/mercurial module sources.

  This should be in PEM format.

  For example:
  ```yaml
  env:
    TERRAFORM_SSH_KEY: ${{ secrets.TERRAFORM_SSH_KEY }}
  ```

  - Type: string
  - Optional

* `TERRAFORM_HTTP_CREDENTIALS`

  Credentials that will be used for fetching modules sources with `git::http://`, `git::https://`, `http://` & `https://` schemes.

  Credentials have the format `<host>=<username>:<password>`. Multiple credentials may be specified, one per line.

  Each credential is evaluated in order, and the first matching credentials are used. 

  Credentials that are used by git (`git::http://`, `git::https://`) allow a path after the hostname.
  Paths are ignored by `http://` & `https://` schemes.
  For git module sources, a credential matches if each mentioned path segment is an exact match.

  For example:
  ```yaml
  env:
    TERRAFORM_HTTP_CREDENTIALS: |
      example.com=dflook:${{ secrets.HTTPS_PASSWORD }}
      github.com/dflook/terraform-github-actions.git=dflook-actions:${{ secrets.ACTIONS_PAT }}
      github.com/dflook=dflook:${{ secrets.DFLOOK_PAT }}
      github.com=graham:${{ secrets.GITHUB_PAT }}  
  ```

  - Type: string
  - Optional

* `TERRAFORM_PRE_RUN`

  A set of commands that will be ran prior to `tofu init`. This can be used to customise the environment before running OpenTofu. 
  
  The runtime environment for these actions is subject to change in minor version releases. If using this environment variable, specify the minor version of the action to use.
  
  The runtime image is currently based on `debian:bullseye`, with the command run using `bash -xeo pipefail`.

  For example:
  ```yaml
  env:
    TERRAFORM_PRE_RUN: |
      # Install latest Azure CLI
      curl -skL https://aka.ms/InstallAzureCLIDeb | bash
      
      # Install postgres client
      apt-get install -y --no-install-recommends postgresql-client
  ```

  - Type: string
  - Optional

## Example usage

```yaml
name: "Run Tests"

on: [push]

jobs:
  test:
    name: Unlock
    runs-on: ubuntu-latest
    steps:
      - name: Checkout current branch
        uses: actions/checkout@v4

      - name: OpenTofu Tests
        uses: dflook/tofu-test@v1
        with:
          path: modules/vpc
```
