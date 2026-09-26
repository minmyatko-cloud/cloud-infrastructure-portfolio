
>


# 1. Problem of Lab 3
Dashboard and Counting EC2 instances are launched and managed manually. Failed instances are not replaced automatically, capacity cannot adjust to traffic demand, services use AWS-generated DNS names, and application traffic is not encrypted.

# 2. Solution

Use Launch Templates and User Data to automate EC2 provisioning, Auto Scaling Groups and scaling policies for self-healing and dynamic capacity, Route 53 for private DNS, and AWS Private CA certificates to secure application traffic with TLS.

# 3. Concepts and Theory

## 3.1. Launch Template

A Launch Template is a reusable configuration that defines how EC2 instances must be created.

It can contain:

- AMI
- Instance type
- Key pair
- Security groups
- IAM instance profile
- Storage configuration
- User Data
- Instance metadata settings
- Resource tags

Launch Templates support versioning. When configuration changes, create a new version and update the Auto Scaling Group to use it.

**AWS reference:** [EC2 Launch Templates](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)

---

## 3.2. EC2 User Data

User Data is a script supplied when an EC2 instance is launched. 

In this lab, User Data will:

- Install required packages.
- Download the application.
- Create the dedicated service user.
- Create the systemd unit.
- Configure application environment variables.
- Start and enable the service.

Example flow:

![[Pasted image 20260924213734.png|264]]

```
ASG launches EC2
    ↓
EC2 reads User Data
    ↓
User Data installs and configures application
    ↓
systemd starts the service
    ↓
ALB health check becomes healthy
```

User Data normally runs during the first boot. Its output can be checked with:

```
sudo cat /var/log/cloud-init-output.log
```

>[!Note]
>Do not place passwords, private keys, or permanent AWS credentials directly in User Data.

**AWS reference:** [Run commands using EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html?utm_source=chatgpt.com)

---

## 3.3. Auto Scaling Group

An Auto Scaling Group, or ASG, manages a group of EC2 instances as one logical unit.

Its main functions are:

- Launch the required number of instances.
- Maintain the desired capacity.
- Replace unhealthy instances.
- Distribute instances across Availability Zones.
- Add or remove instances according to scaling policies.
- Automatically register instances with an ALB target group.

An ASG uses three capacity values:

|Capacity|Meaning|
|---|---|
|Minimum|Lowest number of instances allowed|
|Desired|Number of instances the ASG currently tries to maintain|
|Maximum|Highest number of instances allowed|

Example:

```
Minimum: 2
Desired: 2
Maximum: 4
```

The ASG normally maintains two instances but can scale out to four. It will not scale below two.

**AWS reference:** [Amazon EC2 Auto Scaling Groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html?utm_source=chatgpt.com)

---

## 3.4. Self-Healing

Self-healing means automatically replacing an unhealthy EC2 instance.

![[Pasted image 20260924214639.png|518]]

```
Dashboard EC2 becomes unhealthy
        ↓
ALB health check fails
        ↓
ASG marks the instance unhealthy
        ↓
ASG terminates the instance
        ↓
ASG launches a replacement
        ↓
New instance runs User Data
        ↓
New instance becomes healthy
```

Enable **Elastic Load Balancing health checks** in the ASG. Otherwise, the ASG primarily uses EC2 status checks and may not detect that the application itself has failed.

**AWS reference:** [ASG health checks](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html?utm_source=chatgpt.com)

---

## 3.5. Health Check Grace Period

A new EC2 instance needs time to:

- Complete booting.
- Execute User Data.
- Install packages.
- Start systemd services.
- Become ready to receive traffic.

The health check grace period prevents the ASG from replacing the new instance before initialization finishes.

Example:

```
Health check grace period: 300 seconds
```

This is different from the ALB health-check interval. The ALB checks whether the application is ready; the grace period tells the ASG when it may start acting on failed health checks.

---

## 3.6. Scaling Policies

A scaling policy determines when the ASG should increase or decrease its desired capacity.

### Target Tracking Scaling

Target tracking keeps a selected metric near a target value.

Example:

```
Metric: Average CPU utilization
Target value: 60%
```

Behavior:

```
CPU above target → Scale out
CPU below target → Scale in
```

Other useful metrics include:

- `ASGAverageCPUUtilization`
- `ALBRequestCountPerTarget`
- Network utilization
- Custom CloudWatch application metrics

Target tracking is generally the simplest dynamic scaling option.

**AWS reference:** [Target tracking scaling policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html?utm_source=chatgpt.com)

### Step Scaling

Step scaling performs different scaling actions depending on the alarm severity.

|CPU utilization|Scaling action|
|---|---|
|60–70%|Add one instance|
|70–85%|Add two instances|
|Above 85%|Add three instances|

