## Generate Ansible hosts file

data "template_file" "ansible_inventory" {
  template = file("./templates/hosts.tpl")

  vars = {
    jenkins_master_dns = module.jenkins_master.aws-instance-public-dns
    jenkins_slave_dns  = module.jenkins_slave.aws-instance-public-dns
  }
}

resource "local_file" "save_ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "../ansible/hosts"
}
