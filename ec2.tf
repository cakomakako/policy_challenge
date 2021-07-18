resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/home/app/.ssh/id_rsa.pub")
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main"
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "ssh to VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "test-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "eip" {
  instance = aws_instance.foo.id
  vpc      = true
}

resource "aws_instance" "foo" {
  ami                  = "ami-0233c2d874b811deb"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  key_name             = aws_key_pair.deployer.key_name
  subnet_id            = aws_subnet.my_subnet.id
  security_groups      = [aws_security_group.allow_ssh.id]

  credit_specification {
    cpu_credits = "unlimited"
  }
}

output "eip" {
  value = aws_eip.eip.*
}

output "ec2" {
  value = aws_instance.foo.*
}

