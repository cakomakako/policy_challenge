resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/home/app/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami                  = "ami-005e54dee72cc1d00" # us-west-2
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  key_name             = aws_key_pair.deployer.key_name

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.foo.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  vpc = true
}

output "public_ip" {
  value = aws_eip.example.*
}

