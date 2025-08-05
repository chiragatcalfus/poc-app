provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-1"
  }
}
resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "rt_assoc_public-1" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_assoc_public-2" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "my_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  # Custom TCP: 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP: 6443 (Kubernetes API)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP: 10250 (Kubelet)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP: 30000 - 32767 (NodePort range)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS: TCP 53
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}



resource "aws_instance" "master" {
  ami                    = "ami-021a584b49225376d"
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "pic-key"

  tags = {
    Name = "master"
  }
}
resource "aws_instance" "slave1" {
  ami                    = "ami-021a584b49225376d"
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "pic-key"

  tags = {
    Name = "slave1"
  }
}
resource "aws_instance" "slave2" {
  ami                    = "ami-021a584b49225376d"
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.public_subnet-2.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "pic-key"

  tags = {
    Name = "slave2"
  }
}