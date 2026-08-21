# terraform-oidc-demo

Minimal working example of **AWS OIDC + GitHub Actions**, no long-lived IAM keys.

Terraform provisions:
- A GitHub OIDC identity provider in AWS
- An IAM role GitHub Actions can assume, trust-scoped to one repo/branch
- A private S3 bucket for a static site
- A least-privilege policy letting the role only touch that one bucket

GitHub Actions provisions: nothing — it just assumes the role and syncs `/site` to S3 on push to `main`.

## Project layout

```
terraform/
  main.tf        # providers, backend
  variables.tf    # project_name, github_org/repo/branch, region
  oidc.tf        # OIDC provider + IAM role + trust policy + permissions
  s3.tf          # site bucket
  outputs.tf     # role ARN + bucket name for the workflow
.github/workflows/
  deploy.yml     # OIDC login + s3 sync
site/
  index.html     # what gets deployed
```

## Setup

### 1. Apply the infrastructure

```bash
cd terraform
terraform init
terraform apply \
  -var="github_org=jamilkhan-me" \
  -var="github_repo=terraform-oidc-demo" \
  -var="github_branch=main"
```

If your AWS account already has a GitHub OIDC provider from another project (you can only have one per account), add `-var="create_oidc_provider=false"` and uncomment the `data` block in `oidc.tf`.

### 2. Copy the outputs into GitHub

```bash
terraform output deploy_role_arn
terraform output site_bucket_name
```

In the repo: **Settings → Secrets and variables → Actions → New repository secret**

| Secret name           | Value                          |
|------------------------|---------------------------------|
| `AWS_DEPLOY_ROLE_ARN`  | output of `deploy_role_arn`    |
| `AWS_SITE_BUCKET`      | output of `site_bucket_name`   |

### 3. Push to `main`

The workflow runs, assumes the role via OIDC, and syncs `/site` to the bucket. No AWS access keys stored anywhere.

## How the trust actually works

1. GitHub Actions requests a short-lived OIDC token scoped to this workflow run.
2. `aws-actions/configure-aws-credentials` sends that token to AWS STS (`AssumeRoleWithWebIdentity`).
3. AWS checks the token against the role's trust policy conditions:
   - `aud` must equal `sts.amazonaws.com`
   - `sub` must match `repo:jamilkhan-me/terraform-oidc-demo:ref:refs/heads/main` (or a PR from that repo)
4. If it matches, STS returns temporary credentials, valid only for that job.

## Common gotchas

- **"Not authorized to perform sts:AssumeRoleWithWebIdentity"** — almost always a `sub` mismatch. Double-check org/repo/branch spelling and whether you need `ref:refs/heads/BRANCH` vs `pull_request`.
- **Only one OIDC provider per AWS account** — if `terraform apply` fails with "already exists", set `create_oidc_provider = false`.
- **Missing `permissions: id-token: write`** in the workflow — without it GitHub never mints the token and the credentials step fails.
- **Wildcard branches** — swap `StringLike`'s single value for a list, or use `repo:ORG/REPO:*` if you want any branch/PR to be able to assume the role (looser, use only for low-risk repos).

## Teardown

```bash
cd terraform
terraform destroy
```
