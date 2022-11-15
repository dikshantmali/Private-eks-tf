# Make keypair
# resource "aws_key_pair" "personal-key-pair" {
#   key_name   = "personal-key-pair"
#   public_key = ""
# }

# Create SG For EKS Control Plane

resource "aws_security_group" "bastion-host-sg" {
  name        = "bastion-host-sg"
  description = "aws vpc bastion host sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastionhost-sg"
  }
}
# resource "aws_instance" "myos" {
# ami = "ami-0149b2da6ceec4bb0"
# instance_type = "t2.micro"
# subnet_id  = aws_subnet.pulic-subnet-1.id
# availability_zone = "us-east-1a"
# key_name = "awskey"
# security_groups = [ "${aws_security_group.mysecurityGroup.id}" ]
# tags = {
# Name = "My Bastionhost"
# }
# }