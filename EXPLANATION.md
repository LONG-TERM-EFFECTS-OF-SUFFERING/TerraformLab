# TerraformLab — Beginner's Explanation

## What this project does in one sentence

This Terraform code tells AWS to build a tiny website on the internet that says **"Hi, I am Brandon and this is my IaC"**.

---

## Background concepts (the 30-second version)

- **AWS** is Amazon's cloud. You rent virtual computers (EC2), virtual networks (VPC), storage, etc. It's all just an API.
- **Terraform** is a tool that reads `.tf` files describing what you *want* in the cloud, then talks to AWS and makes reality match. This is called **Infrastructure as Code (IaC)**. Instead of clicking around in the AWS web console, you write text files and commit them to git.
- **HCL** (HashiCorp Configuration Language) is the language inside `.tf` files. It has 4 main building blocks:
  - **`resource`** = "create this thing in the cloud" (a server, a network, etc.)
  - **`variable`** = an input you can change without editing the code
  - **`output`** = a value Terraform shows you after it finishes (like the website URL)
  - **`module`** = a reusable folder of `.tf` files you can call like a function

---

## The architecture being built

```text
Internet
   │
   │  (port 80, HTTP)
   ▼
┌─────────────────── VPC (private cloud network 10.10.0.0/16) ──────────────┐
│                                                                            │
│   Internet Gateway ──── Route Table ──── Public Subnet (10.10.1.0/24)     │
│                                                  │                         │
│                                                  ▼                         │
│                                          ┌──────────────┐                  │
│                                          │ EC2 instance │                  │
│                                          │  (t3.micro)  │                  │
│                                          │   Apache     │                  │
│                                          │   web page   │                  │
│                                          └──────────────┘                  │
│                                          Security Group                    │
│                                          (firewall: allow port 80)         │
└────────────────────────────────────────────────────────────────────────────┘
```

Plain English:

- A **VPC** is your own private slice of AWS's network (like a virtual datacenter).
- A **Subnet** is a range of IPs inside the VPC. "Public" means it has a route to the internet.
- An **Internet Gateway** is the door that connects the VPC to the public internet.
- A **Route Table** says "traffic going to `0.0.0.0/0` (anywhere) should exit through the internet gateway."
- A **Security Group** is a firewall attached to the server, allowing only port 80 in.
- An **EC2 instance** is a virtual machine. It boots Amazon Linux, installs Apache (`httpd`), and serves the HTML page.

---

## File-by-file walkthrough

### Root files (the "entrypoint")

#### `versions.tf`

Declares which Terraform version and which AWS provider plugin to use. The `provider "aws"` block tells Terraform "use AWS, in this region." Think of providers as plugins that know how to talk to a specific cloud.

#### `variables.tf`

Defines all the *inputs* you can tweak: `name_prefix`, `person_name`, `aws_region`, network CIDRs, instance type, etc. Each has a `default`, so they're optional. Changing `name_prefix` changes the name and tags of every resource — that's how you can deploy a second copy without conflict.

#### `main.tf`

The orchestrator. Three things happen here:

1. **`locals` block**: builds a tag map combining user tags + project metadata. Tags are AWS labels you attach to resources for billing/organization.
2. **`data` blocks**: these don't *create* anything — they *look up* existing AWS info.
   - `aws_availability_zones` finds AZs (datacenters) in the region.
   - `aws_ami` finds the latest Amazon Linux 2023 image to boot the server from. An AMI is basically a server template.
3. **`module` blocks**: calls the two child modules (`network` and `webserver`) and wires them together. For example: `subnet_id = module.network.public_subnet_id` — the webserver module receives the subnet ID that the network module created. That's how modules connect.

#### `outputs.tf`

After `terraform apply` finishes, it prints these values: the server's public IP, a clickable `http://...` URL, and the VPC ID.

#### `terraform.tfvars.example`

A template for local testing. If you copy it to `terraform.tfvars`, Terraform auto-loads those values. The real workshop deploy uses Terraform Cloud variables instead (see README).

---

### `modules/network/` — builds the network plumbing

#### `modules/network/main.tf`

Creates **7 AWS resources** in order:

1. **`aws_vpc.main`**: the private network with CIDR `10.10.0.0/16` (~65k IPs). DNS support enabled so instances get hostnames.
2. **`aws_internet_gateway.main`**: the door to the internet, attached to the VPC.
3. **`aws_subnet.public`**: a `10.10.1.0/24` slice (256 IPs). `map_public_ip_on_launch = true` means any EC2 instance launched here automatically gets a public IP.
4. **`aws_route_table.public`**: an empty routing table, attached to the VPC.
5. **`aws_route.internet`**: adds the rule "send traffic to anywhere (`0.0.0.0/0`) through the internet gateway."
6. **`aws_route_table_association.public`**: attaches that route table to the subnet, making it truly "public."
7. **`aws_security_group.web` + ingress/egress rules**: the firewall. Allows inbound TCP 80 from `var.allowed_http_cidr` (default `0.0.0.0/0` = anyone), and all outbound traffic.

Notice the pattern `aws_vpc.main.id` — that's how one resource references another. Terraform builds a dependency graph from these references and creates things in the correct order automatically.

#### `modules/network/variables.tf` and `modules/network/outputs.tf`

Inputs and outputs of the module. The root `main.tf` passes values *in* via variables and reads values *out* via outputs (`vpc_id`, `public_subnet_id`, `web_security_group_id`).

---

### `modules/webserver/` — builds the actual server

#### `modules/webserver/main.tf`

A single `aws_instance.web` resource. The interesting part is `user_data`: a bash script AWS runs **once** on first boot. It:

1. Installs Apache (`dnf install -y httpd`).
2. Enables and starts the web server (`systemctl enable --now httpd`).
3. Writes an HTML file at `/var/www/html/index.html` with your name interpolated via `${var.person_name}`.

`user_data_replace_on_change = true` means: if you ever edit that script, Terraform will destroy and recreate the instance instead of trying (and failing) to update it in place.

#### `modules/webserver/variables.tf` and `modules/webserver/outputs.tf`

Inputs (AMI, instance type, subnet, security group, etc.) and one output: the `public_ip`, which bubbles up to the root `outputs.tf` as `website_url`.

---

## The lifecycle when you run Terraform

1. **`terraform init`** — downloads the AWS provider plugin into `.terraform/`.
2. **`terraform plan`** — reads your `.tf` files, queries AWS for current state, prints a diff: "I will create 10 resources."
3. **`terraform apply`** — actually calls AWS APIs to create everything in the right order. Saves the results in a **state file** (`terraform.tfstate`) so it knows what it owns.
4. **`terraform destroy`** — deletes everything it created. Important here so you don't keep paying AWS.

In this project the apply happens in **HCP Terraform / Terraform Cloud** (a managed service), not on your laptop. That's why the README only suggests `fmt`, `init`, and `validate` locally.

---

## Mental model to keep

- **Root `main.tf`** = "what to build, at a high level" — calls modules.
- **Modules** = reusable Lego bricks (network, webserver). Each module has its own `main.tf` (resources), `variables.tf` (inputs), `outputs.tf` (outputs).
- **Variables** flow *down* into modules; **outputs** flow *up* out of them.
- **Resources** map 1:1 to real things in AWS that cost money or hold state.
- **Data sources** just *read* from AWS without creating anything.
