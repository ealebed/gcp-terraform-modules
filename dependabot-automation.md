# Dependabot automation

Minor and patch Dependabot pull requests are approved and squash-merged by the `automerger` GitHub App after required CI passes. Major and non-semver updates stay open for manual review.

See [ADR-001](decisions/001-dependabot-auto-merge.md) for why a GitHub App is used and why code-owner reviews are **not** a merge gate.

## How it works

```mermaid
sequenceDiagram
  participant Dependabot
  participant Actions as GitHubActions
  participant App as AutomergerApp
  participant GH as GitHubMergeGate

  Dependabot->>GH: Open minor or patch PR with no-release label
  GH->>Actions: pull_request event
  Actions->>Actions: Detect pull request context
  Actions->>Actions: Dependabot auto-merge workflow
  Actions->>Actions: fetch-metadata update-type
  alt semver-minor or semver-patch
    Actions->>App: Mint installation token
    Actions->>GH: gh pr review --approve
    Actions->>GH: gh pr merge --auto --squash
    GH->>GH: Wait for required checks
    GH->>GH: Squash merge to master
  else major or unknown
    Actions->>Actions: Skip approve and merge
  end
```

What gets auto-merged:

- `version-update:semver-minor`
- `version-update:semver-patch`

What stays manual:

- `version-update:semver-major`
- `version-update:semver-unknown`
- Any PR not authored by `dependabot[bot]`

`--auto` does **not** wait inside the job. GitHub merges later, only if branch protection is satisfied. If required status checks are missing, GitHub can squash-merge as soon as the App approves.

## Repository files

- [`.github/workflows/dependabot-auto-merge.yml`](../.github/workflows/dependabot-auto-merge.yml) — approve + enable squash auto-merge
- [`.github/dependabot.yml`](../.github/dependabot.yml) — terraform (weekly) and github-actions (daily); labels `no-release` and `dependencies`
- [`.github/CODEOWNERS`](../.github/CODEOWNERS) — review requests to `@ealebed` (not a merge requirement)

The auto-merge workflow never checks out the pull request branch.

CI ([`ci-test-and-prepare-release.yaml`](../.github/workflows/ci-test-and-prepare-release.yaml)) still requires **exactly one** of `major` / `minor` / `patch` / `no-release` on **human** PRs. Dependabot always keeps `no-release` from `dependabot.yml`, but GitHub also applies `major` / `minor` / `patch` when those labels already exist (they do — module releases use them). Detect therefore treats Dependabot + `no-release` as `no-release` and ignores the extra semver labels. Human PRs are unchanged. `dependencies` is extra and does not count as a release type.

## GitHub App

App: `automerger` (user-owned). Webhook disabled. Installed on selected repositories.

Repository permissions:

- **Contents**: Read and write (merge)
- **Pull requests**: Read and write (approve, enable auto-merge)
- **Metadata**: Read-only (required)

The workflow mints a short-lived installation token with [`actions/create-github-app-token@v3`](https://github.com/actions/create-github-app-token) using **Client ID** + private key PEM. Do not use an OAuth client secret.

These secrets are **not** `TF_MODULES_APP_ID` / `TF_MODULES_APP_PRIVATE_KEY` (those are for module validate, wiki, and release dispatch).

[Making authenticated API requests with a GitHub App in a workflow](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/making-authenticated-api-requests-with-a-github-app-in-a-github-actions-workflow)

## Secrets

Dependabot-triggered `pull_request` jobs only see **Dependabot** secrets, not Actions secrets or variables. Store the **same names** in both stores:

```mermaid
flowchart LR
  subgraph stores [Secret stores]
    ActionsSecrets[Actions secrets]
    DependabotSecrets[Dependabot secrets]
  end
  subgraph names [Identical names]
    ClientId[APP_CLIENT_ID]
    PrivateKey[APP_PRIVATE_KEY]
  end
  ActionsSecrets --> ClientId
  ActionsSecrets --> PrivateKey
  DependabotSecrets --> ClientId
  DependabotSecrets --> PrivateKey
  ClientId --> Workflow[dependabot-auto-merge.yml]
  PrivateKey --> Workflow
```

| Name | Store | Value |
| --- | --- | --- |
| `APP_CLIENT_ID` | Actions **and** Dependabot secrets | GitHub App Client ID (`Iv1…` / `Iv23…`) |
| `APP_PRIVATE_KEY` | Actions **and** Dependabot secrets | Full PEM, including BEGIN/END lines |

If a Dependabot run fails with an empty Client ID or private key, the values were added only under Actions secrets.

## Branch protection (`master`)

Required so auto-merge cannot skip CI:

- Require a pull request before merging
- Required approving reviews: **1**
- **Do not** require review from Code Owners
- Dismiss stale reviews when new commits are pushed (the workflow re-approves on `synchronize`)
- Require status checks to pass before merging
- Required check that always runs: `CI checks` (from [CI/test and prepare release](../.github/workflows/ci-test-and-prepare-release.yaml)). It succeeds when `Detect pull request context` succeeded and `validate` / `lint` / `analysis` / `plan` are each `success` or `skipped`.
- GitHub Actions-only Dependabot PRs skip `validate` / `lint` / `analysis` / `plan` because they only touch `.github/`. `CI checks` still passes after Detect. Module PRs must get those matrix jobs green (for example `validate (google-folder) / validate`).
- Do **not** require skipped matrix names, `Dispatch release event`, or `Comment on PR`.
- You can keep `Detect pull request context` required; `CI checks` is the one that also waits for module validate/lint/analysis/plan.
- Require conversation resolution: **off**
- Allow auto-merge: **on**
- Squash merging: **on**
- No force pushes, no deletions

## Rollout order

App install, secrets, auto-merge, squash, and branch protection are already configured for this repository. After this change, add required status check **`CI checks`** on `master`.

## Verify

1. Minor or patch Dependabot PR with `no-release` (even if GitHub also added `minor`): App approval, extra semver labels removed, auto-merge queued, squash after `CI checks` is green.
2. Actions-only Dependabot PR: validate/lint/analysis/plan skip; `CI checks` still green after Detect.
3. Terraform module Dependabot PR: `CI checks` stays pending until validate/lint/analysis/plan succeed.
4. Major or `semver-unknown` Dependabot PR: workflow runs, no App approval, PR stays open.
5. Human PR: auto-merge job skipped; exactly one of `major` / `minor` / `patch` / `no-release` still required.
6. On a Dependabot-triggered run, `Create GitHub App token` can read both secrets.

After merging this change, set required status check **`CI checks`** on `master`. The same dual-label Detect failure that let [aws-terraform-modules#19](https://github.com/ealebed/aws-terraform-modules/pull/19) merge would apply here.
