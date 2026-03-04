terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}


resource "aws_vpc" "snehalvpc" {
  cidr_block           = "171.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Devops_VPC"
  }

}

resource "aws_subnet" "snehalsubnet1" {
  vpc_id                  = aws_vpc.snehalvpc.id
  cidr_block              = "171.0.0.0/17"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB1"
  }
}

resource "aws_subnet" "snehalsubnet2" {
  vpc_id                  = aws_vpc.snehalvpc.id
  cidr_block              = "171.0.128.0/18"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB2"
  }
}

resource "aws_subnet" "snehalsubnet3" {
  vpc_id                  = aws_vpc.snehalvpc.id
  cidr_block              = "171.0.192.0/27"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB3"
  }
}

resource "aws_internet_gateway" "snehalIGW" {
  vpc_id = aws_vpc.snehalvpc.id
  tags = {
    Name = "Devops_IGW"
  }
}

resource "aws_route_table" "snehalRT" {
  vpc_id = aws_vpc.snehalvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.snehalIGW.id
  }

  tags = {
    Name = "Devops_RT"
  }

}

resource "aws_route_table_association" "snehalasso1" {
  subnet_id      = aws_subnet.snehalsubnet1.id
  route_table_id = aws_route_table.snehalRT.id
}

resource "aws_route_table_association" "snehalasso2" {
  subnet_id      = aws_subnet.snehalsubnet2.id
  route_table_id = aws_route_table.snehalRT.id
}

resource "aws_route_table_association" "snehalasso3" {
  subnet_id      = aws_subnet.snehalsubnet3.id
  route_table_id = aws_route_table.snehalRT.id
}

resource "aws_security_group" "snehalSG" {
  name   = "Devops_SG"
  vpc_id = aws_vpc.snehalvpc.id

  #inbound
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "snehal1" {
    key_name = "snehal1"
    public_key = file("snehal.pub")
  
}


resource "aws_instance" "snehalec2" {
  ami                    = "ami-09b041abcb4daa286"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snehalsubnet1.id
  vpc_security_group_ids = [aws_security_group.snehalSG.id]
  key_name               = aws_key_pair.snehal1.id
  user_data              = file("web.sh")
  tags = {
    Name = "Devops_Instance"
  }
}


output "public_ip" {
  value = aws_instance.snehalec2.public_ip
}