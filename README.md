# CVELens EKS Infrastructure with Terraform

This repository contains Terraform code to set up an Amazon EKS (Elastic Kubernetes Service) cluster and its associated infrastructure on AWS.

## Prerequisites
- AWS CLI installed and configured with a profile that has the necessary permissions to create the resources defined in the Terraform code [AWS CLI Configuration guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- Install Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/terraform/getting-started/install.html)
- Install Packer: [Packer Installation Guide](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
- Install Kubernetes CLI (kubectl): [kubectl Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Repository Structure
```
.
|── dashboards/
│   ├── k8.json
│   └── cve.json
│   ├── kafka.json
│   └── postgres.json
├── README.md
├── Jenkinsfile
├── acm.tf
├── dns.tf
├── eks.tf
├── fluentbit.tf
├── grafana.tf
├── grafana.yaml
├── helm.tf
├── iam.tf
├── internetgw.tf
├── istio_custom.yaml
├── k8s.tf
├── k8s-config.yaml
├── kms.tf
├── postgress.yaml
|── prometheus.tf
|── prometheus.yaml
├── provider.tf
├── routetables.tf
├── sg.tf
├── subnets.tf
├── variables.tf
└── vpc.tf
```

## Infrastructure Components

- A VPC with 3 public and 3 private subnets across 3 availability zones
- 3 NAT Gateways to allow the aforementioned private subnets to allow outbound internet access and an internet gateway for the public subnets
- EKS Cluster based on Kubernetes version 1.29 with cluster add-ons such as EBS CSI Driver, VPC-CNI, and Kube-proxy, etc with high priority classes for critical add-ons
- IAM policies and roles for the EKS cluster and its worker nodes to interact with other AWS services such as KMS, CloudWatch, Route53, SNS, etc and to allow Kubernetes Service Accounts (IRSA) to assume roles and interact with AWS services
- Security Groups for the EKS cluster, worker nodes, and other resources
- AWS Certificate Manager (ACM) and Route53 for automatic validation, issuance and renewal of SSL certificates for the CVELens application
- ExternalDNS integrated with Route53 for automatic creation and deletion of DNS records in Route53 for the CVELens application
- Prometheus with custom Grafana dashboards for monitoring and alerting on the EKS cluster, worker nodes, PostgreSQL database, Kafka, and the CVELens LLM chatbot application
- Fluent Bit for log collection and forwarding to Cloudwatch Logs for the EKS cluster and its components
- Istio for service mesh, traffic management and blue-green deployments
- Helm for managing Kubernetes applications and deploying the CVELens application
- EKS Cluster Autoscaler for automatic scaling of worker nodes based on resource utilization
- KMS for encryption of sensitive data in EBS volumes 
- Kubernetes namespaces, priority classes, manifess, and other resources for organizing and managing the various microservices that make up the CVELens application

## Setup and Deployment

To deploy the CVELens infrastructure using Terraform, follow these steps:

1. Clone this repository to your local machine.
2. Ensure that you have Terraform installed and the AWS CLI configured with the necessary credentials.
3. Review and modify the `variables.tf` file if needed, such as updating the AWS region, instance type, etc.
4. Run the `terraform init` following command to initialize Terraform.
5. Run the `terraform plan` command to preview the changes that Terraform will make.
6. If the plan looks good, run the `terraform apply` command to apply the changes and create the infrastructure.
7. Terraform will create the specified resources in your AWS account. Once the deployment is complete, you can access the CVELens application using the domain name entered while running the Terraform apply command.

## Destroying the Infrastructure

To destroy the Jenkins infrastructure and clean up the resources, run the `terraform destroy` command

Terraform will prompt you to confirm the destruction of the resources. Enter `yes` to proceed.

## CI/CD Pipeline
This repository follows a CI/CD process that integrates GitHub and Jenkins using webhooks to trigger automated workflows. The CI/CD process ensures that code quality, infrastructure validation, and versioning are handled automatically before code can be merged and released.

### CI/CD Workflow Overview
#### GitHub -> Jenkins Integration
- GitHub Webhook: A webhook is configured on this repository to trigger Jenkins jobs on specific GitHub events (e.g., pull requests).
- Jenkins Pipelines: There is a single Jenkins pipelines (JenkinsFile) that handle Terraform code validation, and commit message validation using Conventional Commits standard.

#### CI/CD Pipeline Flow
##### Code Validation and commit message validation:

- Trigger: Pull requests to the main branch
- This pipeline performs several checks to ensure the quality and validity of the Terraform infrastructure code and that the commit messages adhere to the Conventional Commits standard before allowing a merge.

## Multiple Environments
In order to deploy this infrastructure in multiple environments without duplicating the code and while maintaining distinct Terraform state files, I'd recommend using Terraform Workspaces
1. **Create a new workspace:**
   ```bash
   terraform workspace new workspacenew
2. **Switch to the new workspace:**
   ```bash
   terraform workspace select workspacenew 
3. **List workspaces:**
   ```bash
   terraform workspace list 
4. **Delete a workspace:**
   ```bash
   terraform workspace select default 
   terraform workspace delete workspacenew 

## Notes
- Ensure you have necessary permissions in your AWS account to create these resources.
- The EKS cluster and its components will incur costs in your AWS account. Ensure you understand the costs associated with running an EKS cluster and its components.
- Always review the Terraform plan before applying to understand the changes that will be made to your infrastructure.
- This code includes EKS autoscaling, which will automatically scale the worker nodes based on resource utilization, upto 6 EC2 instances using the t3.xlarge plan. Ensure you have set up billing alerts in your AWS account to avoid unexpected charges.