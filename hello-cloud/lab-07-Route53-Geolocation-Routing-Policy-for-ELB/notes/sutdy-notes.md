# Lab 7 — Route 53 Geolocation: Study Notes

These notes use the visible summary of “Write GitHub Lab Guide.” The full chat could not be retrieved. Confirmed details include deployments in Singapore, London and Northern California; Terraform; OpenSSL root and server certificates; ACM imports; EC2 certificate bundles in Secrets Manager; an IAM role and instance profile; and Urban VPN testing. Exact record names, location rules and resource identifiers are unavailable. The DNS mappings and names below are examples, not claims about the deployed configuration.

## 1. Overview and purpose

I deploy a web application in three AWS Regions and use one public hostname to reach it. Route 53 selects a regional endpoint according to the geographic rule matching a DNS query. Each regional ALB forwards web requests to that region’s web servers.

| Layer | Component | Responsibility |
| --- | --- | --- |
| Provisioning | Terraform | Creates and connects resources reproducibly |
| Global DNS | Route 53 public hosted zone | Stores public records and answers authoritative DNS queries |
| Geographic selection | Geolocation alias records | Selects a regional ALB according to configured location rules |
| Regional entry point | Application Load Balancer | Accepts HTTPS and forwards requests to targets |
| Backend | EC2 web servers | Serves the application over HTTPS |
| ALB certificate storage | ACM | Holds certificates used by HTTPS listeners |
| EC2 certificate storage | Secrets Manager | Stores the web-server certificate bundle, including its private key |
| AWS access | IAM role and instance profile | Grants EC2 temporary credentials and limited service permissions |
| Operations | Systems Manager, service logs and health checks | Supports administration and verification |

The two decisions occur at different layers: Route 53 selects an endpoint during DNS resolution; the ALB selects a target during HTTP request processing.

## 2. Whole-lab workflow

### Infrastructure and certificate preparation

1. Define the Terraform provider configurations for Singapore, London and Northern California.
2. Create each region’s VPC, subnets, routing and security groups. Every subnet CIDR must fit inside its VPC CIDR.
3. Create an OpenSSL root CA and use it to sign server certificates with the required Subject Alternative Names.
4. Import the appropriate listener certificates into ACM in each ALB’s region.
5. Store each EC2 certificate bundle in its intended regional Secrets Manager secret.
6. Create the web-server IAM role, trust policy, permissions policy and instance profile.
7. Launch EC2 with that instance profile. Bootstrap retrieves the certificate bundle, installs it with restricted file permissions and configures the HTTPS web service.
8. Create the ALB, HTTPS listener, HTTPS target group and suitable health checks.
9. Verify the regional application before testing global routing.
10. Create a public hosted zone, delegate the domain to its assigned name servers and create the geolocation alias records.
11. Test DNS, certificate validation, backend health and the page’s regional identifier.
12. Repeat tests using Urban VPN and record the observed region and resolver behavior.

This is a dependency workflow. DNS can resolve successfully while the application is broken; a server can also work locally while its ALB target remains unhealthy.

### Request workflow

1. My browser asks its recursive DNS resolver for the application hostname.
2. On a cache miss, the resolver queries the authoritative Route 53 name servers.
3. Route 53 applies the matching geolocation rule and returns the selected ALB’s IP addresses through its alias record.
4. The browser establishes HTTPS with that ALB and validates its certificate.
5. The ALB terminates the browser’s TLS connection.
6. The ALB creates a separate HTTPS connection to the selected EC2 target.
7. The web server returns its response through the ALB.

Route 53 is outside the HTTP data path. Requests do not pass through Route 53, ACM or Secrets Manager.

## 3. Geolocation routing

Geolocation routing applies explicit rules for continents, countries or US states. I decide which regional endpoint should serve each location.

**Illustrative rules only:**

| Query location | Selected destination |
| --- | --- |
| Asia | Singapore ALB — ap-southeast-1 |
| Europe | London ALB — eu-west-2 |
| North America | Northern California ALB — us-west-1 |
| Unmatched or unidentified location | A designated default ALB |

An AWS Region does not automatically determine a record’s audience. A Singapore ALB serves Asian DNS queries only if my rules assign those queries to it.

When rules overlap, the most specific geographic rule takes priority. A country rule takes priority over a continent rule. A default record handles unmatched or unidentified locations; without one, those queries can receive no answer. [1]

