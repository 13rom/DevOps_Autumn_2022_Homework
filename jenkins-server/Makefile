MASTERADDR = $(shell cd $(TERRAFORM_DIR) && terraform output -raw aws-jenkins-master-instance-public-dns)
SLAVEADDR = $(shell cd $(TERRAFORM_DIR) && terraform output -raw aws-jenkins-slave-instance-public-dns)
ANSIBLE_DIR := ./ansible
BACKEND_DIR := ./terraform/backend
TERRAFORM_DIR := ./terraform
SSH_DIR := ./.ssh

PHONY_TARGETS = deploy backend backend-init backend-plan backend-apply backend-output \
				jenkins jenkins-init jenkins-plan jenkins-apply jenkins-output jenkins-show-dns \
				provision ping roles-install provision-master provision-slave \
				connect-master connect-slave connect-webserver
.PHONY: $(PHONY_TARGETS)


#### Main target ##############################################################
deploy: jenkins-apply provision jenkins-output


#### Terraform Backend initialization #########################################
backend: backend-init backend-apply backend-output

backend-init:
	cd ${BACKEND_DIR}; terraform init

backend-plan:
	cd ${BACKEND_DIR}; terraform plan

backend-apply:
	cd ${BACKEND_DIR}; terraform apply

backend-output:
	cd ${BACKEND_DIR}; terraform output


#### Terraform Jenkins initialization #########################################
jenkins: jenkins-apply jenkins-output

jenkins-init:
	cd ${TERRAFORM_DIR}; terraform init

jenkins-plan:
	cd ${TERRAFORM_DIR}; terraform plan

jenkins-apply:
	cd ${TERRAFORM_DIR}; terraform apply

jenkins-output:
	cd ${TERRAFORM_DIR}; terraform output

jenkins-show-dns:
	cd ${TERRAFORM_DIR}; \
	echo "Master Node:"; \
	terraform output -raw aws-jenkins-master-instance-public-dns; \
	echo "Slave Node:"; \
	terraform output -raw aws-jenkins-slave-instance-public-dns


#### Ansible Jenkins provisioning #############################################
provision: provision-master provision-slave

ping:
	cd ${ANSIBLE_DIR}; ansible all -m ping

roles-install:
	cd ${ANSIBLE_DIR}; ansible-galaxy install -r ./requirements.yaml -p ./roles/

provision-master:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-master.yaml

provision-slave:
	cd ${ANSIBLE_DIR}; ansible-playbook ./provision-slave.yaml


#### Auxiliary ################################################################
connect-master:
	ssh -i ${SSH_DIR}/jenkins_rsa ec2-user@${MASTERADDR}

connect-slave:
	ssh -i ${SSH_DIR}/jenkins_rsa ec2-user@${SLAVEADDR}

connect-webserver:
	ssh -i ${SSH_DIR}/jenkins_rsa ubuntu@$webserver.server.cx.ua