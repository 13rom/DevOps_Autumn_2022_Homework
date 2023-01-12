ADDRESS := $(shell terraform output -raw aws-jenkins-instance-public-dns)
ANSIBLE_DIR := ./ansible-jenkins
BACKEND_DIR := ./terraform-backend
TERRAFORM_DIR := ./terraform-jenkins
SSH_DIR := ./.ssh

everything : backend-init backend-plan backend-apply init plan apply show-dns connect ping roles-install provision
.PHONY : everything

backend-init:
	cd ${BACKEND_DIR}; terraform init

backend-plan:
	cd ${BACKEND_DIR}; terraform plan

backend-apply:
	cd ${BACKEND_DIR}; terraform apply

init:
	cd ${TERRAFORM_DIR}; terraform init

plan:
	cd ${TERRAFORM_DIR}; terraform plan

apply:
	cd ${TERRAFORM_DIR}; terraform apply

show-dns:
	cd ${TERRAFORM_DIR}; \
	terraform output -raw aws-jenkins-instance-public-dns

connect:
	ssh -i ${SSH_DIR}/jenkins_rsa ec2-user@${ADDRESS}

ping:
	cd ${ANSIBLE_DIR}; ansible jenkins -m ping

roles-install:
	cd ${ANSIBLE_DIR}; ansible-galaxy install -r ./requirements.yml -p ./roles/

provision:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-jenkins.yml