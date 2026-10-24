Host hc-frontend-pub-1
    Hostname 54.255.201.196
    User ec2-user
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes

Host hc-frontend-prv-1
    Hostname 10.0.253.142
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-pub-1


Host hc-frontend-prv-2
    Hostname 10.0.254.203
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-prv-1

Host hc-frontend-prv-3
    Hostname 10.0.255.180
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-prv-1

#backend 

Host hc-backend-pub-1
    Hostname 52.76.170.12
    User ec2-user
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes

Host hc-backend-prv-1
    Hostname 192.168.253.195
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-pub-1


Host hc-backend-prv-2
    Hostname 192.168.254.177
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-prv-1

Host hc-backend-prv-3
    Hostname 192.168.255.15
    User ubuntu
    IdentityFile ~/.ssh/fe-private-ssh-keypair.pem
    IdentitiesOnly yes
    ProxyJump hc-frontend-prv-1