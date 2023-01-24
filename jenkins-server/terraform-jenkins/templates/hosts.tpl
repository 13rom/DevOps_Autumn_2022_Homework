[all:vars]
ansible_port=22

[master]
jenkins ansible_host=${jenkins_master_dns}

[slaves]
jenkins-slave ansible_host=${jenkins_slave_dns}

[slaves:vars]
master_ip=${jenkins_master_dns}

[aws:children]
master
slaves

[aws:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=../.ssh/jenkins_rsa

[webservers]
webserver ansible_host=138.2.156.94 ansible_user=ubuntu
