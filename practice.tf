# provider "aws" {
#   region     = "us-west-2"
#   access_key = "my-access-key"
#   secret_key = "my-secret-key"
# }
# variable "subnet_cidr_blocks" {
#   description = "subnet cidr block"
  
# }
# variable "vpc_cidr_blocks" {
#   description = "vpc cidr block"
  
# }
# resource "aws_vpc" "developement_vpc" {
#   # cidr_block = "10.0.0.0/16"   // Range of IP Addresses 
#   //Lower the number[16] the more ip addresses you have available for the VPC
#   cidr_block = var.vpc_cidr_block

  
# }

# resource "aws_subnet" "dev_subnet_1" {
#   vpc_id = aws_vpc.developement_vpc.id
#   cidr_block = var.subnet_cidr_block
#   availability_zone = "us-west-2a"
  
# }

# data "aws_vpc" "existing_vpc" {
#   # Data : "The purpose of this data block is to fetch information about a specific AWS service you provide in the data block"
#   default = true
# }

# resource "aws_subnet" "dev_subnet_2" {
#   vpc_id = data.aws_vpc.existing_vpc.id
#   cidr_block = "172.31.48.0/20"
#   availability_zone = "us-west-2a"
# }