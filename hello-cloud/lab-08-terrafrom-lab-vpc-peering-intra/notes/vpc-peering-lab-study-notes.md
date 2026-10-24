# Frontend--Backend VPC Peering Lab

## 1. Overview

This lab provisions separate frontend and backend environments in AWS
using Terraform and HCP Terraform. Each environment is divided into
network, security, and compute workspaces. A dedicated
`vpc-peering-fe-be` workspace establishes private connectivity between
the frontend and backend VPCs.

The lab demonstrates:

-   Modular infrastructure management with separate Terraform
    workspaces.
-   VPCs, subnets, Internet Gateways, route tables, subnet associations,
    and NAT Gateway resources.
-   Security groups that control which workloads can communicate.
-   VPC Peering and routing between frontend and backend networks.
-   Sharing selected infrastructure outputs between HCP Terraform
    workspaces.
-   Connectivity testing with `ping` and SSH.

> **Scope:** This document describes the architecture and test results
> recorded in the lab notes. Where the notes do not include exact
> Terraform resource definitions or complete route tables, examples are
> illustrative and should be checked against the actual configuration
> before use.

## 2. Architecture and workspace design

### 2.1 Workspace responsibilities

  -----------------------------------------------------------------------
  HCP Terraform workspace             Responsibility
  ----------------------------------- -----------------------------------
  `fe-network-ws`                     Frontend VPC, subnets, Internet
                                      Gateway, route tables, subnet
                                      associations, and NAT Gateway
                                      resources

  `fe-security-ws`                    Frontend security groups

  `fe-compute-ws`                     Frontend EC2 instances and SSH key
                                      pair

  `be-network-ws`                     Backend VPC, subnets, Internet
                                      Gateway, and route tables

  `be-security-ws`                    Backend security groups

  `be-compute-ws`                     Backend EC2 instances and SSH key
                                      pair

  `vpc-peering-fe-be`                 VPC peering connection and the
                                      routes required for inter-VPC
                                      communication
  -----------------------------------------------------------------------

This separation gives each workspace a focused responsibility and allows
networking, security, compute, and peering changes to be managed
independently.

### 2.2 Network layout

The lab uses private IP addresses from two separate VPC address ranges.
The recorded examples include frontend addresses in `10.0.0.0/16` and
backend addresses in `192.168.0.0/16`.

Each environment includes a public instance used as an SSH entry point
and private instances in private subnets. The peering connection
provides a private network path between the VPCs; it does not, by
itself, configure routing or authorize traffic.

``` text
Frontend VPC (10.0.0.0/16)
├── Public subnet
│   └── Public EC2 / bastion
└── Private subnets
    ├── Private EC2 01
    ├── Private EC2 02
    └── Private EC2 03
             |
             | VPC Peering
             |
Backend VPC (192.168.0.0/16)
├── Public subnet
│   └── Public EC2 / bastion
└── Private subnets
    ├── Private EC2 01
    ├── Private EC2 02
    └── Private EC2 03
```

The actual subnet CIDRs and subnet-to-route-table associations should be
taken from the deployed environment or Terraform outputs; they are not
all specified in this summary.

## 3. Terraform workflow

The lab uses the following standard workflow for each workspace:

