---
type: study-note
session: CIE Session 1
status: active
domain:
  - Cloud Infrastructure
  - AWS
  - Networking
  - Security
  - Service Discovery
tags:
  - aws
  - networking
  - security
  - service-discovery
  - zero-trust
  - infrastructure-mindset
review: in progress
---

# CIE Session 1 - Study Notes

> [!important]
> **Session Goal**
>
> Build the foundational infrastructure mindset needed to understand how applications are placed, connected, secured, operated, and later automated in cloud environments.

---

## Quick Navigation

- [[Lab 1 - Manual Dashboard and Counting Services]]
- [[Service Discovery]]
- [[Zero Trust]]
- [[Security Groups]]
- [[Public Subnet]]
- [[Private Subnet]]
- [[Bastion Host]]
- [[North-South Traffic]]
- [[East-West Traffic]]
- [[CIE Session 2]]

---

# 1. Session Overview

CIE Session 1 introduces the core questions an infrastructure engineer should ask when deploying an application:

```text
Where does the application run?
        ↓
How does another application find it?
        ↓
How do they communicate?
        ↓
Who is allowed to communicate?
        ↓
How do engineers manage the servers?
```

The key areas are:

```text
Compute
Network
Storage
Security
Application Connectivity
Management Access
Developer Productivity
```

---

# 2. Service Discovery

## What Is the Problem?

Applications often need to communicate with other applications.

Example:

```text
Dashboard Application
        ↓
Counting Application
```

The Dashboard must know how to reach the Counting service.

At a basic level, it needs information such as:

```text
Where is the service?
What endpoint should I use?
What protocol/port should I use?
```

Example:

```text
Counting Service
IP:   10.0.2.20
Port: 8000
```

The Dashboard can then send requests to:

```text
10.0.2.20:8000
```

---

## Basic Application Communication

Traditional application communication may use:

```text
IP Address
+
Port
```

Example:

```text
Dashboard
   │
   │ HTTP
   ▼
10.0.2.20:8000
Counting
```

If network routing and security controls allow that communication, the two applications can exchange traffic.

---

## Why Applications Need to Communicate

Modern systems often contain many separate components.

Examples:

```text
Web Application
      ↓
API
      ↓
Database
```

or:

```text
Grab-style platform

User App
   ↓
Booking Service
   ↓
Driver Service
   ↓
Payment Service
   ↓
Notification Service
```

or:

```text
AI System

Agent A
   ↓
Agent B
   ↓
Tool / API
   ↓
Database
```

Each component may need to locate and communicate with another component.

---

## Service Discovery — Important Correction

> [!important]
> Knowing a **static IP address and port** is enough for basic connectivity, but it is not necessarily dynamic service discovery.

For example:

```text
COUNTING_HOST=10.0.2.20
COUNTING_PORT=8000
```

is usually:

```text
Static Configuration
```

True service discovery becomes more important when:

- instances are replaced
- IP addresses change
- multiple replicas exist
- services scale out/in
- applications move between hosts
- health status changes dynamically

Examples of discovery mechanisms:

```text
ALB / NLB DNS
AWS Cloud Map
Consul
Kubernetes Service
ECS Service Discovery
DNS
```

---

# 3. Infrastructure Mindset

A cloud infrastructure engineer should think in four primary infrastructure dimensions:

```text
Compute
Network
Storage
Security
```

---

## 3.1 Compute

Compute provides the resources required to execute software.

Examples:

```text
CPU
Memory
Operating System
Runtime
```

AWS example:

```text
EC2
```

Questions:

```text
How much CPU?
How much memory?
How many instances?
Which operating system?
How will the application start?
How will failures be handled?
```

---

## 3.2 Network Connectivity

Applications need network paths in order to communicate.

Important concepts:

```text
VPC
Subnet
Route Table
Internet Gateway
Private IP
Public IP
Security Group
Port
Protocol
```

Infrastructure question:

> Can source A reach destination B on the required protocol and port?

Example:

```text
Dashboard
10.0.1.20
     │
     │ TCP 8000
     ▼
Counting
10.0.2.20
```

---

## 3.3 Storage

Applications may require persistent data.

Examples:

```text
Block Storage
Object Storage
File Storage
Database Storage
Cache
```

AWS examples:

```text
EBS
S3
EFS
RDS
ElastiCache
```

Important question:

> What data must survive if the compute instance is terminated?

---

## 3.4 Security

