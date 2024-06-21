# CSYE 7125 - Advanced Cloud Computing: Infrastructure as Code for AWS EKS

This repository contains Terraform code to set up an Amazon EKS (Elastic Kubernetes Service) cluster and its associated infrastructure on AWS.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform (version 1.0.0 or later)
- kubectl installed

## Repository Structure
```
.
├── README.md
├── eks.tf
├── iam.tf
├── ig.tf
├── kms.tf
├── provider.tf
├── routetables.tf
├── sg.tf
├── subnets.tf
├── template.tf
├── variables.tf
└── vpc.tf
```

## Infrastructure Components

- VPC with public and private subnets across 3 availability zones
- Internet Gateway and NAT Gateways
- EKS Cluster (Kubernetes version 1.29)
- EKS Managed Node Group
- IAM roles and policies for EKS
- KMS keys for encryption
- Security Groups

## Key Features

- Cluster authentication method: API and ConfigMap
- Envelope encryption of Kubernetes secrets using KMS
- IPv4 IP family
- Public and private cluster endpoint access
- Control plane logging enabled for API server, Audit, Authenticator, Controller manager, and Scheduler
- Amazon EKS Pod Identity Agent add-on installed
- EBS CSI driver add-on installed

## Setup and Deployment

1. Clone this repository:
```
git clone https://github.com/your-org/infra-aws.git
cd infra-aws
```

2. Initialize Terraform:
```
terraform init
```

3. Review the Terraform plan:
```
terraform plan
```

4. Apply the Terraform configuration:
```
terraform apply
```

5. After successful application, configure kubectl:
```
aws eks get-token --cluster-name webapp-cve-processor | kubectl apply -f -
```

## Cleaning Up

To destroy the created resources:
```
terraform destroy
```


## Notes

- Ensure you have necessary permissions in your AWS account to create these resources.
- The EKS cluster and its components may incur costs in your AWS account.
- Always review the Terraform plan before applying to understand the changes that will be made to your infrastructure.


## Contributing

Please follow the standard GitHub workflow:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with descriptive messages.
4. Push your changes to your forked repository.
5. Submit a pull request to the main repository.

Please ensure that your code follows the existing style and conventions used in the project.