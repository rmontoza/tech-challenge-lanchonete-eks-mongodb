provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "selected_eks" {
  name = var.eks_cluster_name  # Nome do cluster EKS
}

data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.selected_eks.vpc_config[0].vpc_id
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "lanchonete-docdb-subnet-group"
  subnet_ids = data.aws_subnets.eks_subnets.ids

  tags = {
    Name = "docdb-subnet-group"
  }
}

resource "aws_security_group" "docdb_sg" {
  vpc_id = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Ajuste conforme necessário
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docdb-security-group"
  }
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier = "lanchonete-docdb-cluster"
  master_username    = var.docdb_username
  master_password    = var.docdb_password
  skip_final_snapshot = true

  db_subnet_group_name   = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]

  tags = {
    Name = "lanchonete-docdb-cluster"
  }
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  count              = 1
  identifier         = "lanchonete-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = "db.t3.medium"

  tags = {
    Name = "lanchonete-docdb-instance"
  }
}