Security should be considered from the beginning rather than added after deployment.

Important concepts:

```text
Identity
Authentication
Authorization
Least Privilege
Network Segmentation
Encryption
Secrets Management
Logging
Zero Trust
```

---

# 4. Zero Trust

## Core Philosophy

A simplified Zero Trust principle is:

```text
Do not trust automatically
        ↓
Verify identity/context
        ↓
Explicitly allow required access
        ↓
Continuously evaluate access
```

A useful infrastructure mindset is:

```text
Default Deny
+
Explicit Allow
+
Least Privilege
```

---

## Important Correction

> [!important]
> A Security Group can help implement **network-level least privilege**, but a Security Group alone is not a complete Zero Trust architecture.

Zero Trust normally involves multiple layers:

```text
Identity
Authentication
Authorization
Device / Workload Context
Network Policy
Least Privilege
Continuous Verification
Logging / Monitoring
```

---

# 5. Identity Is Fundamental

Security decisions need to know:

```text
Who or what is requesting access?
```

Identity can refer to:

```text
Human Identity
Machine Identity
Workload Identity
Application Identity
Service Identity
```

Examples of identity/security ecosystem technologies discussed in modern infrastructure include:

```text
Okta
HashiCorp products
Cloud IAM systems
Service-mesh identity systems
```

---

## Identity and Authorization

Once identity is established, policy can define what that identity is allowed to do.

Example:

```text
Payment Service
      ↓
May READ customer account
      ↓
May NOT modify unrelated systems
```

Another example:

```text
Reporting Service
      ↓
READ database
      ↓
No WRITE permission
```

This follows:

```text
Least Privilege
```

---

# 6. Network Identity vs Workload Identity

In a simple lab, we may identify an application endpoint as:

```text
IP Address + Port
```

Example:

```text
10.0.2.20:8000
```

This is useful as a **network endpoint identity**.

However:

> [!important]
> IP address is not the same as strong workload identity.

Modern systems may identify workloads through:

```text
IAM roles
Service accounts
Certificates
SPIFFE identities
Kubernetes service accounts
Cloud workload identity
Service mesh identities
```

The CIE Session 1 lab begins with:

```text
IP + Port
```

because it is easy to observe and understand.

Later systems can evolve toward stronger workload identity.

---

# 7. Deterministic vs Non-Deterministic Behavior

Traditional software is usually designed to follow deterministic logic.

Example:

```text
IF balance >= purchase amount
THEN approve
ELSE reject
```

The developer explicitly defines the expected behavior.

AI agents can behave more probabilistically or non-deterministically.

Example:

```text
Same task
+
different context/model state
        ↓
potentially different reasoning/actions
```

This makes:

```text
Identity
Authorization
Policy
Guardrails
Auditability
```

especially important.

---

# 8. Business Logic and Infrastructure Engineering

Infrastructure exists to support business applications.

One useful platform-engineering mindset is:

> Developers are internal customers of the infrastructure/platform team.

The infrastructure team should help developers:

```text
Deploy faster
Deploy safely
Get environments quickly
Observe applications
Recover from failure
Use secure defaults
Avoid repeated manual infrastructure work
```

---

## Developer Productivity

A major goal is:

```text
Reduce infrastructure friction
        ↓
Improve developer productivity
        ↓
Ship business features faster
```

But productivity must be balanced with:

```text
Security
Reliability
Governance
Cost
Operability
```

---

# 9. Technology Transformation — Course Timeline

> [!note]
> This timeline should be understood as a simplified learning model rather than a strict industry chronology. Many technologies overlapped across years.

---

## Around 2000 — Physical Servers

Typical model:

```text
Application
    ↓
Dedicated Physical Server
```

Characteristics:

- hardware procurement
- slower provisioning
- manual configuration
- lower resource utilization
- physical data-center dependency

---

## Early 2010s — Virtualization and Cloud Adoption

```text
Physical Hardware
      ↓
Hypervisor
      ↓
Virtual Machines
```

Cloud platforms accelerated:

```text
On-demand compute
API-driven infrastructure
Elastic capacity
Pay-as-you-go
```

Major hyperscalers:

```text
AWS
Microsoft Azure
Google Cloud
```

---

## Mid 2010s — DevOps, CI/CD, Containers, Kubernetes

Key trends:

```text
DevOps
CI/CD
Containers
Docker
Kubernetes
Automation
```

Application deployment became increasingly automated.

---

## Late 2010s — IaC and GitOps Become More Common

