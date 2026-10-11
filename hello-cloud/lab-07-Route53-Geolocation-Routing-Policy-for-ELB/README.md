# Lab 7 — AWS Route 53 Geolocation Routing

## Overview

I deployed a web application in **Singapore, London, and Northern California** using Terraform. 
I configured Route 53 geolocation routing to direct users to regional Application Load Balancers through one public hostname.

## Architecture

- **DNS:** Route 53 public hosted zone with geolocation alias records.
- **Regional infrastructure:** VPCs, subnets, security groups, ALBs, and EC2 web servers.
- **HTTPS:** Client → HTTPS → Regional ALB → HTTPS → EC2.
- **Certificates:** OpenSSL root CA and server certificates, with ALB certificates imported into ACM.
- **Secret storage:** EC2 certificate bundles stored in AWS Secrets Manager.
- **Access:** IAM roles and instance profiles for secret retrieval and Systems Manager.

![Architecture]()

Route 53 selects the regional endpoint during DNS resolution. Each ALB then forwards application requests to its regional web servers.

![Architecture](/drawing/architecture.png)

## Route53-Geolocationpolicy-Workflow

![route53-geolocation-policy](/drawing/route53-geolocation-workflow.drawio.png)

## Lab Workflow

1. Provision the regional infrastructure with Terraform.
2. Generate certificates and import ALB certificates into regional ACM.
3. Store EC2 certificate bundles in Secrets Manager.
4. Configure IAM permissions and bootstrap the web servers.
5. Configure HTTPS listeners, target groups, and health checks.
6. Delegate the domain to Route 53 and create geolocation records.
7. Test DNS routing and regional application access using Urban VPN.

## Testing and Learning

- Used Urban VPN to test access from different geographic locations.
- Investigated infrastructure, certificate, and connectivity issues.
- Corrected a Singapore VPC CIDR that did not contain its subnet CIDRs.
- Learned how DNS routing, IAM permissions, secret retrieval, and HTTPS work together.

