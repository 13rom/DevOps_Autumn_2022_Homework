webserver ansible_host=138.2.156.94 ansible_user=ubuntu ansible_port=22
jenkins ansible_host=${jenkins_instance_dns} ansible_user=ec2-user ansible_port=22 ansible_ssh_private_key_file=../.ssh/jenkins_rsa
