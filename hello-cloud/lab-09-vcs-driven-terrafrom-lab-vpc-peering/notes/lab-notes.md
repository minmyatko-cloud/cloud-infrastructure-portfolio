# 1. Prerequisites 

1. Terrafrom.tf files are ready for vpc-peering (which are implemented in previouls lab 08)
2. Copy these terrafrom code into new dir (vpc-peering-vcs-driven)

![tf-configuratoin-files](../evidences/terrafrom-configuration-files.png)


# 2. Configure GitHub main branch protection and add collaborators

1. Open your GitHub repository
2. Settings → Rules → Rulesets → New branch ruleset
3. Configure the following settings.

    Recommended ruleset

    Ruleset name: main-branch-protection

    Target branches: Include default branch main

    Enforcement status: Active

Enable these rules
[x] Require a pull request before merging
*Prevents direct changes to main through normal pushes.*

[x] Require approvals
*Set to 1 approval if you have a reviewer available.*

[x] Dismiss stale pull request approvals
*New code changes require fresh review.*

[x] Require conversation resolution
*Resolve review comments before merging.*

[x] Require status checks to pass
*Enable after your CI workflow has run and published check names.*

[x] Block force pushes
*Protects commit history.*

[x] Restrict deletions
*Prevents accidental deletion of main.*

![branch-protection](../evidences/branch-protection-1.png)
![branch-protection](../evidences/branch-protection-2.png)
![branch-protection](../evidences/branch-protection-1)

4. Open repository settings to add collaborators

Step 1. Open your GitHub repository.
Click Settings in the repository navigation bar.

Step 2. Find Collaborators or Collaborators and teams under Access.
Click Add people.

Step 3. Search for the person's GitHub username or email, select their account, and send the invitation.

The collaborator must accept the invitation before gaining access.

[Add Collaborators for approval](../evidences/add-collaborators.png)

**Important for protecting main**
Adding a collaborator does not automatically require pull requests or approvals. Keep your main branch ruleset active and configure:
- Require a pull request before merging.
- Require one approval, if a reviewer is available.
- Require conversation resolution.
- Block force pushes and branch deletion.
- Do not add collaborators or administrators to the ruleset's bypass list unless you intend to let them bypass the restrictions.

[References Managing Teams and people with access to your repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-teams-and-people-with-access-to-your-repository?utm_source=chatgpt.com)

# 3. Initialing git and push repo

```bash
cd /path/<repo-directory>
git init
touch .gitignore
git add . 
git status
git commit -m "first commit"
git push -u origin main
```

Expected: Rejected from main

![Rejected-from-main-branch](../evidences/main-rejected-push.png)

# 4. Create git branch "fe-network-ws" and pusch to github

```bash
git checkout -b fe-network-ws main # create branch
git branch # verify
git add "fe-network-ws/*" track folders & files under git
git commit -m "commit fe-network-ws"
git push -u origin fe-network-ws
```

**verify in git-hub**

![fe-network-ws-github-repo](../evidences/fe-network-ws-github.png)

# 5. Create Worksspace (fe-network-ws) in Hashicorp

**Step 1**
1. Sign in to HCP Terraform.
2. Select organization minmyatko.
3. Open project vpc-peering-vcs-driven.
4. Click Create workspace or New → Workspace.

![create-new-worksacpe](../evidences/create-ws.png)

**Step 2 — Select the workflow**

Choose Version Control Workflow (VCS-driven workflow), then click Next or Continue.

![create-vcs-driven-workdsapce](../evidences/create-ws-2.png)

Step 3 — Connect GitHub
- Select your configured GitHub VCS provider.
- Select the repository containing your Terraform project.
- Choose the branch main if that is the branch you want HCP Terraform to track.

![connect-GitHub](../evidences/create-ws-3.png)

**Step 3- Configure Worksacpe Setting**

