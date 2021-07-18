resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/home/app/.ssh/id_rsa.pub")
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