**AWS reference:** [Step scaling policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html?utm_source=chatgpt.com)

---

## 3.7. Instance Warmup

Instance warmup is the time required for a new instance to become fully operational and contribute reliable metrics.

During warmup:

- The instance starts the application.
- It begins receiving traffic.
- Its metrics are not immediately used to make another scaling decision.

This prevents repeated and unnecessary scale-out operations while recently launched instances are still starting. AWS recommends configuring default instance warmup for target tracking and step scaling.

**AWS reference:** [Default instance warmup](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-default-instance-warmup.html?utm_source=chatgpt.com)

---

## 3.8. ASG, Target Group and ALB Relationship

These resources have different responsibilities:

|Resource|Responsibility|
|---|---|
|Launch Template|Defines how EC2 instances are created|
|Auto Scaling Group|Manages instance quantity and health|
|Target Group|Groups application instances and checks health|
|ALB|Receives and distributes network requests|
|Scaling Policy|Changes ASG desired capacity|
|CloudWatch|Supplies metrics and alarms|

The ASG attaches to the **target group**, not directly to the ALB.
![[Pasted image 20260924215752.png|557]]

```
Scaling Policy
      ↓
Auto Scaling Group
      ↓
EC2 instances
      ↓
Target Group
      ↓
Application Load Balancer
```

When the ASG launches or terminates instances, target registration and deregistration are handled automatically.

**AWS reference:** [Attach an ALB target group to an ASG](https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html?utm_source=chatgpt.com)

---

## 3.9. Route 53 Private Hosted Zone

A Private Hosted Zone provides DNS records that can be resolved only from associated VPCs.

Example zone:

```
lab.internal
```

Example records:

```
dashboard.lab.internal → Dashboard ALB
counting.lab.internal  → Counting ALB
```

This avoids placing AWS-generated ALB DNS names directly in application configurations.

A Private Hosted Zone must be associated with the correct VPC. Route 53 Resolver then answers queries originating from that VPC.

**AWS reference:** [Route 53 Private Hosted Zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-private.html?utm_source=chatgpt.com)

>[!Important Limitation]
>
Private hosted-zone records are not resolvable directly from the public internet.
>
Therefore:
>
>- `counting.lab.internal` is suitable for internal communication.
>- A public user cannot resolve `dashboard.lab.internal` unless connected to the VPC through VPN, Direct Connect, or another DNS-forwarding solution.
>- A public-facing Dashboard requires a Public Hosted Zone or public DNS record.

---

## 3.10. Route 53 Alias Record

A Route 53 Alias record can point a DNS name directly to an AWS load balancer.

Example:

```
counting.lab.internal
        ↓
Internal Counting ALB
```

Alias records are preferred over manually storing ALB IP addresses because ALB IP addresses can change. Route 53 maintains the connection to the AWS resource.

**AWS reference:** [Routing Route 53 traffic to an ELB](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html?utm_source=chatgpt.com)

---

## 3.11. TLS and HTTPS

TLS protects network communication by providing:

- **Encryption:** Prevents others from reading the traffic.
- **Integrity:** Detects modification during transmission.
- **Authentication:** Confirms the identity of the server.

HTTPS means HTTP traffic protected by TLS:

```
HTTP + TLS = HTTPS
```

The standard HTTPS port is:

```
TCP 443
```

---

## 3.12. PKI and Certificate Authority

Public Key Infrastructure, or PKI, manages digital identities and certificates.

Main components include:

|Component|Purpose|
|---|---|
|Certificate Authority|Issues and signs certificates|
|Root CA|Highest trust authority|
|Private key|Proves the identity of the certificate owner|
|Public key|Used during encryption and verification|
|Certificate|Connects a DNS identity with a public key|
|Trust store|Contains trusted CA certificates|
|Certificate chain|Links the server certificate to its trusted CA|

The private key must remain confidential.

---

## 3.13. AWS Private CA

AWS Private Certificate Authority is a managed service for building a private PKI and issuing private X.509 certificates.

It can be used for:

| Use case                          | Meaning                                                                                   | Example                                                                    |
| --------------------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Internal application HTTPS        | Encrypt access to applications available only inside a company network or VPC             | Employee opens `https://dashboard.lab.internal`                            |
| Private APIs                      | Protect API endpoints that are not publicly accessible                                    | Dashboard calls `https://api.lab.internal`                                 |
| Service-to-service authentication | One application verifies the identity of another application                              | Dashboard verifies that it is communicating with the real Counting service |
| Internal ALBs                     | Add an HTTPS listener and private certificate to an internal load balancer                | `counting.lab.internal` points to the internal Counting ALB                |
| Devices and users                 | Issue individual certificates to identify trusted users, laptops, servers, or IoT devices | Company laptop presents its certificate before receiving access            |
| Mutual TLS                        | Both the client and server authenticate each other using certificates                     | Dashboard and Counting service verify each other                           |