``` bash
terraform login
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying changes. `terraform apply -auto-approve`
is used in some lab steps, but interactive approval is preferable when
reviewing infrastructure changes, especially for networking and security
resources.

### 3.1 Workspace dependencies and outputs

The compute and security workspaces consume network information produced
by the network workspaces. The peering workspace consumes outputs from
both frontend and backend network workspaces and, in the lab setup, has
access to outputs from both security workspaces.

The notes configure HCP Terraform remote-state sharing for these
workspace relationships.

When designing a production workflow, share only the outputs that a
downstream workspace needs. Where appropriate, use the HCP Terraform
`tfe_outputs` data source to read explicitly published outputs rather
than granting broader state access. Ensure that output sensitivity and
workspace permissions are configured deliberately.

Typical network outputs include:

-   VPC ID
-   VPC CIDR block
-   Relevant route table IDs
-   Subnet IDs needed by compute or other dependent workspaces

Use the actual output names declared in each workspace; names above are
conceptual.

## 4. VPC Peering

### 4.1 Purpose

VPC Peering enables resources in two VPCs to communicate using private
IP addresses, subject to routing and security controls.

In this lab, the `vpc-peering-fe-be` workspace is responsible for the
peering connection between the frontend and backend VPCs and for adding
routes that direct traffic for the peer VPC through that connection.

### 4.2 Required configuration

A working peering path requires all of the following:

1.  Create the peering connection between the correct VPC IDs.
2.  Accept the peering request if it is pending and acceptance is
    required.
3.  Add a route to the peer VPC CIDR in the relevant frontend route
    tables.
4.  Add a return route to the frontend VPC CIDR in the relevant backend
    route tables.
5.  Confirm that the route tables are associated with the subnets used
    by the instances.
6.  Confirm that security groups and network ACLs permit the intended
    traffic.
7.  Test the specific source-to-destination path and application port.

A peering connection can be active while traffic still fails because
routes or security rules are missing.

### 4.3 Route-table design

A route table determines the next hop for traffic based on the
destination IP address. For this lab, the essential entries are:

  -----------------------------------------------------------------------
  Route destination       Target                  Purpose
  ----------------------- ----------------------- -----------------------
  Frontend VPC CIDR, such `local`                 Routes traffic within
  as `10.0.0.0/16`                                the frontend VPC

  Backend VPC CIDR, such  VPC peering connection  Routes frontend traffic
  as `192.168.0.0/16`     (`pcx-...`)             to the backend VPC

  Backend VPC CIDR        `local` in backend      Routes traffic within
                          route tables            the backend VPC

  Frontend VPC CIDR       VPC peering connection  Provides the return
                          (`pcx-...`)             route from backend to
                                                  frontend
  -----------------------------------------------------------------------

Public-subnet internet routes commonly use an Internet Gateway.
Private-subnet outbound internet access, when required, commonly uses a
NAT Gateway route. These internet routes are separate from the peer-CIDR
routes.

**Important:** Add the peer route to the route tables associated with
the subnets that actually need to communicate. Adding a route to an
unused route table does not provide connectivity for a subnet associated
with a different table.

### 4.4 Peering limitations

-   VPC CIDR ranges must not overlap for standard VPC peering.
-   VPC Peering is non-transitive. If VPC A peers with VPC B and VPC B
    peers with VPC C, A cannot use B's peering connection as a transit
    path to C.
-   Peering does not automatically update route tables.
-   Peering does not bypass security groups, network ACLs, or host
    firewalls.
-   Peering provides private connectivity; it does not automatically
    provide internet access to private instances.

## 5. Least-privilege security

The lab uses separate security workspaces for frontend and backend
security groups. Security policy should allow only the traffic required
for the intended application and administration paths.

### 5.1 Security-group design principles

-   Permit SSH (TCP 22) to a public bastion only from trusted
    administrative source IPs where possible.
-   Permit SSH to private instances from the bastion security group
    rather than opening TCP 22 to the internet.
-   Permit application traffic between frontend and backend workloads
    only on the required ports and from the required source workloads or
    CIDRs.
-   Avoid broad rules such as all protocols from `0.0.0.0/0` unless
    there is a justified requirement.
-   Restrict outbound traffic where the workload's operational needs
    allow it.
-   Review security-group rules whenever a new route or peering path is
    introduced.

A route makes a network path available; a security group determines
whether traffic is allowed at the instance network interface. Both must
be correct.

### 5.2 Security groups versus network ACLs

  -----------------------------------------------------------------------
  Control                 Scope                   Behavior
  ----------------------- ----------------------- -----------------------
  Route table             Subnet routing decision Chooses a target for
                                                  destination traffic

  Security group          Network interface /     Stateful; response
                          instance traffic        traffic for an allowed
                                                  connection is tracked

  Network ACL             Subnet boundary         Stateless; inbound and
                                                  outbound rules must
                                                  allow the required
                                                  flows

  Host firewall           Operating system        Can independently allow
                                                  or block traffic on the
                                                  instance
  -----------------------------------------------------------------------

A failed `ping` is not enough to identify which control blocked traffic.
ICMP may be disallowed even when an application port works. Test the
actual protocol and port required by the workload.

### 5.3 Credential handling

The original lab notes describe adding AWS access key and secret access
key values to workspace variables. For ongoing or production use, prefer
short-lived credentials through HCP Terraform dynamic provider
credentials / OIDC where supported, with an IAM role scoped to the
workspace's responsibilities.

Do not commit AWS credentials or SSH private keys to GitHub. Treat
private keys as secrets, protect Terraform state, and rotate any key
whose private material has been exposed.

## 6. SSH access pattern

The lab uses public instances as SSH entry points to reach private
instances. A local SSH client configuration can use `ProxyJump` to
traverse the bastion without making private instances directly reachable
from the internet.

Example pattern (replace hostnames, addresses, usernames, and key paths
with the deployed values):

``` sshconfig
Host backend-bastion
    HostName <BASTION_PUBLIC_IP>
    User ec2-user
    IdentityFile ~/.ssh/be-private-ssh-keypair.pem
    IdentitiesOnly yes

Host backend-private-01
    HostName <PRIVATE_01_IP>
    User ubuntu
    IdentityFile ~/.ssh/be-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump backend-bastion