Important concepts:

```text
Infrastructure as Code
Terraform
GitOps
Declarative Infrastructure
Automation Pipelines
```

Infrastructure could increasingly be reviewed and version-controlled like software.

---

## Around 2021 — Platform Engineering Growth

Platform teams increasingly focused on:

```text
Internal Developer Platforms
Golden Paths
Self-Service
Standardized Infrastructure
Developer Experience
```

---

## Around 2025 — AI-Assisted Development

Course topics include:

```text
Vibe Coding
Context Engineering
AI Agents
AI-assisted Software Development
```

---

## 2026 — Emerging Engineering Concepts

Course framing includes emerging terms such as:

```text
Harness Engineering
Graph Engineering
```

> [!note]
> These are emerging terms and should not be treated as universally standardized industry disciplines without additional context.

---

# 10. Hyperscalers and AI-Focused Cloud Providers

Traditional hyperscalers:

```text
AWS
Azure
GCP
```

They provide broad cloud platforms covering:

```text
Compute
Storage
Networking
Databases
Security
Analytics
AI/ML
Serverless
Containers
```

The course also discusses newer providers that focus heavily on GPU/AI infrastructure, such as:

```text
Nebius
CoreWeave
Nscale
IREN
```

A simplified distinction:

```text
Hyperscalers
      ↓
Very broad cloud platforms

AI-focused / specialized cloud providers
      ↓
GPU-heavy AI infrastructure specialization
```

---

# 11. Dashboard and Counting Applications

The Session 1 example contains two application services:

```text
Dashboard Application
        ↓
Counting Application
```

The Dashboard is the user-facing component.

The Counting service is an upstream/backend dependency for Dashboard.

---

# 12. Public vs Private Placement

Main question:

> Does the application need direct inbound access from public users?

---

## Dashboard

Public users need to access the Dashboard.

For this learning lab:

```text
Internet
   ↓
Dashboard
```

Therefore, the Dashboard EC2 may be placed in a public subnet.

> [!note]
> In more mature production architecture, even web/application servers are often kept private behind a public load balancer. This Session 1 design is intentionally simpler for learning.

---

## Counting Service

Public users do not need to directly access the Counting service.

Therefore:

```text
Counting Service
      ↓
Private Subnet
```

Only the Dashboard should reach its application port.

---

# 13. Public Subnet vs Private Subnet

## Public Subnet

A subnet is considered public when its route table provides a route to an Internet Gateway.

Concept:

```text
0.0.0.0/0
   ↓
Internet Gateway
```

An EC2 instance also needs an appropriate public IPv4/EIP and Security Group rules to be reachable from the Internet.

---

## Private Subnet

A private subnet does not provide direct inbound Internet reachability through an Internet Gateway route.

Example:

```text
Counting EC2
Private IP only
```

This reduces direct public exposure.

---

# 14. Application Traffic vs Management Traffic

These are different purposes.

---

## Application Traffic

Traffic required for the application itself.

Examples:

```text
User → Dashboard
Dashboard → Counting
```

Example ports:

```text
HTTP/HTTPS
8000
Application-specific ports
```

---

## Management Traffic

Traffic used by administrators to manage infrastructure.

Example:

```text
SSH
TCP 22
```

Flow:

```text
Administrator
     ↓
SSH
     ↓
EC2
```

SSH is not normal end-user application traffic.

It is:

```text
Management Traffic
```

---

# 15. Why We Need a Bastion Host

The Counting server is in a private subnet.

Therefore, we do not want:

```text
Internet
   ↓
direct SSH
   ↓
Counting Server
```

Instead:

```text
Administrator
      │
      │ SSH
      ▼
Bastion Host
      │
      │ SSH
      ▼
Private Counting Server
```

The bastion is also called:

```text
Jump Host
```

It provides a controlled management entry point.

---

# 16. Management Flow

Example:

```text
Laptop
  │
  │ SSH 22
  ▼
Bastion Host
Public Subnet
  │
  │ SSH 22
  ├──────────────► Dashboard EC2
  │
  └──────────────► Counting EC2
                   Private Subnet
```

---

# 17. Application Flow

```text
Public User
     │
     │ Dashboard application port
     ▼
Dashboard EC2
     │
     │ Counting application port
     ▼
Counting EC2
```

The user should not directly access the Counting application.

---

# 18. IP Address Behavior — Important Correction

A common misunderstanding is:

```text
EC2 stops
   ↓
all IP addresses change
```

That is not always correct.

---

## Private IPv4

The primary private IPv4 associated with the EC2 primary network interface normally remains associated across:

```text
Stop
Start
Reboot
```

unless networking is reconfigured.

---

## Auto-Assigned Public IPv4

An automatically assigned public IPv4 can change after:

```text
Stop
Start
```

A normal reboot does not usually cause the same public-IP replacement behavior as stop/start.

---

## Elastic IP

If a stable public IPv4 is required:

```text
Elastic IP
```

can provide a persistent public IPv4 association.

> [!important]
> For application-to-application communication inside a VPC, use private networking rather than public IP whenever possible.

---

# 19. Application Endpoint

In this lab, the Counting application's endpoint may be represented as:

```text
Private IP : Port
```

Example:

```text
10.0.2.20:8000
```

Dashboard needs to know:

```text
Destination IP
Destination Port
Protocol
```

Example:

```text
TCP
10.0.2.20
8000
```

---

# 20. Security Groups and Least Privilege

AWS Security Groups are stateful virtual firewalls attached to network interfaces/resources.

The desired mindset:

```text
Deny unnecessary access
        ↓
Explicitly allow required traffic
```

---

# 21. Minimum-Privilege Security Model

We have three servers:

```text
Bastion
Dashboard
Counting
```

We should not use:

```text
0.0.0.0/0
```

for every port.

Instead, allow only what is required.

---

# 22. Bastion Security Group

Example:

```text
SG-Bastion
```

Inbound:

```text
SSH TCP 22
Source: Your trusted public IP /32
```

Do not allow SSH from the entire Internet if avoidable.

Example:

```text
203.0.113.10/32
```

---

# 23. Dashboard Security Group

Example:

```text
SG-Dashboard
```

Inbound application traffic:

```text
Dashboard Port
Source: Public users
```

For a basic HTTP lab, this might be:

```text
TCP 8000
Source 0.0.0.0/0
```

only if the Dashboard must be directly reachable publicly on that port.

Inbound management traffic:

```text
SSH TCP 22
Source: SG-Bastion
```

This means:

```text
Only Bastion
can SSH
to Dashboard
```

---

# 24. Counting Security Group

Example:

```text
SG-Counting
```

Inbound application traffic:

```text
TCP 8000
Source: SG-Dashboard
```

Inbound management traffic:

```text
SSH TCP 22
Source: SG-Bastion
```

This provides:

```text
Dashboard
   ↓
Counting app port

Bastion
   ↓
SSH management
```

Public users cannot directly reach Counting.

---

# 25. Why Reference Security Groups?

Instead of allowing:

```text
10.0.1.0/24
```

for every application connection, AWS Security Groups can often reference another Security Group as a source.

Example:

```text
SG-Counting inbound TCP 8000
Source: SG-Dashboard
```

This expresses intent more clearly:

```text
Dashboard workload
may access
Counting workload
```

rather than:

```text
Any IP in subnet
may access
Counting
```

---

# 26. Security Group ≠ Complete Zero Trust

Security Groups support:

```text
Segmentation
Least Privilege
Explicit Allow
Stateful Filtering
```

But complete Zero Trust may additionally need:

```text
Strong Identity
Authentication
Authorization
Encryption
Workload Identity
Continuous Verification
Audit Logs
Policy Engines
```

---

# 27. What About NACLs?

> [!important]
> Do not interpret "we usually use Security Groups" as "NACLs are never required."

Security Groups:

```text
Resource / ENI level
Stateful
Allow rules
```

NACLs:

```text
Subnet level
Stateless
Allow + Deny rules
```

For many application designs, Security Groups are the primary day-to-day workload firewall.

NACLs are useful when subnet-level controls or explicit deny rules are required.

For this lab:

```text
Security Groups
```

are sufficient for learning minimum-privilege traffic control.

---

# 28. Complete Session 1 Architecture

```text
                         INTERNET
                             │
               ┌─────────────┴──────────────┐
               │                            │
               │ Public App Traffic         │ SSH Management
               ▼                            ▼
        Dashboard EC2                  Bastion Host
        Public Subnet                  Public Subnet
               │                            │
               │ TCP 8000                   │ SSH 22
               │                            ├──────────────► Dashboard
               ▼                            │
        Counting EC2 ◄──────────────────────┘
        Private Subnet
```

Application flow:

```text
Public User
   ↓
Dashboard
   ↓
Counting
```

