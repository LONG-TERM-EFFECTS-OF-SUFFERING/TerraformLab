# TerraformLab

This project deploys a simple public web server on AWS using Terraform and HCP Terraform / Terraform Cloud.

The deployed page says:

```text
Hi, I am Brandon and this is my IaC
```

## Architecture

Terraform creates:

- VPC.

- Public subnet.

- Internet gateway.

- Public route table.

- Route to the internet gateway.

- Security group allowing inbound HTTP on port 80.

- EC2 instance running Apache/httpd.

- Dynamic tags and names based on variables.

## Repository structure

```text
.
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── terraform.tfvars.example
├── modules
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── webserver
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── README.md
```

## Terraform Cloud / HCP Terraform variables

In your workspace, add these as **Environment variables**:

| Key | Value | Sensitive? |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | Your AWS access key ID | Yes |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key | Yes |
| `AWS_REGION` | `us-east-1` | No |

Then add these as **Terraform variables**:

| Key | Example value | Sensitive? | HCL? |
| --- | --- | --- | --- |
| `name_prefix` | `brandon-iac` | No | No |
| `person_name` | `Brandon` | No | No |
| `aws_region` | `us-east-1` | No | No |

Optional Terraform variables:

| Key | Default |
| --- | --- |
| `vpc_cidr` | `10.10.0.0/16` |
| `public_subnet_cidr` | `10.10.1.0/24` |
| `instance_type` | `t3.micro` |
| `allowed_http_cidr` | `0.0.0.0/0` |

## Deploy with Terraform Cloud / HCP Terraform

1. Push this repository to GitHub.

2. Create an HCP Terraform workspace.

3. Choose **Version Control Workflow**.

4. Connect the GitHub repository.

5. Add the variables listed above.

6. Start a run.

7. Review the plan.

8. Click **Confirm & Apply**.

9. Open the `website_url` output in your browser.

## Local validation commands

These commands are useful before pushing to GitHub:

```bash
terraform fmt -recursive
terraform init
terraform validate
```

For this workshop, the real apply should happen in Terraform Cloud / HCP Terraform.

## Idempotency check

After a successful apply, run another plan with no code changes.

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

That means Terraform state and real AWS infrastructure match the code.

## How to create another copy without overwriting the first

Use the same repository, but create a **new Terraform Cloud workspace** and change only this Terraform variable:

```hcl
name_prefix = "brandon-iac-v2"
```

Each workspace has its own state, so the second workspace can manage a separate copy of the infrastructure.

## Destroy after the workshop

To avoid AWS charges, destroy the infrastructure from Terraform Cloud after grading.
