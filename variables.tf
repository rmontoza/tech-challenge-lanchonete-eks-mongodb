variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "docdb_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "fiaplanchonete"
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS existente"
  type        = string
  default     = "lanchonete-eks-cluster"
}

variable "docdb_password" {
  description = "Master password for DocumentDB"
  type        = string
  sensitive   = true
}
