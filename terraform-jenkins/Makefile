ADDRESS := $(shell terraform output -raw aws-jenkins-instance-public-dns)
ANSIBLE_DIR := ../ansible-jenkins
BACKEND_DIR := ../terraform-backend

everything : backend-init backend-plan backend-apply plan apply show-dns connect ping roles-install provision
.PHONY : everything

backend-init:
	cd ${BACKEND_DIR}; \
	terraform init

backend-plan:
	cd ${BACKEND_DIR}; \
	terraform plan

backend-apply:
	cd ${BACKEND_DIR}; \
	terraform apply

plan:
	terraform plan

apply:
	terraform apply

show-dns:
	terraform output -raw aws-jenkins-instance-public-dns

connect:
	ssh -i ../.ssh/jenkins_rsa ec2-user@${ADDRESS}

ping:
	cd ${ANSIBLE_DIR}; ansible jenkins -m ping

roles-install:
	cd ${ANSIBLE_DIR}; ansible-galaxy install -r ./requirements.yml -p ./roles/

provision:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-jenkins.yml