### How Route 53 estimates location

If the resolver supports EDNS Client Subnet, it can send part of the client’s IP address for location estimation. Otherwise, Route 53 uses the resolver’s source IP address. This means the routing result can reflect the resolver’s location rather than my physical location. [2]

For Urban VPN testing, I must consider whether DNS travels through the VPN. A browser VPN may change web traffic without changing system DNS; browser DNS-over-HTTPS and cached answers can also affect the result. A country shown by the VPN is supporting context, not sufficient proof of the DNS decision.

### Related routing policies

| Policy | Basis for endpoint selection |
| --- | --- |
| Geolocation | Explicit continent, country or US-state rules |
| Latency | AWS latency measurements for candidate regions |
| Weighted | Configured relative weights across DNS answers |
| Failover | Primary/secondary behavior with health evaluation |

Geolocation alone does not guarantee the lowest latency or disaster recovery. Target-group health checks and Route 53 health evaluation are separate mechanisms. A default geographic record is principally a coverage rule; recovery behavior depends on the complete health-aware configuration.

## 4. IAM policy, role and instance profile

These are separate objects:

| Object | Question it answers |
| --- | --- |
| Trust policy | Who can assume this role? |
| Permissions policy | Which AWS actions can the role perform on which resources? |
| IAM role | Which AWS identity does my workload use? |
| Instance profile | How is that role attached to EC2? |

The web-server role trusts the EC2 service. The instance profile contains that role and is attached to the instance or launch template. Applications obtain temporary role credentials through EC2 instance metadata; the AWS CLI and SDK can use and refresh them automatically. [3]

I do not need a named AWS CLI profile or static IAM-user keys on the web server. A CLI profile used on my workstation is different from an EC2 instance profile.

### Illustrative EC2 trust policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
```

### Illustrative secret-reading policy

Replace the example ARN with the exact deployed secret ARN.

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "ReadWebCertificateBundle",
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:ap-southeast-1:111122223333:secret:lab7/web-tls-AbCdEf"
  }]
}
```

For a customer-managed KMS key, the role also needs authorized use of that key for `kms:Decrypt`; the key policy must allow the access. An extra explicit KMS permission is not required merely because the secret uses the AWS-managed `aws/secretsmanager` key. [4]

Systems Manager permissions support management of the instance. They do not replace permission to read Secrets Manager.

IAM authorization and network connectivity must both work. A private instance needs a path to the Secrets Manager API, such as NAT egress or an interface VPC endpoint. SSM likewise needs its agent, permissions and service connectivity.

## 5. Public DNS records and delegation

A public hosted zone contains the authoritative records for my domain.

| Record or setting | Purpose |
| --- | --- |
| Registrar name-server delegation | Directs DNS resolution to the hosted zone’s name servers |
| NS | Identifies the authoritative name servers |
| SOA | Contains zone authority and maintenance information |
| A alias | Resolves an IPv4 application name through an ALB alias target |
| AAAA alias | Provides IPv6 resolution when the ALB configuration supports it |
| ACM validation CNAME | Proves domain ownership when requesting an ACM-issued certificate using DNS validation |

Creating a hosted zone is separate from delegating the domain. I update the registrar with the name servers assigned to the intended hosted zone. If multiple hosted zones share a domain name, only the delegated zone is authoritative for public resolution.

For geolocation, records for the application share the same hostname and type, but have distinct identifiers, geographic rules and ALB targets.

An A alias can target an ALB at either the root domain or a subdomain. I reference the ALB rather than manually storing its current IP addresses. [5]

DNS does not configure HTTPS, security groups or the web service. A working DNS answer proves name resolution only.

My lab imported OpenSSL-issued certificates into ACM. DNS-validation CNAME records relate to ACM-issued certificates; importing my own certificate does not make its private CA publicly trusted.

## 6. AWS Secrets Manager

Secrets Manager stores sensitive values and controls retrieval with AWS authorization. In this lab, the EC2 certificate bundle includes the private key, which is the sensitive part.

An illustrative JSON structure is:

```json
{
  "certificate_pem": "<server certificate>",
  "private_key_pem": "<server private key>",
  "chain_pem": "<CA certificate chain>"
}
```

The actual secret may use a different structure. The bootstrap script and the stored value must agree on field names and format.