```

Connect with:

``` bash
ssh backend-private-01
```

The private key is required on the client initiating SSH. The
destination instance needs the corresponding public key installed for
the target operating-system user. Copying the private key onto every
private instance is generally unnecessary and increases the number of
systems holding a sensitive credential.

Ubuntu AMIs normally use the `ubuntu` SSH username; Amazon Linux
normally uses `ec2-user`. Confirm the AMI and configured username when
troubleshooting authentication.

## 7. Validation and recorded lab results

The notes record the following tests:

  -----------------------------------------------------------------------
  Test                    Recorded result         What it demonstrates
  ----------------------- ----------------------- -----------------------
  Local PC to frontend    Ping and SSH succeeded  Public reachability and
  public instance                                 administrative SSH
                                                  access worked at test
                                                  time

  Frontend public         Ping succeeded          The tested path to
  instance to frontend                            private instance 01 was
  private instance 01                             reachable

  Frontend public         Ping failed             The tested ICMP paths
  instance to private                             were blocked or
  instances 02 and 03                             otherwise unavailable,
                                                  as expected by the
                                                  notes

  Frontend private        Ping succeeded          The tested
  instance 01 to frontend                         intra-frontend private
  private instances 02                            paths worked
  and 03                                          

  Frontend private        Ping succeeded          The tested cross-VPC
  instance 02 to backend                          path worked
  private instance 02                             

  Frontend private        Ping failed             The tested path was
  instance 03 to backend                          denied or unavailable
  private instance 02                             as expected by the
                                                  notes

  Backend private         Ping succeeded          The tested
  instance 01 to backend                          intra-backend private
  private instances 02                            paths worked
  and 03                                          

  Backend private         Ping succeeded          The tested
  instance 02 to frontend                         reverse-direction
  private instance 02                             cross-VPC path worked
  -----------------------------------------------------------------------

These results are point-in-time observations from the lab notes. A
successful ping demonstrates ICMP reachability for that particular path
at the time of testing; it does not verify every application port or
prove that all routes and security policies are correct.

### 7.1 Recommended troubleshooting sequence

When a connection fails, check the layers in this order:

1.  **Addressing:** Confirm the destination private IP and VPC CIDRs.
2.  **Route tables:** Confirm the source subnet has a route to the
    destination CIDR and the destination has a return route.
3.  **Peering status:** Confirm the connection is active and the VPCs'
    CIDRs do not overlap.
4.  **Security groups:** Check the source, destination, protocol, and
    port.
5.  **Network ACLs:** Check inbound and outbound rules, including return
    traffic.
6.  **Host configuration:** Check the OS firewall, service status, SSH
    username, and `authorized_keys` as appropriate.
7.  **Test the actual service:** For SSH, use `nc -vz <private-ip> 22`
    or `ssh -vvv`; do not rely only on ping.

Useful commands:

``` bash
# Test ICMP reachability
ping <DESTINATION_PRIVATE_IP>

# Test TCP port 22 reachability
nc -vz -w 5 <DESTINATION_PRIVATE_IP> 22

# Inspect SSH authentication and connection details
ssh -vvv -i ~/.ssh/be-private-ssh-keypair.pem ubuntu@<DESTINATION_PRIVATE_IP>

# Derive the public key from a private key to validate that the file is readable
ssh-keygen -y -f ~/.ssh/be-private-ssh-keypair.pem
```

`ssh-keygen -y` should print a public key when the private key file is
valid. A key-format error is a client-side file problem;
`Permission denied (publickey)` means authentication was not accepted
and requires checking the key, username, and target's authorized public
key.

## 8. Operational considerations

-   **Private subnet internet access:** Private instances do not need
    direct public internet access for VPC Peering or SSH from a
    reachable bastion. Package installation and downloads may require
    NAT, VPC endpoints, or another approved path to the required
    services.
-   **NAT Gateway:** Use NAT only when private workloads need outbound
    IPv4 internet access. A NAT Gateway is not a substitute for VPC
    Peering and does not provide inbound internet connectivity to
    private instances.
-   **Terraform state:** The state may contain sensitive values,
    including generated private-key material. Marking an output
    `sensitive = true` hides it from normal display but does not remove
    it from state.
-   **Key rotation:** If private-key material has been exposed, replace
    it and ensure replacement instances or authorized-key configuration
    use the corresponding new public key.
-   **Change review:** Inspect `terraform plan` before applying route or
    security changes. A small route or rule change can alter
    connectivity across multiple subnets.

## 9. Summary

This lab demonstrates how to separate AWS infrastructure into Terraform
workspaces and connect frontend and backend VPCs through VPC Peering.
The critical implementation requirements are correct CIDR planning,
routes in both directions, subnet-to-route-table associations, and
security rules that allow only the intended traffic.

The most important operational lesson is to troubleshoot routing and
security separately: a peering connection alone does not guarantee
connectivity, and a successful ping proves only that one ICMP path
worked at the time of the test.
