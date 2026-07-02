# terraform-modules
Reusable Terraform Modules for GCP

## Pre-commit hooks
Git [pre-commit](https://pre-commit.com/) hooks are scripts that run automatically before a commit is finalized. They are used to enforce code quality, style, or other checks before changes are saved to the repository.

### Installation and usage
1) Install pre-commit Python package:
```bash
pip install pre-commit
```

or
```bash
brew install pre-commit
```

2) In the root of Git repository, create a file named `.pre-commit-config.yaml` (already created).
3) Define your hooks in the YAML file.
4) Install the hooks:
```bash
pre-commit install
```
This command will set up the necessary Git hook scripts in `.git/hooks` to run the hooks defined in your `.pre-commit-config.yaml`
5) Manually run hooks
```bash
pre-commit run --all-files
```
6) Depending on hooks configured, you might need to install additional packages/dependencies, e.g.:
```bash
brew install terraform-docs tflint tfsec infracost tfupdate jq
```
More details [here](https://github.com/antonbabenko/pre-commit-terraform?tab=readme-ov-file#1-install-dependencies)

## Repository configuration
- Labels `major`, `minor`, `patch` and `no-release` have to be created manually (from GitHub UI).
- Wiki have to be initialized (create first commit from GitHub UI) manually.
