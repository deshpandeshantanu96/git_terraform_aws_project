resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-aws"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "free_tier_db" {
  allocated_storage        = 20
  storage_type             = "gp2"
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = var.db_instance_class
  username                 = var.db_username
  password                 = var.db_password
  db_name                  = var.db_name
  publicly_accessible      = true
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]
  db_subnet_group_name     = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot      = true
  backup_retention_period  = 7
}
