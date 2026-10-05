# AWS Blue–Green Deployment with 60/40 Traffic Sharing

I extend my Multi-AZ Dashboard and Counting application with two Dashboard environments. I keep the existing versio(lab-04)n as **Blue** and deploy the updated version as **Green**, then use ALB weighted forwarding for a canary-style release.

## Objectives

- Prepare Green while Blue continues serving users.
- Route approximately **60% of requests to Blue** and **40% to Green**.
- Verify health, Counting integration, traffic distribution, and performance.
- Demonstrate full Green promotion and rollback to Blue.

## Architecture
![Architecture](/evidences/traffic-flow-blue-green-environment.png)

Solid arrows represent requests; dashed arrows represent DNS records or certificate configuration. ASGs manage instances rather than forwarding requests.

| Component | Configuration |
|---|---|
| Region | `ap-southeast-1` — Singapore |
| Dashboard | Shared public ALB with HTTPS:443 |
| Blue and Green | Separate Launch Templates, ASGs, and target groups |
| Dashboard capacity | Two EC2 instances per environment across two AZs |
| ASG limits | Minimum 2, desired 2, maximum 4 per Dashboard environment |
| Counting | Shared backend behind an internal HTTPS ALB |
| Target connections | Dashboard HTTP:9000; Counting HTTP:8000 |
| Stickiness | Disabled for distribution testing |

The 60/40 split controls **request share**, not instance counts. With maximum capacity set to two, the Dashboard ASGs cannot scale out beyond two instances.

## Deployment Workflow

![Work-Flow](/evidences/release-work-flow.png)

1. Record Blue's resources and verify its existing behavior.
2. Create Green's Launch Template, target group, and ASG.
3. Use User Data to configure Dashboard, its dedicated service user, systemd, and CA trust where required.
4. Verify Green's health and HTTPS access to Counting before introducing production traffic.
5. Apply 60/40 forwarding and measure distribution and performance.
6. Promote Green after release criteria are met; verify a fresh measurement window.
7. Test rollback to Blue, verify recovery, and restore Green after validation.
8. Retain Blue during the observation period before cleanup.

## Verification and Testing

I evaluate traffic distribution using CloudWatch target-group **RequestCount**, with **Sum** over the same time window for Blue and Green. Response-marker classification was not performed.

I assess errors, healthy targets, average and p95 target response time, and client-side latency and throughput from load testing. Target response time is not the complete client response time.

Before each test, I confirm the active listener weights and ensure the test script does not reset them. I isolate the measurement window from earlier runs and allow for metric publication delay and unrelated traffic.


## Security and Operational Notes

- I keep application instances in private subnets and allow application ports from their corresponding ALB security groups.
- I allow Counting ALB HTTPS access from the Dashboard instance security group or groups.
- I validate Counting's hostname and certificate trust from both Dashboard versions.
- HTTPS terminates at each ALB; the ALB-to-EC2 connections shown above use HTTP.
- A private Dashboard hosted zone requires client access to private DNS resolution.
- An unhealthy Green target group does not automatically transfer its weighted share to Blue.
- Rollback requires a healthy, compatible Blue environment and does not undo shared data changes.
- Zero traffic weight does not stop instances or their charges.
- I exclude credentials, private keys, and sensitive configuration from the repository.

## References

- [AWS — Blue-green and canary deployments with ALB](https://aws.amazon.com/blogs/devops/blue-green-deployments-with-application-load-balancer/)
- [AWS — Weighted forwarding and stickiness](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/rule-action-types.html)
- [AWS — ALB health checks](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html)
- [AWS — ALB CloudWatch metrics](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html)
