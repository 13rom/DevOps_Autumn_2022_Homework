webserver ansible_host=138.2.156.94 ansible_user=ubuntu ansible_port=22
jenkins ansible_host=${jenkins_master_dns} ansible_user=ec2-user ansible_port=22 ansible_ssh_private_key_file=../.ssh/jenkins_rsa
jenkins-slave ansible_host=${jenkins_slave_dns} master_ip=${jenkins_master_dns} ansible_user=ec2-user ansible_port=22 ansible_ssh_private_key_file=../.ssh/jenkins_rsa