AWS Private CA manages the CA infrastructure, while ACM can request and manage certificates issued by that CA.

**AWS references:**

- [What is AWS Private CA?](https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html?utm_source=chatgpt.com)
- [Request an ACM private certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-private.html?utm_source=chatgpt.com)

### Private Certificate Trust

A private certificate is not automatically trusted by public browsers or operating systems.

The Private CA root certificate must be installed in the client’s trust store. Otherwise, the browser displays a certificate warning.

For example:

```
Private CA certificate
        ↓ installed in
Laptop operating-system trust store
        ↓
Browser trusts the private application certificate
```

---

## 3.14. HTTPS Listener on an ALB

An ALB HTTPS listener requires:

| Component                           | Purpose                                                                                                                                                             |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Protocol: HTTPS**                 | Tells the ALB to accept HTTP traffic encrypted with TLS.                                                                                                            |
| **Port: 443**                       | Standard network port used for HTTPS connections. The ALB security group must allow inbound TCP `443`.                                                              |
| **Certificate from ACM**            | Proves the identity of the ALB and provides the public key used during the TLS connection.                                                                          |
| **TLS security policy**             | Defines the allowed TLS versions, encryption algorithms, and ciphers. Use the AWS-recommended policy unless the application has special compatibility requirements. |
| **Default forwarding target group** | Specifies where the ALB sends requests when no other listener rule matches—for example, `dashboard-tg`.                                                             |

## AWS Certificate Manager (ACM)

ACM is an AWS service for requesting, storing, deploying, and renewing TLS certificates.

For this lab:

```
AWS Private CA
      ↓ issues
ACM private certificate
      ↓ attached to
ALB HTTPS listener
```

Example certificate:

```
Certificate name: dashboard.lab.internal
HTTPS listener: 443
Attached resource: Dashboard ALB
```

>[!Important points:]
>
>- The certificate name must match the DNS name used by the client.
>- The ACM certificate must be in the same AWS Region as the ALB.
>- ACM securely manages the certificate and private key.
>- The private key is not directly exposed when the certificate is attached to the ALB.
>- ACM-managed private certificates can be renewed automatically when the required permissions remain available.
>- Clients must trust your Private CA root certificate.

**AWS reference:**
[AWS: ACM private certificates](https://docs.aws.amazon.com/acm/latest/userguide/private-certificates.title.html?utm_source=chatgpt.com)  
[AWS: Create an ALB HTTPS listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html?utm_source=chatgpt.com)


---

## 3.15. TLS Termination and End-to-End TLS

### TLS Termination at the ALB

```
Client ──HTTPS──> ALB ──HTTP──> EC2
```

The ALB decrypts the request. Communication between the ALB and EC2 uses HTTP.

Advantages:

- Easier certificate management
- Lower application configuration complexity
- ALB handles encryption and decryption

### End-to-End TLS

```
Client ──HTTPS──> ALB ──HTTPS──> EC2
```

The ALB decrypts the client connection and creates a separate HTTPS connection to the EC2 target.

This requires:

- HTTPS target group
- TLS configuration on EC2
- Certificate installed on the EC2 service or reverse proxy
- Application or Nginx listening with TLS

An ALB supports HTTPS targets, but it does not validate the certificate installed on the target.

**AWS reference:** [ALB target groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html?utm_source=chatgpt.com)

---

## 16. Proposed Lab 4 DNS and TLS Flow

```
User or VPC Client
        │
        │ HTTPS:443
        ▼
dashboard.lab.internal
        │
        ▼
Dashboard ALB
        │
        ▼
Dashboard ASG instances
        │
        │ HTTPS:443
        ▼
counting.lab.internal
        │
        ▼
Internal Counting ALB
        │
        ▼
Counting ASG instances
```

The certificate names must match the DNS names used by clients:

```
Dashboard certificate: dashboard.lab.internal
Counting certificate:  counting.lab.internal
```

---

## 17. Security Groups for TLS

|Security group|Mandatory inbound traffic|
|---|---|
|Dashboard ALB SG|TCP 443 from approved clients|
|Dashboard EC2 SG|Application port from Dashboard ALB SG|
|Counting ALB SG|TCP 443 from Dashboard EC2 SG|
|Counting EC2 SG|Application port from Counting ALB SG|

If port `80` remains enabled on the Dashboard ALB, use it only to redirect HTTP requests to HTTPS.

Do not permit direct public access to Dashboard or Counting EC2 instances.

---