Management flow:

```text
Administrator
   ↓
Bastion
   ├── Dashboard
   └── Counting
```

---

# 29. Key Infrastructure Questions

When deploying any application, ask:

## Compute

```text
Where will it run?
How much CPU/memory?
How will the process start?
```

## Network

```text
Who talks to whom?
Which protocol?
Which port?
Which subnet?
Which route?
```

## Storage

```text
Does data need to persist?
Where is state stored?
```

## Security

```text
Who is allowed?
Who is denied?
What identity is used?
What is the minimum required access?
```

## Operations

```text
How do engineers access it?
How is it monitored?
How does it recover?
```

---

# 30. Session 1 Interview Reasoning

## Problem

Two applications need to communicate, but the backend should not be exposed directly to the public Internet.

## Design

```text
Dashboard
= public-facing

Counting
= private backend

Bastion
= management entry point
```

## Security

Use separate Security Groups:

```text
Internet → Dashboard application port
Trusted IP → Bastion SSH
Bastion → Dashboard SSH
Bastion → Counting SSH
Dashboard → Counting application port
```

## Result

Application traffic and management traffic are separated while the backend remains private.

---

# 31. Session 1 → Session 2 Evolution

Session 1:

```text
Applications are started manually
        ↓
Static backend IP/port
        ↓
Basic Security Group connectivity
        ↓
Bastion management access
```

Session 2 builds on this:

```text
Manual Process
      ↓
systemd

Login User
      ↓
Dedicated Service User

Single Counting Instance
      ↓
Multiple Instances + Load Balancer

Fixed Capacity
      ↓
Auto Scaling
```

Because Lab 1 now belongs to Session 1, Session 2 becomes:

```text
Lab 2 — systemd
Lab 3 — Dedicated Application User
Lab 4 — ELB and SPOF Removal
Lab 5 — ELB + Auto Scaling + Load Testing
```

---

# 32. Quick Memorization

```text
Service endpoint
= IP/DNS + Port
```

```text
Application traffic
= traffic used by application/users
```

```text
Management traffic
= SSH/admin/operations traffic
```

```text
Public-facing component
= reachable by intended public clients
```

```text
Private backend
= no direct public inbound requirement
```

```text
Security Group
= stateful resource-level virtual firewall
```

```text
Bastion
= controlled jump point for management access
```

```text
Zero Trust
≈ verify explicitly + least privilege + assume no implicit trust
```

---

# 33. Common Mistakes

> [!warning]
> **Static IP + port is not automatically service discovery.**
>
> It is commonly static service configuration.

> [!warning]
> **An IP address is not a complete workload identity.**

> [!warning]
> **Security Groups alone do not create a full Zero Trust architecture.**

> [!warning]
> **Private IPv4 and auto-assigned public IPv4 have different lifecycle behavior.**

> [!warning]
> **Private subnet does not mean administrators can never reach the instance.**
>
> Management access can occur through a bastion, VPN, SSM, or other controlled mechanism.

> [!warning]
> **NACLs are not useless.**
>
> They are a different subnet-level control and are optional depending on design requirements.

---

# 34. Recommended Further Study

- [ ] [[Service Discovery]]
- [ ] [[DNS]]
- [ ] [[Security Groups]]
- [ ] [[Network ACL]]
- [ ] [[Zero Trust]]
- [ ] [[AWS IAM]]
- [ ] [[Workload Identity]]
- [ ] [[Bastion Host]]
- [ ] [[AWS Systems Manager Session Manager]]
- [ ] [[Public Subnet]]
- [ ] [[Private Subnet]]
- [ ] [[North-South Traffic]]
- [ ] [[East-West Traffic]]

---

# 35. Study Progress

- [ ] Understand service-to-service communication
- [ ] Understand static endpoint vs service discovery
- [ ] Understand compute/network/storage/security mindset
- [ ] Understand Zero Trust at a high level
- [ ] Understand identity vs IP endpoint
- [ ] Understand developer productivity mindset
- [ ] Understand technology evolution overview
- [ ] Understand public vs private application placement
- [ ] Understand application vs management traffic
- [ ] Understand why a bastion host is used
- [ ] Understand private vs public IP lifecycle
- [ ] Understand Security Group least privilege
- [ ] Understand Security Group vs NACL
- [ ] Complete [[Lab 1 - Manual Dashboard and Counting Services]]
- [ ] Explain CIE Session 1 without notes