| Setting | Value |
| --- | --- |
| Workspace name | fe-network-ws
| Project | vpc-peering-vcs-driven
| Workflow | Version Control Workflow
| VCS provider | Your connected GitHub provider
| Repository |  Your cloud infrastructure portfolio repository
| Branch | main
| Terraform working directory |	The repository-relative path to the frontend network configuration |
| Automatic run triggering | Only trigger runs when files in specified paths change |
| Path | fe-network-ws/* | 
| Pull requests | Automatic speculative plans |

![completed-creeating-workspace](../evidences/created-ws.png)


**Step 4- Configure the AWS role in HCP Terraform**

Open fe-network-ws → Variables.

For dynamic AWS credentials, HCP Terraform typically needs the AWS provider authentication configuration and workspace environment variables, along with an AWS IAM role trusted by your HCP Terraform organization/workspace.

![AWS-Dynamic-Variables](../evidences/aws-dynamic-credentials.png)
![AWS-Roles](../evidences/aws-roles.png)

[AWS dynamic credentials setup reference](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/aws-configuration?utm_source=chatgpt.com)

*Important: Configure the AWS IAM role first*
*Adding the role ARN alone is not enough. In AWS IAM, you must configure:*

- An OIDC identity provider for https://app.terraform.io.
- A trust policy allowing the correct HCP Terraform organization, project, workspace, and run phase.
- An IAM permissions policy allowing the operations required by fe-network-ws, such as creating VPCs, subnets, route tables, and internet gateways.

[AWS Login](../evidences/signing%20in%20into%20aws.png)
[OIDC Approval](../evidences/oidc-approval.png)

**Step 5- 1. Attach policies in AWS IAM**

Open the AWS IAM Roles page.
Role 1: aws-plan-role
Read-only access for Terraform plan
1. Select aws-plan-role.
2. Open Permissions.
3. Select Add permissions → Attach policies.
4. Search for ReadOnlyAccess.
5. Select the AWS-managed policy ReadOnlyAccess.
6. Click Add permissions.
Policy ARN

arn:aws:iam::aws:policy/ReadOnlyAccess

[Attach Read Only Access Policy](../evidences/attach-read-only-policy.png)

Role 2: aws-apply-role
Full access for Terraform apply
1. Return to the Roles page and select aws-apply-role.
2. Open Permissions.
3. Select Add permissions → Attach policies.
4. Search for AdministratorAccess.
5. Select the AWS-managed policy AdministratorAccess.
6. Click Add permissions.
Policy ARN

arn:aws:iam::aws:policy/AdministratorAccess

[Attach Administrator Access Policy](../evidences/attach-administratorAccess-policy.png)

2. Configure HCP Terraform workspace variables
Return to HCP Terraform → project vpc-peering-vcs-driven → workspace fe-network-ws → Variables.

Add these as Environment variables:
| Key |	Value |
| --- | --- |
| TFC_AWS_PROVIDER_AUTH | true |
| TFC_AWS_PLAN_ROLE_ARN | ARN of aws-plan-role |
| TFC_AWS_APPLY_ROLE_ARN | ARN of aws-apply-role |

[worksacpe variables](../evidences/authentication%20worksapce%20variables.png)

# 6. Create Individually managed policies (your current setup)

## Step 1. Open Policies

In HCP Terraform, select organization minmyatko → Settings → Policies → Create a new policy.



## Step 2. Configure the instance policy
- Policy name: instance_type
- Framework: OPA
- Query: data.terraform.policies.instance_type.deny
- Enforcement: Mandatory
- Policy code: paste instance-type Rego code.

```rego
package terraform.policies.instance_type

import input.plan as plan

deny[msg] {
  r := plan.resource_changes[_]
  r.type == "aws_instance"
  r.change.after != null
  r.change.after.instance_type != "t3.micro"
  msg := sprintf("%v must use instance type t3.micro", [r.address])
}
```
![Create Policy](../evidences/create%20policy.png)

## Step 3. Create the ingress policy

Repeat the process with:
- Policy name: public_ingress
- Framework: OPA
- Query: data.terraform.policies.public_ingress.deny
- Enforcement: Advisory
- Policy code: paste ingress Rego code.

```rego
package terraform.policies.public_ingress

import input.plan as plan

deny contains msg if {
    some r in plan.resource_changes
    r.type == "aws_security_group"
    r.change.after != null
    some ingress in r.change.after.ingress
    some cidr in ingress.cidr_blocks
    cidr == "0.0.0.0/0"

    msg := sprintf(
        "%v has 0.0.0.0/0 as allowed ingress",
        [r.address],
    )
}

package terraform.policies.public_ingress

import input.plan as plan

deny contains msg if {
    some r in plan.resource_changes
    r.type == "aws_vpc_security_group_ingress_rule"
    r.change.after != null
    r.change.after.cidr_ipv4 == "0.0.0.0/0"

    msg := sprintf(
        "%v allows unrestricted IPv4 ingress (0.0.0.0/0)",
        [r.address],
    )
}
```

![Policies-Creating-Complete](../evidences/two-policies.png)


# 7. Create Pull Reqeust in Github (fe-network-ws)

1. Submit the pull request for review
    After pushing your feature branch:
1. Open the repository on GitHub.
2. Select Pull requests → New pull request.
3. Set base: main and compare: feature/fe-network-ws.
4. Click Create pull request.
5. On the pull request page, find Reviewers in the right sidebar.
6. Click the settings icon and select an eligible collaborator.
7. Request their review.
The collaborator opens the PR, selects Files changed, reviews the Terraform configuration, and clicks Review changes → Approve → Submit review.
4. Merge after approval
Once the required approval is recorded, conversations are resolved, and required status checks pass, click Merge pull request. Delete the feature branch afterward if you no longer need it.

Important: A collaborator needs repository access and must be eligible to review. If the pull request author is the repository owner, the owner's own approval does not satisfy the required approval from another person.

For your Terraform workflow, review the plan in HCP Terraform before applying infrastructure changes after the merge.

![Open Pull Reqeust](../evidences/open-pull-request.png)
![Approve from collaborators](../evidences/approve-from-collaborators.png)

## 7.1 Run Planning, and Apply at Hashicorp

![fe-network-planning](../evidences/fe-network-planning.png)
![fe-network-apply](../evidences/fe-network-apply.png)

## 7.2 Verify in AWS Console 

![verifciation vpc and subnets](../evidences/fe-network-vpc.png)

# 8. Create VCS-Driven Worksapce (fe-security-ws)

New --> Select Project --> Work Flow (VCS) --> Connect to VCS --> Organization , Repository -->  Worksapce Name (fe-security-ws) --> Advanced Options -->
     Terraform working directory: fe-security-ws
     Auto-Apply : Auto-apply run triggers 
     VCS Branch: default
     Automatic run triggering: Only trigger runs when files in specified paths change
     Syntax : pattern 

![fe-security-ws](../evidences/fe-security-ws.png)

## 8.1 Add Varibles for AWS Autentication and Authorizaiton

Variables --> Quick setup AWS dynamic credentials --> Separate Roles (Plan role name) (Apply role Name) --> Add Credentials -- Allow

![AWS Authentication Authorization](../evidences/variables-aws-auth-auz%20-fe-security.png)

# 9. Create the Policy Set
Go to HCP Terraform → organization minmyatko → Settings → Policy Sets →
    Create Policy Set --> Individually managed policies --> Configure settings (Open policy agent (OPA)) --> 
    Policy set name: Deny-all-zero-cidir-ingress-security-group
    Scope of policies:
        Projects: vpc-peering-intra-vcs-driven <project name>
        Workspaces: fe-security-ws <worksapce name>
    Select Policies: deny-security-group-from-public-0.0.0.0. <individual Policies which has written in previous>

    
![Policy Set](../evidences/policy-set-security.png)


[Open Policy Agent](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/define-policies/opa)

## 8.2 Share fe-networkws to fe-security-ws to take outputs of VPC-id and other dependency



# 10. Push fe-security-ws to branch (fe-security-ws)

```bash
git swtich main # change to main branch
git checkout -b fe-security-ws # create branch
git branch # verify branch
git add .
git commit -m "commit fe-security-ws"
git push -u origin fe-security-ws # push to github branch
```
![fe-security-ws-github](../evidences/fe-security-ws-github.png)

# 11. Create Pull Reqesut and merge into Main

Create Pull Reqeust -- > Submit for Review -- Approve pull request -- Merge Pull Request

![Crete Pull Request](../evidences/create-pull-reqeust-fe-security-ws.png)
![Approvl Require](../evidences/fe-security-review-requried.png)
![Submit Approval](../evidences/submit-review.png)
![Approve Pull Reqeust](../evidences/approve-fe-security-ws.png)
![Merge Pull Reqeust](../evidences/mergie-pull-request-fe-security-sg.png)

# 12. Planning, Checking OPA Policy and Applying in HashiCorp

*Note: If there is no history run in Worksacpe, the first run is required to run mannual.*


![Run Planning](../evidences/run-planning-stage-fe-security-ws.png)
![Checking OPA Policy](../evidences/advisory-security-opa-policy.png)

## 12.1 Fix the error to allow OPA Policy in tf-config

    1. Fix the error
        change ip "0.0.0.0/0" to my ip "x.x.x./32" in variables for the ingress security route
        push to github again
        follow the approval process
        run hashicop 

![Pass OPA Policy Check](../evidences/opa-policy-pass.png)
![Apply-fe-security-sg](../evidences/apply-fe-security-sg.png)

# 13. Verify the Security group in AWS Console

![fe-security-groups-in-aws-console](../evidences/aws-fe-security-group.png)

# 14. Creae Work Sapce (fe-compute-ws)
*Share fe-netowrk-ws and fe-security-ws to fe-compute-ws* 
**Follow the same procedure and configuration setup in previous section 5**

![fe-compute-ws](../evidences/fe-compute-ws.png)

**Create variables for AWS Roles to authenticate and authorize AWS**
*Can refer to section 5: Step 4*

![AWS Roles](../evidences/plan-apply-role-fe-compute.png)


# 15. Create Policy Sets for compute worksapcing using individual poliy 
*Update Ploicy Set adding new individual policy which is allowd only the instance type of t3.micro*
![update-security-policy-set](../evidences/update-security-policy-set.png)


# 16. Push fe-compute-ws to github
**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in fe-compute-ws mannually* at Hashicorp

![Run Mannual with no config files](../evidences/first-run-with-no-tf-config.png)

```bash
min-myat-ko@ubuntu$git push -u origin fe-compute-ws
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 8 threads
Compressing objects: 100% (10/10), done.
Writing objects: 100% (11/11), 2.52 KiB | 1.26 MiB/s, done.
Total 11 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), done.
remote: 
remote: Create a pull request for 'fe-compute-ws' on GitHub by visiting:
remote:      https://github.com/minmyatko-cloud/vpc-peering-vcs-driven/pull/new/fe-compute-ws
remote: 
To github.com:minmyatko-cloud/vpc-peering-vcs-driven.git
 * [new branch]      fe-compute-ws -> fe-compute-ws
branch 'fe-compute-ws' set up to track 'origin/fe-compute-ws'.
```


## 16.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 17. Planning, Checking OPA Policy, Applying in Hashicorp
**Follow the same procedure and configuration setup in previous 12**

In this stage,  I deployed "Instance Type = t3.small" in order to test OPA Policy. Exptected Result: Fail

![Failed OPA Polic Check](../evidences/opa-policy-failed-aws-compute.png)

Then, Change "Instance Type = t3.micro", test again. Expected Result "Pass"

![OPA Policy Pass Instance Type t3.mirco](../evidences/opa-policy-pass.png)

Then, Apply the plan. 
# 18. Verify in AWS Console for instances 

[frontend-computes](../evidences/frontend-instances.png)

# 19. Creae Work Sapce (be-compute-ws)
**Follow the same procedure and configuration setup in previous section 5**

![Worksapce be-network-ws](../evidences/be-network-ws-create.png)

**Create variables for AWS Roles to authenticate and authorize AWS**
*Can refer to section 5: Step 4*

![AWS Role Creation be-network-ws](../evidences/roles-be-network-ws.png)

# 20. Push be-network-ws to github

**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in be-network-ws mannually* at Hashicorp

![Push Completion be-network-ws](../evidences/be-network-ws-repo-github.png)


## 20.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 20.2 Planning, Checking OPA Policy, Applying in Hashicorp
**Follow the same procedure and configuration setup in previous 12**

![Apply Complete be-network-ws](../evidences/be-network-ws-apply.png)


# 22. Verify in AWS Console for instances 

![Completion Backend VPC and related Resources](../evidences/backend-vpc.png)

# 23. Creae Work Sapce (be-security-ws)
**Follow the same procedure and configuration setup in previous section 5**

![Worksapce be-security-ws](../evidences/create-be-security-ws.png)

*Can refer to section 5: Step 4*

*Share from be-network-ws to be-security-ws to references vpc_id and other dependencies*

**Create variables for AWS Roles to authenticate and authorize AWS**

# 24. Push be-security-ws to github

**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in be-security-ws mannually* at Hashicorp


## 24.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 24.2 Planning, Checking OPA Policy, Applying in Hashicorp
**Follow the same procedure and configuration setup in previous 12**

![Apply Complete be-security-ws](../evidences/be-security-grou-apply.png)


# 25. Verify in AWS Console for instances 

![Completion Backend Security Groups](../evidences/be-security-groups.png)

# 26. Creae Work Sapce (be-compute-ws)
**Follow the same procedure and configuration setup in previous section 5**

![Worksapce be-compute-ws](../evidences/be-compute-ws-creation.png)

*Can refer to section 5: Step 4*

*Share from be-network-ws to be-security-ws to references vpc_id and other dependencies*

**Create variables for AWS Roles to authenticate and authorize AWS**

# 24. Push be-compute-ws to github

**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in be-compute-ws mannually* at Hashicorp
*update Policy Sets to control be-computer-ws*

## 24.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 24.2 Planning, Checking OPA Policy, Applying in Hashicorp
**Follow the same procedure and configuration setup in previous 12**

*Policy Test with t3.small* 
Fail: 

![Fail OPA Policy](../evidences/fail-opa-policy.png)

![Apply Complete be-compute-ws](../evidences/be-compute-apply-completion.png)


# 25. Verify in AWS Console for instances 

![Completion Backend Computes](../evidences/be-computes-aws.png)

# 27. Creae Work Sapce (vpc-peering-ws)
**Follow the same procedure and configuration setup in previous section 5**

![VPC-Peering-WS](../evidences/vpc-peering-ws.png)

*Can refer to section 5: Step 4*

*Share from fe-network-ws,be-network-ws,fe-security-ws,be-security-ws,fe-compute-ws, be-compute-ws to vpc-peering-ws to references vpc_id and other dependencies*

**Create variables for AWS Roles to authenticate and authorize AWS**

# 24. Push be-compute-ws to github

**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in be-compute-ws mannually* at Hashicorp
*update Policy Sets to control be-computer-ws*

## 24.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 24.2 Planning, Checking OPA Policy, Applying in Hashicorp
**Follow the same procedure and configuration setup in previous 12**


![Apply Complete vpc-peering-ws](../evidences/Apply-vpc-peering.png)


# 25. Verify in AWS Console for instances 

![Completion VPC Peering ](../evidences/vpc-peering-aws-console.png)

# 28. Testing


1. Ping from local pc to public_instance_1(fe)

```bash
min-myat-ko@ubuntu$ping 3.1.35.136
PING 3.1.35.136 (3.1.35.136) 56(84) bytes of data.
64 bytes from 3.1.35.136: icmp_seq=1 ttl=120 time=20.2 ms
64 bytes from 3.1.35.136: icmp_seq=2 ttl=121 time=14.5 ms
64 bytes from 3.1.35.136: icmp_seq=3 ttl=121 time=12.4 ms
64 bytes from 3.1.35.136: icmp_seq=4 ttl=120 time=14.6 ms
```
2. SSH login from pc to public_instance_1(fe) 
```bash
min-myat-ko@ubuntu$ssh hc-frontend-pub-1 
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Sat Oct 31 05:01:02 
[ec2-user@ip-10-0-1-106 ~]$ 
```

3. Ping from public_instance_1(fe) to internet
```bash
[ec2-user@ip-10-0-1-106 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=0.933 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=0.947 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=114 time=0.919 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=114 time=0.939 ms
```
4. Ping from public_instance_1(fe) to prviate_instance_1(fe)
```bash
[ec2-user@ip-10-0-1-106 ~]$ ping 10.0.253.154
PING 10.0.253.154 (10.0.253.154) 56(84) bytes of data.
64 bytes from 10.0.253.154: icmp_seq=1 ttl=64 time=0.807 ms
64 bytes from 10.0.253.154: icmp_seq=2 ttl=64 time=0.150 ms
64 bytes from 10.0.253.154: icmp_seq=3 ttl=64 time=0.174 ms
64 bytes from 10.0.253.154: icmp_seq=4 ttl=64 time=0.185 ms
```
4.1 Ping from public_instance_1(fe) to prviate_instance_2(fe) & private_instance_3(fe)

*Expected result: Fail coz no security rule allow*
```bash
[ec2-user@ip-10-0-1-106 ~]$ ping 10.0.255.119
PING 10.0.255.119 (10.0.255.119) 56(84) bytes of data.
^C
--- 10.0.255.119 ping statistics ---
14 packets transmitted, 0 received, 100% packet loss, time 13504ms

[ec2-user@ip-10-0-1-106 ~]$ ping 10.0.254.232
PING 10.0.254.232 (10.0.254.232) 56(84) bytes of data.
^C
--- 10.0.254.232 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3134ms

[ec2-user@ip-10-0-1-106 ~]$ 
```
5. SSH from public_instance_1(fe) to private_instance_1

```bash
min-myat-ko@ubuntu$ssh hc-frontend-prv-1
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
Welcome to Ubuntu 24.04.5 LTS (GNU/Linux 7.0.0-1014-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Oct 31 05:06:44 UTC 2026

  System load:  0.0               Temperature:           -273.1 C
  Usage of /:   30.5% of 6.71GB   Processes:             117
  Memory usage: 25%               Users logged in:       0
  Swap usage:   0%                IPv4 address for ens5: 10.0.253.154

 * Ubuntu Pro delivers the most comprehensive open source security and
   compliance features.

   https://ubuntu.com/aws/pro

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Thu Oct 29 12:26:36 2026 from 10.0.1.198
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-0-253-154:~$ 
```

5.1 Ping from prviate_instance_1(fe) to internet

```bash
ubuntu@ip-10-0-253-154:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=0.990 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=0.581 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=0.616 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=0.615 ms
```

6. Ping from prviate_instance_1(fe) to private_instance_2(fe)

```bash
ubuntu@ip-10-0-253-154:~$ ping 10.0.254.232
PING 10.0.254.232 (10.0.254.232) 56(84) bytes of data.
64 bytes from 10.0.254.232: icmp_seq=1 ttl=64 time=1.11 ms
64 bytes from 10.0.254.232: icmp_seq=2 ttl=64 time=0.714 ms
64 bytes from 10.0.254.232: icmp_seq=3 ttl=64 time=0.718 ms
64 bytes from 10.0.254.232: icmp_seq=4 ttl=64 time=0.751 ms
64 bytes from 10.0.254.232: icmp_seq=5 ttl=64 time=0.715 ms
```
7. SSH login to private_instance_2(fe)
```bash
min-myat-ko@ubuntu$ssh hc-frontend-prv-2
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
The authenticity of host '10.0.254.232 (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is: SHA256:xTfBlXAWVnphzuX9rKrQjA/MtjdH8YGdXVNlM2w43fM
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.0.254.232' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.5 LTS (GNU/Linux 7.0.0-1014-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Oct 31 05:08:09 UTC 2026

  System load:  0.0               Temperature:           -273.1 C
  Usage of /:   30.2% of 6.71GB   Processes:             113
  Memory usage: 25%               Users logged in:       0
  Swap usage:   0%                IPv4 address for ens5: 10.0.254.232


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-0-254-232:~$ 
```
7. Ping from prviate_instance_2(fe) to private_instance_2(be)

```bash
ubuntu@ip-10-0-254-232:~$ ping 192.168.254.207
PING 192.168.254.207 (192.168.254.207) 56(84) bytes of data.
64 bytes from 192.168.254.207: icmp_seq=1 ttl=64 time=0.498 ms
64 bytes from 192.168.254.207: icmp_seq=2 ttl=64 time=0.195 ms
64 bytes from 192.168.254.207: icmp_seq=3 ttl=64 time=0.185 ms
64 bytes from 192.168.254.207: icmp_seq=4 ttl=64 time=0.172 ms
64 bytes from 192.168.254.207: icmp_seq=5 ttl=64 time=0.216 ms
```

9. Ping from prviate_instance_3(fe) to private_instance_3(be)
```bash
ubuntu@ip-10-0-255-119:~$ ping 192.168.255.107
PING 192.168.255.107 (192.168.255.107) 56(84) bytes of data.
64 bytes from 192.168.255.107: icmp_seq=1 ttl=64 time=0.272 ms
64 bytes from 192.168.255.107: icmp_seq=2 ttl=64 time=0.273 ms
64 bytes from 192.168.255.107: icmp_seq=3 ttl=64 time=0.281 ms
64 bytes from 192.168.255.107: icmp_seq=4 ttl=64 time=0.277 m
```

# Step 10.1 Testing (backend)

1. Ping from local pc to public_instance_1(be)
```bash
min-myat-ko@ubuntu$ping 3.1.35.136
PING 3.1.35.136 (3.1.35.136) 56(84) bytes of data.
64 bytes from 3.1.35.136: icmp_seq=1 ttl=120 time=14.7 ms
64 bytes from 3.1.35.136: icmp_seq=2 ttl=121 time=14.1 ms
64 bytes from 3.1.35.136: icmp_seq=3 ttl=121 time=15.4 ms
```

2. SSH login from pc to public_instance_1(be)
```bash
min-myat-ko@ubuntu$ssh hc-backend-pub-1 
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Sat Oct 31 04:35:04 2026 from 161.142.142.210
```

3. Ping from public_instance_1(be) to internet
```bash
[ec2-user@ip-192-168-1-158 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=0.602 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=0.605 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=114 time=0.624 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=114 time=0.571 ms
```

4. Ping from public_instance_1(be) to prviate_instance_01(be)
```bash
[ec2-user@ip-192-168-1-158 ~]$ ping 192.168.253.251
PING 192.168.253.251 (192.168.253.251) 56(84) bytes of data.
64 bytes from 192.168.253.251: icmp_seq=1 ttl=64 time=0.787 ms
64 bytes from 192.168.253.251: icmp_seq=2 ttl=64 time=0.326 ms
64 bytes from 192.168.253.251: icmp_seq=3 ttl=64 time=0.388 ms
64 bytes from 192.168.253.251: icmp_seq=4 ttl=64 time=0.360 ms
```
5. Ping from prviate_instance_1(be) to internet
```bash
ubuntu@ip-192-168-253-251:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=1.60 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=1.19 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=1.19 ms
```

6. Ping from prviate_instance_1(be) to private_instance_2(be)
```bash
ubuntu@ip-192-168-253-251:~$ ping 192.168.254.207
PING 192.168.254.207 (192.168.254.207) 56(84) bytes of data.
64 bytes from 192.168.254.207: icmp_seq=1 ttl=64 time=1.18 ms
64 bytes from 192.168.254.207: icmp_seq=2 ttl=64 time=1.00 ms
64 bytes from 192.168.254.207: icmp_seq=3 ttl=64 time=0.789 ms
```

7. Ping from prviate_instance_2(be) to private_instance_2(fe)
```bash
ubuntu@ip-192-168-254-207:~$ ping 10.0.254.232
PING 10.0.254.232 (10.0.254.232) 56(84) bytes of data.
64 bytes from 10.0.254.232: icmp_seq=1 ttl=64 time=0.193 ms
64 bytes from 10.0.254.232: icmp_seq=2 ttl=64 time=0.194 ms
64 bytes from 10.0.254.232: icmp_seq=3 ttl=64 time=0.192 ms
64 bytes from 10.0.254.232: icmp_seq=4 ttl=64 time=0.278 ms
```

8. Ping from prviate_instance_1(be) to private_instance_3(be)

```bash
ubuntu@ip-192-168-253-195:~$ ping 192.168.255.15
PING 192.168.255.15 (192.168.255.15) 56(84) bytes of data.
64 bytes from 192.168.255.15: icmp_seq=1 ttl=64 time=0.908 ms
64 bytes from 192.168.255.15: icmp_seq=2 ttl=64 time=0.552 ms
64 bytes from 192.168.255.15: icmp_seq=3 ttl=64 time=0.560 ms
64 bytes from 192.168.255.15: icmp_seq=4 ttl=64 time=0.544 ms
```
9. Ping from prviate_instance_3(be) to private_instance_3(fe)
```bash
ubuntu@ip-192-168-255-15:~$ ping 10.0.255.180
PING 10.0.255.180 (10.0.255.180) 56(84) bytes of data.
64 bytes from 10.0.255.180: icmp_seq=447 ttl=64 time=0.240 ms
64 bytes from 10.0.255.180: icmp_seq=448 ttl=64 time=0.214 ms
64 bytes from 10.0.255.180: icmp_seq=449 ttl=64 time=0.186 ms
64 bytes from 10.0.255.180: icmp_seq=450 ttl=64 time=0.216 ms
64 bytes from 10.0.255.180: icmp_seq=451 ttl=64 time=0.201 ms
```

# 27. Creae Work Sapce Runner (worksapce-runner-ws)
**Follow the same procedure and configuration setup in previous section 5**

![workspace-runner-ws](../evidences/workspace-runner.png)


**Create variables for AWS Roles to authenticate and authorize AWS**

# 28. Push be-compute-ws to github
## 24.1 Create Terrafrom Configuration Workspace Runner
*Create TFE_TOKEN and Add as "ENVIRONMENT VARIABLES"*

Step 1 — Generate a user token
1. Open HCP Terraform.
2. Click your profile icon.
3. Go to User Settings → Tokens.
4. Generate a new API token.
Step 2 — Configure the runner workspace
1. Open workspace-runner-ws.
2. Go to Variables.
3. Add an environment variable:
Field	Value
Key	TFE_TOKEN
Value	Your personal API token
Category	Environment variable
Sensitive	Enabled

![Create TFE Token](../evidences/creae_tfe_token.png)
![Add Env Variables](../evidences/TFE_TOKEN.png)


**Follow the same procedure and configuration setup in previous 10 (used approraite name)**
*First run in be-compute-ws mannually* at Hashicorp
*update Policy Sets to control be-computer-ws*

## 28.1 follow the approval process (pull reqeust, submit approval, merge)
**Follow the same procedure and configuration setup in previous section 11**

# 29. Execute Workspace Runner

## 29.1 Background and Challenge

As I am using the **HCP Terraform Free plan**, I encountered a limitation when executing multiple workspace runs.

For example, when `workspace-runner-ws` triggers a remote run, another workspace such as `fe-network-ws` may be queued and cannot execute simultaneously.

However, my Workspace Runner is designed to orchestrate seven workspaces in a specific execution sequence. I want to avoid unnecessary waiting and allow the runner to execute locally while the target workspaces continue running remotely.

## 29.2 Solution: Use CLI-Driven Local Execution

To address this limitation, I configured `workspace-runner-ws` to use **CLI-driven local execution** instead of remote execution.

With this configuration:

- Terraform commands are executed from my local Ubuntu machine.
- The TFE provider communicates with HCP Terraform through the Terraform API.
- Workspace Runner triggers runs in the target HCP Terraform workspaces.
- The target workspaces continue using their own remote execution environments.
- The runner does not directly provision AWS infrastructure; each target workspace manages its own resources and Terraform state.

**Important:** Local execution of the runner does not mean that all seven target workspaces execute locally. Only the orchestration runs locally; the target workspace runs remain remote.


### Step 1: Switch to the Main Branch

Retrieve the latest approved Terraform configuration from GitHub.

```bash
git switch main
git pull
```

### Step 2: Navigate to the Workspace Runner Directory

```bash
cd workspace-runner-ws
```

### Step 3: Initialize Terraform

```bash
terraform init
```

This initializes the required Terraform providers, including the HashiCorp TFE provider.

### Step 4: Review the Execution Plan

```bash
terraform plan
```

Review the execution plan to ensure that the seven `tfe_workspace_run` resources will be created in the intended order.

### Step 5: Execute the Workspace Runner

```bash
terraform apply
```

Review the plan and enter `yes` when prompted.

Alternatively, use:

```bash
terraform apply -auto-approve
```

The runner then triggers the target workspace runs according to the configured dependency sequence.

## 29.4 Destroy Execution Sequence

When destroying the infrastructure, the runner executes the target workspace destroy operations in reverse dependency order.

This ensures that VPC peering is removed before the dependent compute, security, and network resources.

### Step 1: Execute Terraform Destroy

From the `workspace-runner-ws` directory, execute:

```bash
terraform destroy
```

Review the destruction plan and enter `yes` to confirm.

Alternatively:

```bash
terraform destroy -auto-approve
```

### Step 2: Verify Target Workspace Runs

After execution, check the Runs page of each target workspace in HCP Terraform.

Verify that:

- Each target workspace received a destroy run.
- The destroy runs completed successfully.
- The AWS resources managed by the target workspaces were removed.

## 29.5 Important Notes

- `workspace-runner-ws` manages the orchestration resources (`tfe_workspace_run`), not the AWS infrastructure directly.
- Each target workspace maintains its own Terraform state.
- The `apply` block triggers a target workspace apply run when its runner resource is created.
- The `destroy` block triggers a target workspace destroy run when its runner resource is destroyed.
- `wait_for_run = true` makes the runner wait for the target run to finish.
- `depends_on` controls the execution order.
- `manual_confirm = false` allows the target run to be automatically confirmed, subject to applicable policy and workspace controls.

**Result:** Workspace Runner provides centralized orchestration for the seven VCS-driven HCP Terraform workspaces, while each workspace independently manages its own AWS infrastructure.
