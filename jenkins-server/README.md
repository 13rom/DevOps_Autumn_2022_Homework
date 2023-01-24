## Tutorial URL
https://betterprogramming.pub/provisioning-a-jenkins-server-on-aws-using-terraform-4cd1351b5d5f

## Create terraform folder initial structure
```bash
mkdir -p terraform/modules/{compute,security_group,vpc} && cd terraform && touch main.tf outputs.tf secrets.tfvars && cd modules/compute && touch main.tf outputs.tf install_jenkins.sh && cd ../security_group && touch main.tf outputs.tf && cd ../vpc && touch main.tf outputs.tf
```

## Install Ansible roles locally
```bash
ansible-galaxy install -r requirements.yml -p ./roles/
```

## Add github to jenkins known hosts
```bash
jenkins@jenkins:~$ ssh-keyscan github.com >> ~/.ssh/known_hosts
```

## Tutorials
* [Assign a role to jenkins instance](https://www.youtube.com/watch?v=Qlj-xGx9hHg)
* [Add slaves with plugin](https://faun.pub/10-steps-to-deploy-and-configure-jenkins-on-aws-with-terraform-26e641e90ae)
* [[ AWS 23 ] Launch AWS EC2 instances as Jenkins Slaves using EC2 plugin](https://www.youtube.com/watch?v=dAa3u39RYpM) - Launch EC2 as jenkins slave with role
* [How To Use Ansible with Terraform for Configuration Management](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management) - Automatic Ansible start


Plan:
* Create VPC
    * add public subnet
    * add internet gateway
    * add route table (CIDR to GW)
    * associate rt with subnet
* Create Jenkins master instance
    * get AMI
    * create security group
    * add key pair
    * create instance
* TODO: Assign AIM role to master instance
* TODO: Create Jenkins agent node
* Provision master
    * enable jenkins user
    * install jenkins software
    * install additional software
    * TODO: create key pair
    * TODO: set github credentials
    * upload jenkins home folder