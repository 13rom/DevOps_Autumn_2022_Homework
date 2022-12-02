## Generate Ansible hosts file

data "template_file" "ansible_inventory" {
  template = file("./templates/hosts.tpl")

  vars = {
    jenkins_instance_dns = module.jenkins_server.aws-jenkins-instance-public-dns
  }
}

resource "local_file" "save_ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "../ansible-jenkins/hosts"
}