Secrets Manager encrypts values at rest using KMS. When authorized retrieval occurs, it decrypts the value and returns it over the protected API connection. The server must still protect the resulting local files. [6]

### Bootstrap workflow

1. Obtain temporary credentials from the attached IAM role.
2. Call `GetSecretValue` using the correct secret identifier and region.
3. Parse the bundle without printing its private key.
4. Install certificate and key files with suitable ownership.
5. Restrict the private key to the service account or root as required.
6. Validate the web-service configuration.
7. Start or reload the service and check its health.

A secret update does not automatically refresh files already installed on EC2. Certificate rotation requires a retrieval, installation and service-reload mechanism. Secrets Manager also does not issue certificates or serve application HTTPS.

ACM holds the ALB listener certificate in this design; Secrets Manager holds the bundle deployed on EC2. The root CA certificate can be shared for trust, but the root CA private key should remain protected outside the web-server bundle.

If Terraform manages secret values, those values may appear in state even when marked sensitive. Keep state access restricted and exclude state, private keys and secret-bearing files from Git.

## 7. HTTPS and certificate trust

There are two independent TLS connections:

| Connection | Certificate location | Validation behavior |
| --- | --- | --- |
| Client to ALB | ACM | The client checks hostname, validity and trust chain |
| ALB to EC2 | Web-server files, retrieved from Secrets Manager | ALB encrypts the connection but does not validate the target certificate |

An HTTPS listener alone encrypts only the client-facing connection. The target group must use HTTPS, and the backend must serve TLS on its configured port, to encrypt the backend connection.

AWS documents that ALBs do not validate HTTPS target certificates. A healthy target therefore does not prove that the backend certificate’s name, expiry or CA chain is valid. [7]

Because my lab uses a private root CA, my test client must trust that CA. Importing the certificate into ACM does not establish browser trust. TLS is terminated and re-established at the ALB; this design is not TLS passthrough.

## 8. Testing and troubleshooting

Use the actual application hostname in place of `app.example.com`.

```bash
dig NS example.com
dig app.example.com A
curl --cacert ./lab-root-ca.crt https://app.example.com/
```

The curl command checks certificate trust and hostname matching while requesting the page. Using `curl -k` bypasses certificate verification and cannot provide the same evidence.

| Check | Evidence I look for |
| --- | --- |
| Delegation | Public NS answer matches the intended hosted zone |
| DNS routing | Answer corresponds to the intended regional endpoint |
| Application | Page displays an unambiguous regional identifier |
| Client TLS | Request succeeds with trusted CA and hostname validation |
| Backend | Correct HTTPS service port and healthy ALB targets |
| IAM | Instance has its role and can retrieve its intended secret |
| Geographic behavior | VPN location, DNS behavior and observed page region are recorded |

A regional identifier is stronger application evidence than an HTTP 200 response alone.

| Symptom | Investigation |
| --- | --- |
| Wrong region | Check location rules, resolver/ECS behavior, DNS cache and VPN DNS handling |
| No DNS answer | Check delegation, record name/type and default coverage |
| Certificate failure | Check SAN, client trust, validity and selected ALB certificate |
| Secret access denied | Check instance role, exact secret ARN and KMS authorization |
| Secret retrieval timeout | Check region, routing, API endpoint access and security groups |
| Unhealthy target or ALB error | Check backend protocol/port, service configuration, certificate files and health-check path |

## 9. Key takeaways

- Route 53 chooses the regional DNS endpoint; an ALB chooses a backend target.
- Geographic rules are explicit and depend on the DNS location signal.
- Public delegation makes the intended hosted zone authoritative.
- An EC2 instance profile attaches a role; it is different from an AWS CLI profile.
- IAM permissions grant service access; network connectivity enables the API call.
- Secrets Manager distributes protected values; the server uses local certificate files for TLS.
- ACM import does not make a private CA publicly trusted.
- Successful DNS, HTTP, TLS and health checks prove different parts of the system.

## AWS documentation

1. [Geolocation routing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html)
2. [EDNS Client Subnet and location estimation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-edns0.html)
3. [IAM roles for Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
4. [GetSecretValue permissions](https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html)
5. [Routing traffic to an ELB load balancer](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html)
6. [Secrets Manager encryption](https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html)
7. [ALB target groups and backend TLS](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)

