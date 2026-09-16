---
title: Manual Dashboard and Counting Services
type: lab
project: CIE Session 1
lab: 1
status: in-progress
domain:
  - AWS
  - Linux
  - Networking
  - Security
tags:
  - aws
  - ec2
  - vpc
  - security-group
  - bastion
  - dashboard
  - counting
---

# Lab 1 - Manual Dashboard and Counting Services

> [!important]
> **Lab Goal**
>
>
> ```text
> Public User
>      ↓
> Dashboard Application
>      ↓
> Counting Application
> ```
>
> The Dashboard will be publicly reachable.
>
> The Counting application will remain private and will only accept application traffic from the Dashboard.
>
> Administrative SSH access will use a Bastion Host.

---

## Quick Navigation

- [[CIE Session 1]]
- [[#1. Objective]]
- [[[#2. PLanning and Design]]]
- [[#3. Implementation]]
- [[#4. Testing]]
- [[CIE Session 2]]

---

# 1.  Objective

Deploy three EC2 instances:

```text
1. Bastion Host
2. Dashboard Application Server
3. Counting Application Server
```

Run the applications manually:

```text
Dashboard server → dashboard application

Counting server → counting application
```

Then verify:

```text
Public User → Dashboard → Counting → esponse returned to user
```

---

# 2. Planning and Design

## AWS Infrastructure

- VPC
- Public subnet
- Private subnet
- Internet Gateway
- Route Tables
- 3 EC2 instances
- 3 Security Groups
- SSH key pair
	- Public IPv4/EIP where required
---

## 2.1. Target Architecture

![[Pasted image 20260916003825.png]]


---

## 2.2.  Network Plan


| VPC            | 172.20.0.0/16  |
| -------------- | -------------- |
| Public Subnet  | 172.20.1.0/24  |
| Private subnet | 172.20.11.0/24 |
| Bastion-Host   | 172.20.1.x/24  |
| Dashboard      | 172.20.2.x/24  |
| Coutning       | 172.20.11.x/24 |


---

## 2.3 . Public Subnet Requirements

The public subnet route table should include:

```text
Destination: 0.0.0.0/0
Target:      Internet Gateway
```

This allows resources with appropriate public addressing and Security Group rules to communicate with the Internet.

---

## 2.4. Private Subnet

The Counting server does not need direct public inbound access.

Therefore:

```text
Counting EC2 → Private Subnet → Private IPv4
```

For the first lab, the main goal is inbound application connectivity from Dashboard and SSH management through Bastion.

> [!note]
> If the Counting server needs outbound Internet access for package installation, you would normally add NAT or use another controlled mechanism. That is separate from the core application-flow lesson.

---

## 2.5. Security Group Design

Use three Security Groups:

```text
SG-Bastion
SG-Dashboard
SG-Counting
```

---

### 2.5.1. SG-Bastion

## Inbound

Allow SSH only from your trusted public IP.

```text
Protocol: TCP / Port: 22 / Source:   PUBLIC_IP/32
```


> [!warning]
> Avoid:
>
> ```text
> SSH 22 from 0.0.0.0/0
> ```
>
> unless there is a specific temporary lab reason and you fully understand the risk.

---

## Outbound

For a basic learning lab, AWS default outbound may be left temporarily. A stricter design can reduce outbound rules later.

---

### 2.5.2. SG-Dashboard

## Inbound (Application)

Allow users to reach the Dashboard application.

Example if Dashboard listens on TCP 8000:

```text
Protocol: TCP
Port:     8000
Source:   0.0.0.0/0
```

If the Dashboard uses HTTP: 

```text
TCP 80
```

If HTTPS:

```text
TCP 443
```

Use the actual application port.

---

## Inbound  - SSH Management

Allow:

```text
TCP 22
Source: SG-Bastion
```

Meaning: Only instances associated with SG-Bastion can reach Dashboard on SSH

---

### 2.5.3. SG-Counting

## Inbound - Counting Application

Allow the Counting application only from Dashboard.

Example:

```text
Protocol: TCP
Port:     8000
Source:   SG-Dashboard
```

This is better than:

```text
TCP 8000
Source 0.0.0.0/0
```

because Counting is not intended for public users.

---

## Inbound - SSH Management

Allow:

```text
TCP 22
Source: SG-Bastion
```

---

### 2.5.4. Minimum-Privilege Rule Summary

| Destination |               Port | Source             | Purpose     |
| ----------- | -----------------: | ------------------ | ----------- |
| Bastion     |                 22 | my public IP `/32` | Management  |
| Dashboard   | Dashboard app port | Public users       | Application |
| Dashboard   |                 22 | SG-Bastion         | Management  |
| Counting    |  Counting app port | SG-Dashboard       | Application |
| Counting    |                 22 | SG-Bastion         | Management  |

---
# 3. Implementation 
1. Create the VPC

```text
Name: roy-vpc-1

CIDR: 172.20.0.0/16
```

![[Pasted image 20260908185102.png]]

---
2.  Create Public Subnet

```text
Name: public-subnet-1

CIDR: 172.20.1.0/24
```
![[Pasted image 20260908185547.png]]

3. Create Security Group
	3.1 baston-host-sg

```text
name = bastion-host-sg
vpc id = roy-vpc-1
inbound rule: type=ssh, protocol = TCP, soruce = my public ip, descriptoin = Allows dedicated User
outbound rule: no rule
```
![[Pasted image 20260908191403.png]]

	3.2 dashboard-app-sg
```text
name = dashboard-app-sg
vpc id = roy-vpc-1
inbound rule: 
rule 1: type = tcp, Port = 9000, soruce = 0.0.0.0/0 
rule 2: type=ssh, protocol =-TCP, soruce = baston-host-sg
outbound rule: no rule
```

![[Pasted image 20260908191731.png]]

	3.2  counting-app-sg
	
```text
name = counting-app-sg
vpc id = roy-vpc-1
inbound rule: 
rule 1: type=ssh, protocol =-TCP, soruce = baston-host-sg
outbound rule: no rule
```

![[Pasted image 20260908220949.png]]

4. Create Internet Gateway
```text
name = roy-vpc-1-igw
```
![[Pasted image 20260908192234.png]]
	
	4.1 IGW attached to VPC
	
![[Pasted image 20260908194005.png]]

5.  Create Public Routing Table
```text
name = roy-public-rt-1
vpc - roy-vpc-1
```
![[Pasted image 20260908192526.png]]

	5.1 Associate with Public Subnet 

![[Pasted image 20260908194927.png]]

6. Configure Public Route Table
```text
destination = 0.0.0.0/0
target = igw 
```

![[Pasted image 20260908194049.png]]

7. Allocate EIP and Associate with Instance (Bastion-Host , Dashboard)

```text 
public ipv4 address pool
Network border group = ap-southeast-1
Tags optional
Name = bastion-host-eip
Name = dashboard-app-eip
```

![[Pasted image 20260909003927.png]]

![[Pasted image 20260909004950.png]]

8. Launch Bastion-Host Server
	8.1 Create Key-Pair

```text
name = bastion-key-pair
type = rsa
```
![[Pasted image 20260908190114.png]]
	
	8.2 app-server-keypair

```text
name = app-server-key-pair
type = rsa
```

![[Pasted image 20260908212258.png]]
	
	8.3 Create Bastion-host (EC2)
```text
name = bastion-host
AMI = ubuntu server 26.04 LTS (HVM)
Instance type = t3.micro
Key pair = bastion-key-pair
vpc = roy-vpc-1
subnet = public-subnet-1
auto-assign public ip = disable
security group= bastion-host-sg

```

```text
Role = Management Entry 
```
![[Pasted image 20260908210124.png]]
---
	8.4  Launch dashboard-app-server (EC2)

```text
ame = dashboard-app-server
AMI = ubuntu server 26.04 LTS (HVM)
Instance type = t3.micro
Key pair = bastion-key-pair
vpc = roy-vpc-1
subnet = public-subnet-1
auto-assign public ip = disable
security group= dashboard-sg
```

![[Pasted image 20260908212448.png]]


9. Create Private Subnet

```text
Name:private-subnet-1
Zone = ap-southeast-1b

CIDR: 172.20.2.0/16
```
![[Pasted image 20260908194706.png]]

10. Create Route Table for private subnet

```text
name = roy-private-rt-1
vpc = roy-vpc-1
```
![[Pasted image 20260908213312.png]]
---
10.1  Associate Route table with private subnet 

![[Pasted image 20260908213503.png]]


11. Create Nat Gateway

```text
name = counting-nat-gw (optional)
availability mode = zonal 
subnet = public-subnet-1
connectivity type = public
elastic ip allocation = automatic

```
![[Pasted image 20260909012242.png]]

11. Attach NAT to private route table
```text

```
![[Pasted image 20260909012151.png]]

> [!important]
> Traffic between VPC subnets uses the VPC local route. You do not need an Internet Gateway for Dashboard-to-Counting private communication.

12. Launch Counting Server


```text
ame = counting-app-server
AMI = ubuntu server 26.04 LTS (HVM)
Instance type = t3.micro
Key pair = app-keypair
vpc = roy-vpc-1
subnet = private-subnet-1
auto-assign public ip = disable
security group= counting-sg
```


![[Pasted image 20260908221711.png]]


13.  Connect to Bastion
	 13.1 Change Prviate Key-pair's permission

```bash
!chmod 400 private-key-pair.pem
```
![[Pasted image 20260909012755.png]]

From  local machine:

```bash
ssh -i <key>.pem ubuntu@<BASTION_PUBLIC_IP>
```

![[Pasted image 20260909012931.png]]


---

	13.2 SSH from Bastion to Dashboard

```text
private key(app-key-pair) of dashboard server add to bastion-host sever
allow outbound rules of  SSH (baston-sg) to destination dashboard-sg
```

```bash
ssh -i private-key.pem ubuntu@<DASHBOARD_PRIVATE_IP>
```

![[Pasted image 20260909015849.png]]

>[!Note] 
>Depending on your SSH/key setup, you may use:
>
>```text
SSH agent forwarding
a separate key on Bastion
ProxyJump


> [!warning]
> Avoid casually copying long-lived private SSH keys onto Bastion hosts in real production environments.

---

	13.4 SSH from Bastion to Counting


```text
Security Group
outbound at Bastion:
ssh allow to destination to counting-sg
inbound at counting-app-server
ssh allow from soruce bastion-host-sg
```

```bash
ssh -i private-key.pem ubuntu@<DASHBOARD_PRIVATE_IP>
```

![[Pasted image 20260909020239.png]]

---

14.  Download Dashboard application to dashboard-app-server

Main repo in github : https://github.com/hashicorp/demo-consul-101/releases

Files To download at dashboard-server: 
https://github.com/hashicorp/demo-consul-101/releases/download/v0.0.5/dashboard-service_linux_amd64.zip
https://github.com/hashicorp/demo-consul-101/archive/refs/tags/v0.0.5.zip

```bash 
curl -LO https://github.com/hashicorp/demo-consul-101/releases/download/v0.0.5/dashboard-service_linux_amd64.zip

curl -L https://github.com/hashicorp/demo-consul-101/archive/refs/tags/v0.0.5.zip

sudo apt install unzip

unzip dashboard-service_linux_amd64.zip

rm dashboard-service_linux_amd64.zip
mv dashboard-service_linux_arm64 dashboard
```


15. Run Dashboard Application Manually 

```bash
chmod +x dashboard

PORT=9000 ./dashboard

```


![[Pasted image 20260909025046.png]]

![[Pasted image 20260909025906.png]]
---

16.  Start Counting Application Manually

On Counting server:

Main repo in github : https://github.com/hashicorp/demo-consul-101/releases

```bash
curl -LO https://github.com/hashicorp/demo-consul-101/releases/download/v0.0.5/counting-service_linux_amd64.zip

curl -LO https://github.com/hashicorp/demo-consul-101/archive/refs/tags/v0.0.5.zip

sudo apt install unzip

unzip counting-service_linux_amd64.zip

rm counting-service_linux_amd64.zip
mv counting-service_linux_arm64 counting


```

17. Run Counting Service 


```bash
PORT=800 ./conting
```
![[Pasted image 20260909111023.png]]

	17.1 Vefiy  Counting Service is running

```bash
ss -lntp | grep 8000
```

Result:  listening on port 8000

![[Pasted image 20260909115508.png]]

---

Local test:

```bash
curl http://127.0.0.1:8000

or 

curl http://localhost:8000
```

---

18. Verification Connectivity ( Dashboard → Counting Connectivity)

From Dashboard:

```bash
curl http://<COUNTING_PRIVATE_IP>:8000
```

The result = fail
![[Pasted image 20260909120752.png]]

	18.1 After adding outbund rule from dashboard-app-sg and inbound rule in counting-app-sg:

the result is success:s

![[Pasted image 20260909120921.png]]
Success proves:

```text
Success proves:

Route
+
Security Group
+
Listening Application

are working
```

---

19.  Connectivity Reasoning

For Dashboard to reach Counting from User:
![[Pasted image 20260916163322.png]]

---

20. Configure Dashboard Upstream

Dashboard needs to know the Counting endpoint.

Example configuration:

```text
PORT="dashboard_port" COUNTING_SERVICE_URL="http://coutning_private_ip:counting_port" ./dashboard
```

Example:

```bash
	PORT=9000 COUNTING_SERVIE_URL="http://172.20.2.154:8000" ./dashboard
```



[[Lab 2]] will later evolve this architecture.

---

21.  Public User Test

From your local machine/browser:

```text
http://<DASHBOARD_PUBLIC_IP>:<DASHBOARD_PORT>
```

# 4. Testing

1. That Counting Is Not Publicly Reachable
2. Test SSH Isolation
Expected:

```text
Local Laptop
   ↓
Counting private IP
   ✕
No direct Internet path
```

Instead:

```text
Laptop
 ↓
Bastion
 ↓
Counting
```

---

3. Failure Test — Stop Counting Application

On Counting:

```text
Ctrl+C
```

Then from Dashboard:

```bash
curl http://<COUNTING_PRIVATE_IP>:8000
```

Expected: connection fails

This demonstrates:

```text
Network may be healthy
but application process is down
```

---

4. Failure Test - Restart Counting Manually

Run again: Counting service
	Dashboard should be able to reach it again.

>[!Note]
This exposes the Lab 1 weakness:
>
```text
Application stopped
      ↓
Human must restart manually
```

[[01 Hello-Cloud/03 CIE-Lab/CIE-Lab-2]]  solves this using:

```text
systemd
```

5. Failure Test  - Stop Dashboard Application

Stop Dashboard: Ctrl+C
Public user access fails.

Restart manually: 
Again:

```text
Manual dependency
```

This becomes the motivation for [[01 Hello-Cloud/03 CIE-Lab/CIE-Lab-2]].

---

6.  Important IP Test

Record before stop/start:

```text
Dashboard private IP:
Dashboard public IP:

Counting private IP:
```

Stop and start the Dashboard EC2 if appropriate.

Check again:

```text
Dashboard private IP:
Dashboard public IP:
```

Observe:

```text
Primary private IP
usually remains

Auto-assigned public IPv4
may change after stop/start
```

> [!important]
> Do not assume all EC2 IP addresses behave the same way.

---

# 5 Application Endpoint in This Lab

The Dashboard reaches Counting using: Private IP + Port

Example:

```text
10.0.2.20:8000
```

This is easy for learning but creates a future problem:

```text
Counting instance replaced
       ↓
Endpoint may change
       ↓
Dashboard configuration may need change
```

This leads into:

```text
Service Discovery
Load Balancing
Stable Endpoints
```

---

# 5.1. Why This Is Not Yet High Availability

Current design:

```text
Dashboard = 1 instance
Counting  = 1 instance
Bastion   = 1 instance
```

Therefore:

```text
Dashboard failure → user service unavailable
```

and:

```text
Counting failure → Dashboard upstream function unavailable
```

These are Single Points of Failure (SPOF)

Later labs improve this.

---

# 6. Troubleshooting  Dashboard Cannot Reach Counting

Check in this order:

```text
1. Is Counting application running?
2. Is it listening on correct port?
3. Is it listening on correct interface?
4. Is Dashboard using correct Counting private IP?
5. Is SG-Counting allowing app port from SG-Dashboard?
6. Are both instances in the VPC?
7. Is the VPC local route present?
8. Is a host firewall blocking traffic?
```

Commands:

```bash
sudo ss -lntp
```

```bash
curl http://127.0.0.1:8000
```

```bash
curl http://<COUNTING_PRIVATE_IP>:8000
```

---

## 6.1 Troubleshooting  Cannot SSH to Bastion

Check:

```text
Bastion has public IPv4/EIP?
Public subnet has IGW route?
SG-Bastion allows TCP 22 from your public IP /32?
Correct username?
Correct SSH key?
Key file permissions?
```

Example:

```bash
chmod 400 key.pem
ssh -i key.pem ubuntu@<BASTION_PUBLIC_IP>
```

---

## 6.2 Troubleshooting — Bastion Cannot SSH to Private EC2

Check:

```text
Correct private IP?
Target SG allows TCP 22 from SG-Bastion?
Correct SSH key/agent setup?
Target instance is running?
Target OS username correct?
```

---

## 6.3 Troubleshooting — Dashboard Not Publicly Reachable

Check:

```text
Dashboard has public IP?
Public subnet route to IGW?
SG-Dashboard allows application port?
Application listening on 0.0.0.0 rather than only 127.0.0.1?
Correct browser URL and port?
```

Check:

```bash
sudo ss -lntp
```


---

# 53. GitHub Evidence Structure

Recommended:

```text
projects/
└── cie-session-1/
    ├── README.md
    ├── diagrams/
    ├── docs/
    │   └── lab-1.md
    ├── evidence/
    └── terraform/
```

If Session 1 is built manually first, Terraform can be added later as a second implementation.


---

# 55. Interview-Style Explanation

## Question

How did you design the Dashboard and Counting application infrastructure?

## Answer

I separated the public-facing Dashboard from the backend Counting service.

The Dashboard was placed in a public subnet for this learning architecture because users needed direct access to it. The Counting service was placed in a private subnet because users did not need to access it directly.

For application traffic, the Dashboard Security Group was allowed to reach the Counting application port. For management traffic, I used a Bastion Host and allowed SSH from the Bastion Security Group to both application servers.

This separated application traffic from management traffic and reduced unnecessary public exposure of the backend service.

At this stage, both applications were started manually and Dashboard used the Counting server's private IP and port as a static endpoint. Those limitations became the starting point for Session 2, where I introduced systemd, dedicated service users, load balancing, health checks, and Auto Scaling.


---
