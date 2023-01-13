# Terraform snippet for deploying CloudFormation Template

## Prerequisites:
1. AWS account
2. IAM role with necessary permissions
3. Terraform & AWS CLI configured on machine from which the scripts are to be run
4. AMI Id (Which you want to Launch) for particular region.
5. Key Pair name for Praticular Region.

## The files included are:

1)  main.tf: main.tf file contains the terraform script to create necessary resources with CloudFormation Stack like below.

## Changes Required to RUN Terraform snippet

1. Need to replace AMI ID according to Region.
2. Need to change Region or Availability zone
3. Need to replace keyname according to Region.
4. Need to change VPCCidr,CidrBlock and Myip (Your Workstation IP to connect EC2) according to your network.

## Follow Below Steps to RUN Terraform snippet

1. Create folder and Clone this repo.
2. Change required parameters value if you want.
3. Initialize terraform using 
```bash
terraform init
```
4. Show changes required by the current configuration 
```bash
terraform plan
```
5. Create or update infrastructure 
```bash
terraform apply
```
Your infra is ready to use now.

6. Destroy previously-created infrastructure 
```bash
terraform destroy
```
## Output
- Cloudformaion stack created with name "networking-stack"
- EC2 instance created with newly createtd VPC,subnet and SG.
