

## Step 1 — Root module: versions.tf

| Setting | Purpose |
|---|---|
| `required_version` | Allows Terraform 1.6 or newer within version 1.x. |
| `source` | Uses HashiCorp’s official AWS provider. |
| `version = "~> 6.0"` | Allows AWS provider versions 6.x while excluding 7.x. |


Reference documents:
[- Terraform block](https://developer.hashicorp.com/terraform/language/block/terraform?utm_source=chatgpt.com)
[- Provider requirements](https://developer.hashicorp.com/terraform/language/providers/requirements?utm_source=chatgpt.com)


# Step 2 — Configure AWS Regions: providers.tf

I configure Singapore as the default AWS provider and use provider aliases for London and Northern California. 
Aliases let the same root module manage resources in multiple Regions. 

Create main.tf inside ~/lab-07-route53-geolocation-roiuting-policy:

Reference documents:
[- Provider configuration and aliases](https://developer.hashicorp.com/terraform/language/block/provider?utm_source=chatgpt.com)
[- AWS provider: authentication, Regions, and default tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

# Step 3 — Create the VPCs: vpc.tf

Create vpc.tf alongside main.tf and providers.tf:
Each VPC uses the CIDR from the supplied design.
| Argument | Purpose |
|---|---|
| `provider` | Selects the regional AWS provider. |
| `cidr_block` | Defines the VPC’s IPv4 address range. |
| `enable_dns_support` | Enables DNS resolution through the Amazon-provided DNS server. |
| `enable_dns_hostnames` | Enables VPC DNS hostname support. |
| `tags.Name` | Sets the display name in the AWS console. |

The VPCs also inherit Project and ManagedBy from their provider’s default_tags. Terraform Registry
Check the configuration:

terraform plan previews the changes. We can apply after completing the configuration.
Reference: [Terraform AWS provider — aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc?utm_source=chatgpt.com)


# Step 4 — Create the subnets: subnets.tf
I create four subnets per VPC: two public subnets for the ALB and NAT gateway, and two private subnets for the web servers.


How the configuration works

A| Argument | Purpose |
|---|---|
| `vpc_id` | References the regional VPC created in `vpc.tf`. |
| `cidr_block` | Assigns a non-overlapping `/24` address range within that VPC. |
| `availability_zone` | Places the subnet in the specified AZ. |
| `map_public_ip_on_launch = false` | Disables automatic public IPv4 assignment to instances launched in the subnet. |

A subnet becomes public through its route to an Internet Gateway. 

The VPC references, such as aws_vpc.singapore.id, automatically establish creation dependencies.

Reference: [Terraform AWS provider — aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

# Step 5 — Create Internet Gateways: internet-gateways.tf
I create and attach one Internet Gateway to each regional VPC.

The vpc_id argument attaches each gateway to its VPC. 

| Resource reference | Attached VPC |
|---|---|
| `aws_internet_gateway.singapore` | `aws_vpc.singapore` |
| `aws_internet_gateway.london` | `aws_vpc.london` |
| `aws_internet_gateway.california` | `aws_vpc.california` |


Each gateway inherits the provider’s Project = "lab-07-route53-geolocation" and ManagedBy = "Terraform" tags.

Attaching an Internet Gateway alone does not enable internet access for the subnets. Next, I will configure the public route tables with 0.0.0.0/0 pointing to these gateways.


Reference: [Terraform AWS provider — aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway?utm_source=chatgpt.com)

# Step 6 — Public route tables: public-route-tables.tf

I create one public route table per VPC.
 Each table routes internet-bound IPv4 traffic to its regional Internet Gateway and serves both public subnets.


| Resource | Purpose |
|---|---|
| `aws_route_table` | Creates the regional public route table. |
| `aws_route` | Adds `0.0.0.0/0 → Internet Gateway`. |
| `aws_route_table_association` | Assigns each public subnet to that table. |


AWS automatically provides the VPC’s local route. 
Traffic within the VPC follows that more-specific route; 
other IPv4 destinations follow 0.0.0.0/0.
Both public subnets share one route table. The private subnets will receive separate routing configuration later.

Reference documents:
[- aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
[- aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route?utm_source=chatgpt.com)
[- aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

# Step 7 — NAT gateways: `nat-gateways.tf`

I create **one public NAT gateway and one Elastic IP per Region**. 
Each gateway goes in public subnet 1. 
Later, both private subnets will route outbound internet traffic through it.

This keeps the lab smaller, but outbound connectivity depends on that gateway’s AZ. A setup requiring resilient outbound access would use one gateway per AZ


**How it works**

| Argument | Purpose |
|---|---|
| `domain = "vpc"` | Allocates an Elastic IP for use with VPC resources. |
| `allocation_id` | Assigns the Elastic IP to the NAT gateway. |
| `subnet_id` | Places the gateway in the selected public subnet. |
| `connectivity_type = "public"` | Creates a public NAT gateway for internet-bound traffic. |
| `depends_on` | Waits for the Internet Gateway, public route, and subnet association. |

The Elastic IP and subnet references already establish their dependencies. 
The explicit `depends_on` covers the public routing configuration, which is not directly referenced by the NAT gateway’s arguments. 

The private instances will initiate outbound connections through NAT while retaining private IP addresses. **Creating these gateways alone does not enable private-subnet internet access**—the private route tables come next.

NAT gateways and their public IPv4 addresses incur charges after creation, so include them in the final cleanup.

**Reference documents:**

- [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
- [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)

# Step 8 — Private route tables: `private-route-tables.tf`

I create one private route table per Region and associate both private subnets with it. Each table sends outbound internet traffic to its regional NAT gateway.
**How the routes work**

Each table contains an automatically created local route and the default route configured above:

| Region | Local route | Default route |
|---|---|---|
| Singapore | `10.10.0.0/16 → local` | `0.0.0.0/0 → sg-nat-1` |
| London | `172.16.0.0/16 → local` | `0.0.0.0/0 → lon-nat-1` |
| Northern California | `192.168.0.0/16 → local` | `0.0.0.0/0 → sfo-nat-1` |

Use **`nat_gateway_id`** for a NAT gateway target. Our public routes used **`gateway_id`** for an Internet Gateway target.

For example, when a Singapore private instance downloads a package, its outbound path is:

**Private instance → private route table → NAT gateway → public route table → Internet Gateway → internet**

Traffic between the ALB and private instances stays within the VPC using the local route; it does not pass through NAT.

The resource references automatically establish the creation dependencies. No additional `depends_on` is needed in this file.

**Reference documents:**

- [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
- [aws_route — including nat_gateway_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)
- [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

# Step 9 — Security groups: `security-groups.tf`
I create two security groups per Region with these rules:

| Group | Direction | Traffic | Source / destination |
|---|---|---|---|
| ALB | Inbound | TCP 80 | `0.0.0.0/0` |
| ALB | Inbound | TCP 443 | `0.0.0.0/0` |
| ALB | Outbound | TCP 80 | Regional web security group |
| Web servers | Inbound | TCP 80 | Regional ALB security group |
| Web servers | Outbound | All traffic | `0.0.0.0/0` |

Port 80 on the ALB will support HTTP-to-HTTPS redirects. The private web servers accept HTTP only from the ALB. I use Session Manager for administration, so no SSH inbound rule is needed.

**How the arguments work**

| Argument | Meaning |
|---|---|
| `security_group_id` | The group whose rules I am configuring. |
| `cidr_ipv4` | Allowed source range for ingress, or destination range for egress. |
| `referenced_security_group_id` | Allowed source group for ingress, or destination group for egress. |
| `ip_protocol = "tcp"` | Allows TCP within the specified port range. |
| `ip_protocol = "-1"` | Allows all protocols and ports; omit `from_port` and `to_port`. |

For example, `singapore_web_from_alb` adds a rule **to the web group**, allowing HTTP **from the ALB group**. [Terraform Registry](https://registry.terraform.io/providers/-/aws/5.39.1/docs/resources/vpc_security_group_ingress_rule?utm_source=chatgpt.com)

Terraform removes AWS’s initial allow-all outbound rule when creating a security group, so I explicitly define the required outbound rules. I keep all rules in standalone resources and do not mix them with inline `ingress` or `egress` blocks. [Terraform Registry](https://registry.terraform.io/providers/-/aws/latest/docs/resources/security_group?utm_source=chatgpt.com)

Security groups are stateful: response traffic for allowed connections does not require separate return-traffic rules. The web servers’ outbound rule supports connections they initiate through NAT.

**Reference documents:**

- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [aws_vpc_security_group_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)
- [aws_vpc_security_group_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)

# Step 10 — EC2 management role: `iam.tf`

I create one IAM role and instance profile for all six web servers. IAM is global within the AWS account, so I reuse them across all three Regions.

Create **`iam.tf`**:


**How it works**

| Configuration | Purpose |
|---|---|
| `assume_role_policy` | Trust policy allowing the EC2 service to assume this role. |
| `jsonencode()` | Converts the Terraform object into valid JSON policy text. |
| `AmazonSSMManagedInstanceCore` | Grants the instance permissions needed for core Systems Manager functionality, including Session Manager. |
| Instance profile | Passes the role to an EC2 instance. |
| `depends_on` | Ensures the policy attachment completes before Terraform creates the instance profile. |

The instance profile supplies the instance-side permissions for Session Manager. Your own AWS identity also needs permission to start sessions. [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html?utm_source=chatgpt.com)

When I configure EC2, I will attach:

```hcl
iam_instance_profile = aws_iam_instance_profile.web_server.name
```

Session Manager also requires a running SSM Agent and outbound HTTPS connectivity, which our NAT routing supports. This role is for administration; HTTPS certificates and web-server TLS configuration come separately.

**Reference documents:**

- [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)
- [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)
- [AWS — Session Manager instance permissions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html)

# Step 11 — Regional AMI lookup: `data.tf`

I use a **data source** to find an Amazon Linux 2023 image in each Region. A data source reads existing information; it does not create an AMI.

**How the lookup works**

| Setting | Purpose |
|---|---|
| `provider` | Searches the specified AWS Region. |
| `most_recent = true` | Selects the newest image matching all filters. |
| `owners = ["amazon"]` | Restricts the search to Amazon-owned images. |
| Name pattern | Matches standard Amazon Linux 2023 x86_64 images. |
| `architecture` | Matches the x86_64 instance type we will use. |
| `virtualization-type` | Selects HVM virtualization. |
| `root-device-type` | Selects an EBS-backed image. |
| `state` | Selects an available image. |

The owner restriction prevents similarly named third-party images from entering the selection. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami.html?utm_source=chatgpt.com)

The name pattern follows AWS’s AL2023 naming format. The kernel wildcard allows different kernel versions; this lookup does not pin a specific kernel. [Amazon Linux 2023](https://docs.aws.amazon.com/linux/al2023/ug/naming-and-versioning.html?utm_source=chatgpt.com)

Later, the EC2 resources will reference:

| Region | AMI reference |
|---|---|
| Singapore | `data.aws_ami.sg.id` |
| London | `data.aws_ami.lon.id` |
| Northern California | `data.aws_ami.nca.id` |


During planning, Terraform reads the three regional AMIs. These data sources add **no managed resources**.

Because `most_recent` can select a newer image in a future plan, review any proposed EC2 replacements. For repeatable releases, pin the tested regional AMI IDs.

**Reference documents:**

- [Terraform AWS provider — aws_ami data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)
- [AWS — Amazon Linux 2023 naming and versioning](https://docs.aws.amazon.com/linux/al2023/ug/naming-and-versioning.html)
- [Terraform — Data sources](https://developer.hashicorp.com/terraform/language/data-sources)


# Step 12 — Create the root CA locally

I create a root CA on my Ubuntu PC to sign the ALB and EC2 server certificates.

**1. Prepare a directory outside the GitHub repository**

**2. Generate the root CA private key**

**3. Create the self-signed root CA certificate**


| Setting | Purpose |
|---|---|
| `-x509` | Creates a self-signed certificate. |
| `-days 3650` | Sets validity to approximately 10 years. |
| `CA:TRUE` | Identifies this certificate as a CA. |
| `pathlen:0` | Allows direct server certificates without subordinate intermediate CAs. |
| `keyCertSign` | Allows the CA key to sign certificates. |

These certificate extensions define the CA’s permitted role. [OpenSSL Documentation](https://docs.openssl.org/3.6/man5/x509v3_config/?utm_source=chatgpt.com)

**4. Inspect and verify**
**Files created**

| File | Use |
|---|---|
| `private/root-ca.key` | Signs server certificates; keep only in your protected local workspace. |
| `certs/root-ca.crt` | Public CA certificate used for certificate chains and client trust. |

The root private key stays on your PC. Only server private keys will be used by ACM or EC2.

**Reference documents:**

- [OpenSSL — genpkey](https://docs.openssl.org/3.0/man1/openssl-genpkey/)
- [OpenSSL — req](https://docs.openssl.org/3.2/man1/openssl-req/)
- [OpenSSL — Certificate extensions](https://docs.openssl.org/3.6/man5/x509v3_config/)

# Step 13 — Create the ALB server certificate

I create a certificate for **`geo.minracle.com`**, the shared hostname for all three regional ALBs. Change this hostname before running the commands if you prefer another name.

**1. Return to the certificate workspace**
**2. Generate the ALB private key**
**3. Generate the certificate signing request**
**4. Define the server certificate extensions**
**5. Sign the certificate with the root CA**
**6. Verify the certificate and hostname**
**Files for the upcoming ACM import**

| ACM field | Local file |
|---|---|
| Certificate body | `certs/alb.crt` |
| Certificate private key | `private/alb.key` |
| Certificate chain | `certs/root-ca.crt` |

The same certificate can serve the shared hostname on all three ALBs, but it must be imported separately into ACM in each Region. [AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate.html?trk=article-ssr-frontend-pulse_little-text-block\&utm_source=chatgpt.com)

**Reference documents:**

- [OpenSSL — Signing certificates with x509](https://docs.openssl.org/3.4/man1/openssl-x509/)
- [AWS — ACM import prerequisites](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-prerequisites.html)

# Step 14 — Import the ALB certificate into ACM

I import the certificate for **`geo.minracle.com`** into each Region. Each ALB needs an ACM certificate in its own Region.

**1. Verify the certificate before importing**
**2. Import into Singapore**
**3. Import into London**
**4. Import into Northern California**

Each successful command returns a **certificate ARN**. Save all three for the Terraform ALB listener configuration. `fileb://` makes the AWS CLI read the file contents for the import. [AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-api-cli.html?utm_source=chatgpt.com)

| Region | ARN to retain |
|---|---|
| Singapore | `arn:aws:acm:ap-southeast-1:…:certificate/…` |
| London | `arn:aws:acm:eu-west-2:…:certificate/…` |
| Northern California | `arn:aws:acm:us-west-1:…:certificate/…` |

**5. Check in the AWS console**

Reference documents:**

- [AWS — Import a certificate into ACM](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-api-cli.html)
- [AWS CLI — import-certificate](https://docs.aws.amazon.com/cli/latest/reference/acm/import-certificate.html)

# Step 15 — Create the EC2 backend certificates

I generate a separate private key and certificate for each web server, signed by the existing root CA.

| Server | Certificate hostname |
|---|---|
| Singapore 1 | `sg-web-svr-1.internal.minracle.com` |
| Singapore 2 | `sg-web-svr-2.internal.minracle.com` |
| London 1 | `lon-web-svr-1.internal.minracle.com` |
| London 2 | `lon-web-svr-2.internal.minracle.com` |
| Northern California 1 | `sfo-web-svr-1.internal.minracle.com` |
| Northern California 2 | `sfo-web-svr-2.internal.minracle.com` |

These names identify the certificates. We do not need DNS records for them when the ALB connects to registered EC2 targets by private IP.

**1. Return to the local workspace**
**2. Generate and verify all six certificates**
**3. Inspect one certificate**

**Files needed on each EC2 instance**

| File | Purpose |
|---|---|
| Its own server `.crt` | Apache’s HTTPS certificate |
| Its own server `.key` | Apache’s private key |
| `root-ca.crt` | Local certificate verification |

The server keys are unencrypted so Apache can start unattended. Keep them outside GitHub. **The root CA private key stays on your PC.**

These backend certificates go on EC2, rather than into ACM. The ALB uses the certificate already imported into ACM and establishes separate HTTPS connections to the backend servers. ALB does not validate backend certificates. [docs.aws.amazon.com](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html?trk=article-ssr-frontend-pulse_little-text-block\&utm_source=chatgpt.com)

**Reference documents:**

- [OpenSSL — Certificate signing with x509](https://docs.openssl.org/3.4/man1/openssl-x509/)
- [OpenSSL — Certificate verification](https://docs.openssl.org/3.4/man1/openssl-verify/)
- [AWS — ALB HTTPS target groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)

# Step 16 — Store EC2 certificates in Secrets Manager

I store each server’s certificate and private key in its own regional secret. Later, user data will download those files onto EC2.

This keeps the private keys out of the Terraform configuration and user-data text. Secrets Manager has separate storage and API charges.

**1. Return to the local certificate workspace**

The AWS CLI reads the JSON from the temporary file and uploads it as the secret value. Each successful call prints only the secret ARN. [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli_secrets-manager_code_examples.html?utm_source=chatgpt.com)

The temporary file is removed when the subshell exits. **The root CA private key is not uploaded.**

**3. Verify the secrets**

Our existing EC2 role currently has only Systems Manager permissions. It will also need **`secretsmanager:GetSecretValue`** before user data can retrieve these bundles. [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html?utm_source=chatgpt.com)

Retain the six ARNs for the EC2 configuration.

These commands create new secrets. If a secret already exists, `create-secret` will fail for that name; update it with `put-secret-value` rather than creating a duplicate.

These secrets are created outside Terraform and will need separate cleanup.

**Reference documents:**

- [AWS — Create a secret](https://docs.aws.amazon.com/secretsmanager/userguide/create_secret.html)
- [AWS CLI — create-secret](https://docs.aws.amazon.com/cli/latest/reference/secretsmanager/create-secret.html)
- [AWS CLI — get-secret-value](https://docs.aws.amazon.com/cli/latest/reference/secretsmanager/get-secret-value.html)


# Step 17 — Allow EC2 to retrieve certificates: update `iam.tf`

I add permission to read the **six lab certificate secrets**. The role retains its existing Systems Manager permissions.

**1. Add these blocks to `iam.tf`**

**How it works**

| Setting | Purpose |
|---|---|
| `aws_caller_identity` | Reads the account ID, avoiding a hard-coded account number. |
| `aws_iam_role_policy` | Adds an inline permissions policy to the existing role. |
| `GetSecretValue` | Allows retrieval of the certificate bundle. |
| `Resource` | Restricts access to the six named lab secrets. |

Secrets Manager appends a hyphen and six random characters to each secret ARN. **`-??????`** matches that suffix; these question marks are intentional IAM wildcards, not placeholders to replace. You may use the exact secret ARNs instead. [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_iam-policies.html?utm_source=chatgpt.com)

Because all six instances share this role, each can read all six listed secrets. Its user data will request only its own bundle.

Our upload commands used the default AWS-managed Secrets Manager encryption key. If you selected a customer-managed KMS key instead, the role also needs permission to decrypt with that key. [AWS Secrets Manager](https://docs.aws.amazon.com/it_it/secretsmanager/latest/apireference/API_GetSecretValue.html?utm_source=chatgpt.com)

**2. Update the existing instance profile’s dependency**
**3. Check the configuration**

This update adds **one managed resource: the role policy**. It does not read certificate values into Terraform state.

**Reference documents:**

- [Terraform — aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)
- [Terraform — aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)
- [AWS — Secrets Manager IAM policy examples](https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_iam-policies.html)

# Step 18 — Simple HTTPS web-server template

I use one template for all six servers. Terraform supplies the server label, background color, Region, and secret name.

The AWS CLI uses the **EC2 instance role**, so the script does not include your local `terraform-cli-admin` profile. Standard Amazon Linux 2023 ships with AWS CLI v2. [Amazon Linux 2023](https://docs.aws.amazon.com/linux/al2023/ug/awscli2.html?utm_source=chatgpt.com)


This checks Bash syntax; the actual installation and HTTPS checks run after EC2 launches.

**Reference documents:**

- [Terraform — templatefile()](https://developer.hashicorp.com/terraform/language/functions/templatefile)
- [AWS — Configure TLS on Amazon Linux 2023](https://docs.aws.amazon.com/linux/al2023/ug/SSL-on-amazon-linux-2023.html)
- [AWS CLI — get-secret-value](https://docs.aws.amazon.com/cli/latest/reference/secretsmanager/get-secret-value.html)

# Step 19 — Create the private web servers: `ec2.tf`

I create **two EC2 instances per Region**, each in a different private subnet. Each instance uses its own certificate secret and background color.

Create **`ec2.tf`**:

**How it works**

| Setting | Purpose |
|---|---|
| `for_each` | Creates one instance for each named entry—two per Region. |
| `each.key` | The server name, such as `sg-web-svr-1`. |
| `each.value` | That server’s subnet, page label, and color. |
| `templatefile()` | Renders the shared bootstrap template with those values. |
| `associate_public_ip_address = false` | Keeps instances without public IPv4 addresses. |
| `iam_instance_profile` | Supplies Systems Manager and certificate-retrieval permissions. |
| `http_tokens = "required"` | Requires IMDSv2 for instance metadata access. |

`for_each` gives each instance a stable Terraform address, for example:

```hcl
aws_instance.sg_web["sg-web-svr-1"]
```

Terraform creates one resource instance for each map key. [HashiCorp Developer](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each?utm_source=chatgpt.com)

The explicit dependencies wait for private routing and outbound security-group rules so bootstrap can reach package repositories and Secrets Manager. The instance-profile reference also inherits the IAM dependencies configured in Step 17.

**Template changes replace instances**

```hcl
user_data_replace_on_change = true
```

Changing the rendered user data causes Terraform to replace the affected EC2 instance so bootstrap runs again. Review these replacements in the plan. Updating a secret value alone does not change user data or replace an instance. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/6.38.0/docs/resources/instance?utm_source=chatgpt.com)


This file adds **six EC2 resources**. Before applying, confirm:

- All six secrets are accessible and use the expected names.
- The IAM policy includes the two `nca` secrets.
- Backend certificates include `geo.minracle.com` in their SANs.
- The updated web security groups allow HTTPS:443 from their regional ALBs.

**Reference documents:**

- [Terraform — aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Terraform — for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Terraform — templatefile()](https://developer.hashicorp.com/terraform/language/functions/templatefile)

# Step 20 Create **`target-groups.tf`** in the root module.

I create one target group per region. 
Each group forwards traffic to its two EC2 web servers using **HTTPS on port 443**, with HTTPS health checks. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group.html?utm_source=chatgpt.com)


The important settings are:

| Setting | Purpose |
|---|---|
| `target_type = "instance"` | Register EC2 instances by their instance IDs. |
| `protocol = "HTTPS"` | Encrypt traffic from the ALB to EC2. |
| `port = 443` | Connect to Apache’s HTTPS listener. |
| `port = "traffic-port"` | Run health checks on the target’s traffic port: 443. |
| `path = "/health.html"` | Check the health page created by user data. |
| `matcher = "200"` | Treat HTTP status 200 as successful. |
| `for_each = aws_instance.sg_web` | Create one attachment for each Singapore EC2 instance. |
| `target_id = each.value.id` | Register that instance’s ID. |

The attachment resources register **six instances across three target groups**. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/6.40.0/docs/resources/lb_target_group_attachment?utm_source=chatgpt.com)

Reference documents:

- [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)
- [aws_lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment)

# Step 21 Create **`alb.tf`** in the root module.

I create three public ALBs, each spanning two public subnets in its region.

These references use the subnet and route resource labels from our earlier files. If you renamed those labels locally, update the references to match.

| Setting | Purpose |
|---|---|
| `internal = false` | Create an internet-facing ALB. |
| `load_balancer_type = "application"` | Create an Application Load Balancer. |
| `security_groups` | Attach the regional ALB security group. |
| `subnets` | Place the ALB across two Availability Zones. |
| `enable_deletion_protection = false` | Allow Terraform to delete the ALB during lab cleanup. |
| `depends_on` | Wait for public routes and subnet associations before creating the ALB. |

The subnet and security group settings belong to the `aws_lb` resource. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/5.89.0/docs/resources/lb?utm_source=chatgpt.com)

**This file creates the ALBs.** We will configure their certificates and listeners in subsequent steps.

Reference: [Terraform — aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)

# Step 22 Create **`acm.tf`** in the root module.

I use data sources to find the existing `geo.minracle.com` certificates imported into ACM in each region.

| Setting | Purpose |
|---|---|
| `data "aws_acm_certificate"` | Read an existing ACM certificate. |
| `domain` | Find a certificate for `geo.minracle.com`. |
| `statuses = ["ISSUED"]` | Select a certificate with issued status. |
| `types = ["IMPORTED"]` | Select a manually imported certificate. |
| `most_recent = true` | If several match, select the one with the latest certificate `NotBefore` date. |
| `tags` | Require the matching `Project` tag on the certificate. |

The `tags` block here **filters existing certificates**; it does not add tags. These settings and the returned `.arn` attribute are documented by HashiCorp. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate?utm_source=chatgpt.com)

The actual certificate lookup occurs during `terraform plan`. If no certificate matches in a region, the plan will fail.

Reference: [Terraform — aws_acm_certificate data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate)

# Step 23 Create **`listeners.tf`** in the root module.

I configure each ALB with:

- **HTTPS 443:** use the regional ACM certificate and forward to its HTTPS target group.
- **HTTP 80:** redirect the client to HTTPS 443.

I use your updated Singapore target group label, **`sg_web_server`**, and the earlier London and California labels, `lon_web` and `nca_web`. Match these references to your local declarations.

| Setting | Purpose |
|---|---|
| `load_balancer_arn` | Attach the listener to its regional ALB. |
| `certificate_arn` | Present the imported `geo.minracle.com` certificate to clients. |
| `ssl_policy` | Allow TLS 1.2 and TLS 1.3 for client connections. |
| `type = "forward"` | Send requests to the regional target group. |
| `type = "redirect"` | Tell the client to make a new HTTPS request. |
| `status_code = "HTTP_301"` | Return a permanent redirect. |

The selected security policy supports TLS 1.2 and TLS 1.3. Backend HTTPS is configured separately by the target groups. [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html?utm_source=chatgpt.com)

**HTTPS requests are encrypted on both connections:** client → ALB and ALB → EC2. If a client starts with HTTP, its initial request and redirect response are unencrypted; the subsequent HTTPS request is encrypted.

Reference documents:

- [Terraform — aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)
- [AWS — ALB security policies](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html)

# Step 24 Create **`route53-zone.tf`** in the root module.

I create a public hosted zone specifically for **`geo.minracle.com`**. This lets Route 53 manage the lab subdomain while `minracle.com` keeps its existing DNS provider. AWS supports this through subdomain delegation. [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html?utm_source=chatgpt.com)


| Setting | Purpose |
|---|---|
| `name` | DNS namespace managed by this zone. |
| No `vpc` block | Creates a public hosted zone. |
| `name_servers` | AWS-assigned name servers used for delegation. |
| `zone_id` | Identifies the zone where we will create geolocation records. |

**Only one hosted zone is needed for all three regions.** Route 53 is a global service; `provider = aws` uses your default provider’s credentials.

After deployment, I will add an **NS record** in the existing DNS service for `minracle.com`:

| Field | Value |
|---|---|
| Type | `NS` |
| Name | `geo` (or `geo.minracle.com`, depending on the provider) |
| Values | All four name servers from `geo_name_servers` |

This delegates `geo.minracle.com` to the new hosted zone. Add this record in the parent domain’s **DNS records**, rather than changing the registrar’s name servers for the entire domain. [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html?utm_source=chatgpt.com)

Reference documents:

- [Terraform — aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)
- [AWS — Delegate a subdomain to Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html)

# Step 25 Create **`route53-records.tf`** in the root module.

I create four geolocation **A alias records** for the same hostname, `geo.minracle.com`.

| Location | Code | Destination |
|---|---|---|
| Asia | `AS` | Singapore ALB |
| Europe | `EU` | London ALB |
| North America | `NA` | Northern California ALB |
| Other or unidentified locations | `*` | Singapore ALB |

Alias records use the target resource’s TTL, so I do not specify `ttl` or `records`. [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/6.40.0/docs/resources/route53_record.html?utm_source=chatgpt.com)

With health evaluation enabled, an unhealthy London or California destination can fall back to the healthy Singapore default. **This configuration does not provide Singapore with a different regional fallback**, because Asia and the default both point to Singapore. [AWS re:Post](https://repost.aws/knowledge-center/route-53-active-passive-failover?utm_source=chatgpt.com)


Public DNS resolution will work after delegating `geo.minracle.com` to the hosted zone’s name servers.

Reference documents:

- [Terraform — aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)
- [AWS — Geolocation alias records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-geo-alias.html)

# Step 26 Create **`outputs.tf`** in the root module.

**Move the two output blocks from `route53-zone.tf` into this file** to avoid duplicate declarations. Keep the hosted zone resource in `route53-zone.tf`.

I collect the values needed for DNS delegation and lab verification:

The `for` expression builds a map linking each server name to its instance ID. It **does not create resources**.

For example, after deployment:

```hcl
sg_instance_ids = {
  "sg-web-svr-1" = "i-0123456789abcdef0"
  "sg-web-svr-2" = "i-0fedcba9876543210"
}
```

These IDs are examples; AWS will assign your actual values.

Terraform displays root module outputs after `terraform apply`. You can retrieve them later with `terraform output`. [HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/outputs?utm_source=chatgpt.com)

I selected these outputs because they help with the **next practical tasks: DNS delegation, access, and troubleshooting**.

| Output | Why it is useful |
|---|---|
| Name servers | Required to delegate `geo.minracle.com` from your existing DNS provider to Route 53. |
| Hosted zone ID | Useful for checking DNS records with AWS CLI. |
| Website URL | Convenient link to open the lab. |
| Regional ALB DNS names | Useful for testing each region separately from geolocation routing. |
| EC2 instance IDs | Useful for connecting through SSM and checking user-data logs. |


I left out VPC, subnet, route table, and security group IDs because we don’t need to copy them for the next steps. Terraform already references them internally.

For a minimal setup, keeping only **`geo_name_servers`** is enough for the upcoming DNS delegation. The website URL is already known, and the other values can also be found through AWS Console or CLI.

Reference: [Terraform — Output values](https://developer.hashicorp.com/terraform/language/values/outputs)

# Step 27 Review the Deployment Plan

I now **validate the configuration and review the deployment plan**.

Run these commands from the `lab-07-route53-geolocation` root directory.

1. Confirm the AWS account used by the provider profile:
2. Initialize Terraform:
3. Format and validate the files:
4. Generate a saved plan:

This reads AWS data, including the AMIs and imported ACM certificates, and proposes changes. **It does not create the infrastructure.** [HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/commands/plan?utm_source=chatgpt.com)

5. Review the plan:

For a fresh deployment, check these main resources:

| Resource | Expected count |
|---|---:|
| VPCs | 3 |
| Subnets | 12 |
| Internet gateways | 3 |
| NAT gateways and EIPs | 3 each |
| EC2 web servers | 6 |
| ALBs | 3 |
| Target groups | 3 |
| Target group attachments | 6 |
| Listeners | 6 |
| Public hosted zone | 1 |
| Geolocation A alias records | 4 |

Also confirm:

- The three AWS regions are correct.
- EC2 instances use private subnets and have no public IPs.
- Target groups and health checks use HTTPS 443.
- ACM certificate lookups succeed in all three regions.
- The plan shows no unexpected changes or deletions.

Keep `lab07.tfplan` out of GitHub; it is a local deployment artifact.

Reference: [Terraform — plan command](https://developer.hashicorp.com/terraform/cli/commands/plan)

# Step 28 Deploy the reviewed Terraform Plan

I now **deploy the reviewed Terraform plan**.

**EC2 creation finishing does not mean user data has finished configuring Apache.** We will verify the web servers and target health separately.

Reference: [Terraform — apply command](https://developer.hashicorp.com/terraform/cli/commands/apply)

# Step 29 Delegate domain to Rotue 53

I now **delegate `geo.minracle.com` to Route 53**.

1. Open the DNS management page for **`minracle.com`** at its current DNS provider. If the parent domain already uses Route 53, open its `minracle.com` hosted zone.

2. Add the  **NS records**:

**Add these in the parent domain’s DNS records. Keep the registrar’s name servers for `minracle.com` unchanged.** This delegates only the `geo` subdomain. [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html?utm_source=chatgpt.com)

3. Save the records, then check from your PC:


Reference: [AWS — Delegate a subdomain to Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html)


[AWS — Name server (NS) records created for a hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html)

[AWS — Delegate a subdomain using its four assigned Route 53 name servers](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html)

# Step 30 Verififcation and Testing

1. **Verify delegation**
2. **Check geolocation records**  
3. **Check backend health**  
4. **Verify DNS and HTTPS**
5. **Test geolocation**  
