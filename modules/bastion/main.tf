resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.bastion_inputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_inputs.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = var.bastion_inputs.public_subnet_id
  key_name               = var.bastion_inputs.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
}
