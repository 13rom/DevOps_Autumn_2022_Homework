# Jenkins CI/CD project
> TODO: Assign IAM role to master instance

> TODO: Save Jenkins home folder backup to S3

## Project description
### Infrastructure
* Control Unit (Laptop)
    - `git`, `terraform`, `ansible`
* Jenkins **Master** Node (AWS EC2 instance)
    - GitHub, DockerHub, SSH credentials
* Jenkins **Slave** Node (AWS EC2 instance)
    - `git`, `ansible`, `docker`
* **Webserver** (Oracle Cloud Compute Instance)
    - `docker`, `docker compose`, `docker swarm`
* GitHub private repository
    - **demo webapp** source code
    - **Jenkinsfile**
* DockerHub private repository
    - **demo webapp** docker image

## Project stages
### Jenkins Server deployment
1. Control Unit - `terraform`
    * Deploy AWS S3 Bucket for Terraform remote state
    * Deploy AWS VPC with public subnet
    * Set up Security groups for Jenkins nodes
    * Deploy Jenkins Master and Slave nodes
    * ??? Create GitHub Webhook for Jenkins CI/CD project

2. Control Unit - `ansible`
    * Provision Jenkins Master Node
    * Provision Jenkins Slave Node and connect it to Master


### Demo Webapp Deployment
1. Jenkins Master - Build Start
    * Chekout **demo webapp** repository
    * Get **Jenkinsfile** from repo
    * Execute **Jenkinsfile** instructions on **Slave** Node

1. Jenkins Slave - Build Execution
    * Checkout **demo webapp** repository
    * Get **demo webapp** source code from repository
    * Get Multistage **Dockerfile** from repository
    * Build docker image, push to **DockerHub**

1. Jenkins Slave - Webapp Deploy
    * Get ansible **playbook** from repository
    * Get **docker compose** file from repository
    * Run ansible playbook on **webserver**

1. Webserver - Ansible playbook
    * Get **docker compose** file from Jenkins Slave
    * Create/update docker **stack**



---
## Notes
#### Create terraform folder initial structure
```bash
mkdir -p terraform/modules/{compute,security_group,vpc} && cd terraform && touch main.tf outputs.tf secrets.tfvars && cd modules/compute && touch main.tf outputs.tf install_jenkins.sh && cd ../security_group && touch main.tf outputs.tf && cd ../vpc && touch main.tf outputs.tf
```

#### Install Ansible roles locally
```bash
ansible-galaxy install -r requirements.yml -p ./roles/
```

#### Create an RSA PEM key (esp. for publish Over SSH)
```
ssh-keygen -t rsa -C "jenkins" -m PEM -P "" -f .ssh/jenkins_rsa
```

#### Add github to jenkins known hosts
```bash
jenkins@jenkins:~$ ssh-keyscan github.com >> ~/.ssh/known_hosts
```
