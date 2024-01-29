//This Terraform Template creates 3 Ansible Nodes (Machines) on EC2 Instances
//Ansible Machines will run on Ubuntu 20.04 with custom security group
//allowing SSH (22), 27017 (MongoDB) connections from anywhere.
//User needs to select appropriate variables form "tfvars" file when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "nodes" {
  ami = var.myami
  instance_type = var.instancetype
  count = var.num
  # availability_zone = element(var.availabilityzone, count.index)
  key_name = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = "ansible_${element(var.tags, count.index )}"
    stack = "ansible_project"
    environment = "production"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "tf-sec-gr" {
  name = "${var.mysecgr}-${var.user}"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = var.mysecgr
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    protocol    = "tcp"
    to_port     = 27017
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "null_resource" "config" {
#   connection {
#     host = aws_instance.nodes.public_ip 
#     type = "ssh"
#     user = "ubuntu"
#     private_key = file("~/.ssh/${var.mykey}.pem")
#     # Do not forget to define your key file path correctly!
#   }

#   provisioner "file" {
#     source = "../ansible/ansible.cfg"
#     destination = "/home/ubuntu/.ansible.cfg"
#   }

#   provisioner "file" {
#     # Do not forget to define your key file path correctly!
#     source = "~/.ssh/${var.mykey}.pem"
#     destination = "/home/ubuntu/${var.mykey}.pem"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo hostnamectl set-hostname Control-Node",
#       "sudo apt-get update",
#       "sudo apt-get install -y python3-pip python3-dev",
#       "pip3 install ansible",
#       "pip3 install boto3 botocore",
#       "chmod 400 ${var.mykey}.pem"
#     ]
#   }
# }

# output "controlnode-publicip" {
#   value = aws_instance.control_node.public_ip
# }

# output "controlnode-privateip" {
#   value = aws_instance.control_node.*.private_ip
# }