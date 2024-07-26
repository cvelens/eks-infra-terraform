variable "profile" {
  type        = string
  default     = "infra"
  description = "Account in which the resources will be deployed"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region where the resources will be deployed"
}

variable "vpc_name" {
  type    = string
  default = "csye7125_eks"
}

variable "vpccidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  validation {
    condition     = contains(["10.0.0.0/16", "192.168.0.0/16", "172.31.0.0/16"], var.vpccidr)
    error_message = "Please enter a valid CIDR. Allowed values are 10.0.0.0/16, 192.168.0.0/16 and 172.31.0.0/16"
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Public subnets for VPC"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "Public subnets for VPC"
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "AZs to be used"
}

variable "aws_cluster_security_group_name" {
  type    = string
  default = "cluster"
}

variable "cluster_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "All Inbound"
    }
  ]
}

variable "cluster_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "All Outbound"
    }
  ]
}

variable "aws_node_security_group_name" {
  type    = string
  default = "node"
}

variable "node_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "All Outbound"
    }
  ]
}

variable "cluster_name" {
  type    = string
  default = "csye7125_cluster"
}

variable "node_group_name" {
  type    = string
  default = "csye7125_node1_group"
}

variable "k8_cluster_version" {
  type    = string
  default = "1.29"
}

variable "eks_role" {

  type    = string
  default = "csye7125_eks_role"
}

variable "family" {

  type    = string
  default = "ipv4"
}


variable "eks_policies" {

  type = map(string)
  default = {
    AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    AmazonEKS_CNI_Policy           = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEBSCSIDriverPolicy       = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
  }
}

variable "log_types" {
  type        = list(string)
  default     = ["audit", "api", "authenticator", "scheduler", "controllerManager"]
  description = "Logging"
}

variable "node_ami_id" {
  type    = string
  default = "AL2_x86_64"
}

variable "disk_size" {
  type    = string
  default = "20"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.xlarge"]
}

variable "instance_type" {
  type    = string
  default = "t3.xlarge"
}

variable "min_size" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 6
}

variable "desired_size" {
  type    = number
  default = 3
}

variable "max_unavailable_number" {
  type    = string
  default = "1"
}

variable "authentication_mode" {
  type    = string
  default = "API_AND_CONFIG_MAP"
}

variable "cluster_tags" {
  type = map(string)
  default = {
    "course" = "csye7125"
    "name"   = "infra"
  }
}

variable "create_cluster_security_group" {
  type    = bool
  default = false
}

variable "kafka_name" {
  type    = string
  default = "kafka"
}

variable "helm_kafka_repo" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}

variable "chart_name" {
  type    = string
  default = "kafka"
}

variable "secret_name" {
  type    = string
  default = "github-token"
}

variable "token" {
  description = "A map of the secret data"
  type        = string
}