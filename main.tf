provider "aws" {
   region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my-ip" {}
variable "instance_type"  {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
  }

  resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    
    tags = {
      Name: "${var.env_prefix}--subnet-1"
    }
  }

  resource "aws_route_table" "myapp-route-table" {
    
    vpc_id = aws_vpc.myapp-vpc.id
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myapp-igw.id

      tags = {
        Name : "${var.env_prefix}-route-table"
      }
    }
  }
  resource "aws_internet_gateway" "myapp-igw" {
    
    vpc_id = aws_vpc.myapp-vpc
    tags = {
      Name : "${var.env_prefix}-igw"
    }
  }

  resource "aws_route_table_association" "myapp-rtb-subnet" {

    subnet_id = aws_subnet.myapp-subnet-1.id
    rouroute_table_id = aws_route_table.myapp-route-table.id   
  }

  # # How can we add default route table
  # resource "aws_default_route_table" "default-rtb" {
  #   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id     // This is default id 
    
  #   route{
  #     cidr_block = "0.0.0.0/0"
  #     gateway_id = aws_internet_gateway.myapp-igw.id

  #     tags = {
  #       Name : "${var.env_prefix}-route-main-table"
  #     }
  #   }
    
  # }

#   resource "aws_security_group" "myapp-sg" {
#     name = "myapp-sg"
#     vpc_id = aws_vpc.myapp-vpc

#     ingress = {         //"ingress" refers to the rules that control inbound traffic to the associated resources, such as EC2 instances or load balancers. These rules define the allowed sources, ports, and protocols for incoming connections

#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_block = [var.my_ip]

#     }
#     egress = {      // This is for out going

#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_block = ["0.0.0.0/0"]
#     prefix_list_ids = []

#     tags = {
#       Name : "${var.env_prefix}-sg"
#     }
# }    
#   }

#   # use default securty group instead of creating a new one. Above security group is new one.

  resource "aws_default_security_group" "default_sg" {
    vpc_id = aws_vpc.myapp-vpc

       ingress = {         //"ingress" refers to the rules that control inbound traffic to the associated resources, such as EC2 instances or load balancers. These rules define the allowed sources, ports, and protocols for incoming connections

    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = [var.my_ip]

    }
    egress = {      // This is for out going

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = ["0.0.0.0/0"]
    prefix_list_ids = []

    tags = {
      Name : "${var.env_prefix}-sg"
    }
}
  }


# To retrieve the ID of an existing Amazon Machine Image (AMI)

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id     // it will show the output as ec2 instance id 
}

# Creating an EC2 instance

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default_sg.id]   // square brackets are used to define a list of security group IDs.
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "server-key-pair"

  tags = {
    Name = "${env_prefix}-server"
  }

  
   
}
