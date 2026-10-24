# Frontend--Backend VPC Peering with Terraform

Build and validate private connectivity between separate AWS frontend
and backend VPCs using Terraform and HCP Terraform. This lab separates
network, security, and compute resources into dedicated workspaces and
manages VPC Peering and inter-VPC routes through a dedicated workspace.

## Project objectives

-   Provision frontend and backend AWS network environments with
    Terraform.
-   Organize infrastructure using separate HCP Terraform workspaces.
-   Configure VPCs, subnets, Internet Gateways, route tables, subnet
    associations, and NAT Gateway resources.
-   Apply security groups to control workload communication.
-   Establish VPC Peering between frontend and backend VPCs.
-   Configure routes in both directions for private IP connectivity.
-   Validate connectivity using `ping`, SSH, and targeted
    troubleshooting commands.
-   Practice least-privilege security and workspace output sharing.

## Architecture overview

![Architecture-Overview](/hello-cloud/lab-08-terrafrom-lab-vpc-peering-intra/drawings/vpc-peering-architecture.png)

> The CIDR blocks above reflect the ranges shown in the lab notes.
> Confirm the deployed subnet CIDRs, route-table associations, and
> resource IDs in Terraform outputs or the AWS Console before applying
> changes.

## Terraform workspace layout

  -----------------------------------------------------------------------
  Workspace                           Responsibility
  ----------------------------------- -----------------------------------
  `fe-network-ws`                     Frontend VPC, subnets, IGW, route
                                      tables, subnet associations, NAT
                                      Gateway resources

  `fe-security-ws`                    Frontend security groups

  `fe-compute-ws`                     Frontend EC2 instances and SSH key
                                      pair

  `be-network-ws`                     Backend VPC, subnets, IGW, route
                                      tables, subnet associations, NAT
                                      Gateway resources as configured

  `be-security-ws`                    Backend security groups

  `be-compute-ws`                     Backend EC2 instances and SSH key
                                      pair

  `vpc-peering-fe-be`                 VPC Peering connection and
                                      inter-VPC routes
  -----------------------------------------------------------------------

This workspace design separates network foundations, security controls,
compute resources, and cross-VPC connectivity so each area can be
managed and reviewed independently.

## Repository structure

``` text
.
├── README.md
├── docs/
│   └── vpc-peering-lab-study-notes.md
├── terraform/
│   ├── fe-network-ws/
│   ├── fe-security-ws/
│   ├── fe-compute-ws/
│   ├── be-network-ws/
│   ├── be-security-ws/
│   ├── be-compute-ws/
│   └── vpc-peering-fe-be/
└── evidences/
```

Folder names and evidence paths may differ from your local repository;
update this tree to match the actual files committed to GitHub.

## Prerequisites

-   An AWS account with permissions appropriate to create the resources
    in this lab.
-   An HCP Terraform account and access to the required organization and
    workspaces.
-   Terraform CLI installed for local workflow operations.
-   AWS provider and Terraform configuration files in each workspace.
-   SSH client installed on your local machine.
-   Public and private SSH key material handled securely.
-   Non-overlapping VPC CIDR ranges.

## Deployment workflow

Deploy and validate each workspace in dependency order. The exact order
may depend on your existing HCP Terraform workspace configuration and
outputs.

For each workspace, initialize and validate the Terraform configuration:

``` bash
terraform login
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying. Confirm that each workspace has the
correct HCP Terraform organization, workspace configuration, variables,
and required provider credentials.

### 1. Deploy frontend networking

Use `fe-network-ws` to provision the frontend VPC, subnets, route
tables, subnet associations, Internet Gateway, and any NAT Gateway
resources configured for the lab.

### 2. Deploy frontend security

Use `fe-security-ws` to create the frontend security groups. Share the
required network outputs with this workspace.

### 3. Deploy frontend compute

Use `fe-compute-ws` to create frontend EC2 instances and the SSH key
pair. Share the required network and security outputs.

### 4. Deploy backend networking

Use `be-network-ws` to provision the backend VPC and its networking
components.

### 5. Deploy backend security

Use `be-security-ws` to create backend security groups and consume the
required network outputs.

### 6. Deploy backend compute

Use `be-compute-ws` to provision backend EC2 instances and their
associated EC2 key pair.

### 7. Deploy VPC Peering

Use `vpc-peering-fe-be` to create the peering connection and add the
routes needed for communication between the frontend and backend VPCs.
Ensure the peering connection is active and that the relevant route
tables on both sides contain the peer-VPC route.

## VPC Peering and routing

VPC Peering provides a private network path between the two VPCs. It
does not automatically configure route tables or authorize traffic.

Required checks:

1.  Confirm the VPC CIDR ranges do not overlap.
2.  Confirm the peering connection is active.
3.  Add the backend VPC CIDR route to the relevant frontend route
    tables, targeting the peering connection.
4.  Add the frontend VPC CIDR route to the relevant backend route
    tables, targeting the peering connection.
5.  Confirm each subnet is associated with the route table you intended
    to update.
6.  Confirm security groups and network ACLs allow the required traffic.
7.  Test the specific source and destination paths.

Example route design:

  -----------------------------------------------------------------------
  Route destination       Route target            Purpose
  ----------------------- ----------------------- -----------------------
  Frontend VPC CIDR       `local`                 Intra-VPC routing

  Backend VPC CIDR in     `pcx-...`               Frontend-to-backend
  frontend route tables                           routing

  Backend VPC CIDR        `local`                 Intra-VPC routing

  Frontend VPC CIDR in    `pcx-...`               Backend-to-frontend
  backend route tables                            routing
  -----------------------------------------------------------------------

VPC Peering is non-transitive. A VPC cannot use a peer VPC as a transit
path to another VPC.

## Security and least privilege

-   Restrict SSH to bastion hosts to trusted administrative IP addresses
    where practical.
-   Allow SSH to private instances from the bastion security group
    rather than from the public internet.
-   Permit only the application protocols and ports required between
    frontend and backend workloads.
-   Avoid broad inbound rules such as `0.0.0.0/0` for SSH or all
    protocols.
-   Remember that route tables determine the network path; security
    groups and network ACLs determine whether traffic is allowed.
-   A successful ping proves ICMP reachability for that path, not that
    every application port is open.
-   Do not commit AWS credentials, SSH private keys, Terraform state, or
    other sensitive files to GitHub.
-   Prefer short-lived HCP Terraform dynamic credentials / OIDC where
    supported instead of long-lived AWS access keys.
-   Treat Terraform state as sensitive. Marking an output
    `sensitive = true` hides it from normal CLI display but does not
    remove the value from state.
-   Rotate any private key whose private material has been exposed.

## Connectivity validation

The lab notes record successful and failed ICMP tests between selected
frontend and backend instances. These results demonstrate that some
paths were permitted while others were intentionally restricted by the
lab's security design. Validate the actual deployed environment before
relying on these results.

### Useful commands

``` bash
# Test ICMP reachability
ping <DESTINATION_PRIVATE_IP>

# Test whether TCP port 22 is reachable
nc -vz -w 5 <DESTINATION_PRIVATE_IP> 22

# Troubleshoot SSH connectivity and authentication
ssh -vvv -i ~/.ssh/<PRIVATE_KEY_FILE> ubuntu@<DESTINATION_PRIVATE_IP>

# Derive a public key from a private key to check whether the private key is readable
ssh-keygen -y -f ~/.ssh/<PRIVATE_KEY_FILE>
```

Use `ubuntu` for typical Ubuntu AMIs and `ec2-user` for typical Amazon
Linux AMIs. Confirm the selected AMI and username before troubleshooting
authentication.


