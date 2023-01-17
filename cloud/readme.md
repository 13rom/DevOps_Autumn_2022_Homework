## Task2.2 CLOUD BASICS
![AWS lab](screenshots/AWS_VMs.png)
![AWS ssh lab](screenshots/CentOS_ssh.png)

Things done:
* registered an AWS account
* created **VM1** (`CentOS-Lightsail-VM`) - Lightsail VM
* created **VM2** (`EC2 CentOS playground`) - EC2 official CentOS instance
* created a **VM2** snapshot
* created **Disk_D** EBS
* attached **Disk_D** to **VM2**
* created empty test.txt in **Disk_D** filesystem
* created **VM3** (`EC2 CentOS reloaded`) - EC2 custom image instance based on a **VM2** snaphot
* attached **Disk_D** to **VM3**

![S3 lab](screenshots/AWS_CLI.png)

* created WordPress instance with Lightsail
* created S3 Bucket (`s3bucket-playground`)
* uploaded and downloaded a file using AWS CLI

![Docker lab](screenshots/ECS_apache.png)

* created EC2 Amazon Linux instance (`AWS linux docker`)
* created custom docker image (`hello-cloud`) based on `httpd:2.4-alpine`
* uploaded image from `AWS linux docker` to ECS repository
* created ECS cluster
* created task
* started task
* tested apache2 website (`3.69.175.155`)
* created a static site on Amazon S3 (http://cloudbucket.site.s3-website.eu-central-1.amazonaws.com/)
