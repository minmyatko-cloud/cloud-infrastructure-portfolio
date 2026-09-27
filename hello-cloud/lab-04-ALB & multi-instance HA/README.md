# Weakness & Problem of Lab 3
Although Lab 3 provides Multi-AZ redundancy and load balancing, it still has these limitations:

 EC2 instances are launched and configured manually.
Failed instances are not replaced automatically.
Instance capacity cannot scale with traffic demand.
Instances must be registered with target groups manually.
Application traffic uses unencrypted HTTP.
 Services use AWS-generated ALB DNS names.
There is no private DNS for internal service discovery.
Application updates require creating and launching new AMIs manually.


# Purpose of Lab 4

Upgrade Lab 3 with automated provisioning, self-healing, dynamic scaling, private DNS, and TLS-secured application traffic.

# Objectives

Create Launch Templates for Dashboard and Counting EC2 instances.
Configure applications automatically using User Data.
Create separate Auto Scaling Groups across two Availability Zones.
Automatically register instances with their target groups.
Replace unhealthy instances automatically.
Configure scaling policies to add or remove instances based on demand.
Create private DNS names using a Route 53 Private Hosted Zone.
Create a Private CA and issue certificates using AWS Private CA.
Configure HTTPS listeners and encrypt application traffic.
 Test DNS resolution, TLS, scaling policies, failover, and instance replacement.