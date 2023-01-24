MASTERADDR = $(shell terraform output -raw aws-jenkins-master-instance-public-dns)
SLAVEADDR = $(shell terraform output -raw aws-jenkins-slave-instance-public-dns)
ANSIBLE_DIR := ./ansible
BACKEND_DIR := ./terraform/backend
TERRAFORM_DIR := ./terraform
SSH_DIR := ./.ssh

everything : deploy output backend-init backend-plan backend-apply init plan apply show-dns connect-master connect-slave ping roles-install provision-master provision-slave
deploy: apply provision-master provision-slave output
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

output:
	cd ${TERRAFORM_DIR}; terraform output

show-dns:
	cd ${TERRAFORM_DIR}; \
	echo "Master Node:"; \
	terraform output -raw aws-jenkins-master-instance-public-dns; \
	echo "Slave Node:"; \
	terraform output -raw aws-jenkins-slave-instance-public-dns

connect-master:
	ssh -i ${SSH_DIR}/jenkins_rsa ec2-user@${MASTERADDR}

connect-slave:
	ssh -i ${SSH_DIR}/jenkins_rsa ec2-user@${SLAVEADDR}

ping:
	cd ${ANSIBLE_DIR}; ansible jenkins -m ping

roles-install:
	cd ${ANSIBLE_DIR}; ansible-galaxy install -r ./requirements.yml -p ./roles/

provision-master:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-master.yml

provision-slave:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-slave.yml