ADDRESS := $(shell terraform output -raw aws-jenkins-instance-public-dns)
ANSIBLE_DIR := ../ansible-jenkins

all : plan apply show-dns connect ping roles-install provision
.PHONY : all

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