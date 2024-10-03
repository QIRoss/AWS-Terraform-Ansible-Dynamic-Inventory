# Multi Environment Terraform Ansible Dynamic Inventory

Studies based in day 23-24 of 100 Days System Design for DevOps and Cloud Engineers.

https://deoshankar.medium.com/100-days-system-design-for-devops-and-cloud-engineers-18af7a80bc6f

Days 21–30: Advanced Infrastructure as Code (IaC)

Day 23–24: Automate multi-environment setups using Terraform and Ansible dynamic inventories.

## Project Overview

* Goal: Automate the provisioning of EC2 instances using Terraform and configure them dynamically with Ansible by installing Docker and running a FastAPI application.
* Multi-environment setup: Create separate environments such as dev, staging, and prod using Terraform, and manage them with Ansible.
* Dynamic inventory: Automatically fetch the public IPs of the instances provisioned by Terraform and use Ansible to configure them dynamically.

## Prerequisites
* Terraform (v1.0+)
* Ansible (v2.9+)
* AWS CLI with a configured profile (qiross)
* SSH key (qiross.pem) available and uploaded to AWS
* Python (for dynamic inventory script)

## Setup

### Clone the Repository:
```
git clone https://github.com/qiross/terraform-ansible-dynamic-inventory.git
cd terraform-ansible-dynamic-inventory
```

### Directory Structure:
```
├── ansible
│   ├── inventory
│   │   └── dynamic_inventory.py   # Script for dynamic inventory
│   ├── playbooks
│   │   └── common.yml             # Ansible playbook to install Docker and run FastAPI
│   └── ansible.cfg                # Ansible configuration file
├── terraform
│   ├── environments               # Environment-specific variables
│   ├── main.tf                    # Main Terraform configuration
│   ├── outputs.tf                 # Outputs for Terraform
│   └── variables.tf               # Terraform variables definition
```

## Usage Instructions

### Building and Pushing the Docker Image to DockerHub (optional)

To build the Docker image for the FastAPI application and push it to DockerHub, follow these steps:<br>
Navigate to the Docker folder:
```
cd docker
```
Build the Docker image: Use the following command to build the image, tagging it as qiross/fastapi-hello-world:latest:
```
docker build -t qiross/fastapi-hello-world:latest .
```
Log in to DockerHub: Make sure you're logged into DockerHub using:
```
docker login
```
Push the image to DockerHub: Once the image is built successfully, push it to DockerHub:
```
docker push qiross/fastapi-hello-world:latest
```

### Terraform: Provisioning Infrastructure

Initialize Terraform:<br>
Before applying any configurations, you must initialize the Terraform working directory.
```
cd terraform
terraform init
```

Plan and Apply Terraform Configuration:<br>
To create EC2 instances in the desired environment (e.g., dev), run:
```
terraform plan -var-file=./environments/dev/terraform.tfvars
terraform apply -var-file=./environments/dev/terraform.tfvars
```

Repeat this for other environments if you want(staging, prod):
```
terraform apply -var-file=./environments/staging/terraform.tfvars
terraform apply -var-file=./environments/prod/terraform.tfvars
```

You can see outputs again running:
```
terraform output -json
```

### Ansible: Configure Instances

Once the infrastructure is provisioned and Terraform outputs the public IPs, use Ansible to install Docker and deploy the FastAPI application.

Run the Ansible Playbook:
```
#inside terraform folder
ansible-playbook -i ../ansible/inventory/dynamic_inventory.py ../ansible/playbooks/common.yml --ssh-extra-args="-o StrictHostKeyChecking=no"
```

This will:

* Use the dynamic inventory to fetch the public IPs of the EC2 instances provisioned by Terraform.
* Install Docker on each instance.
* Pull and run the FastAPI application using the qiross/fastapi-hello-world Docker image.

### Verify Deployment

To verify that the FastAPI application is running, you can:

* SSH into the instance:
```
ssh -i "qiross.pem" ubuntu@<public_ip_of_instance>
```
* Access FastAPI via Browser: Navigate to:
```
http://<public_ip_of_instance>
```
You should see the message: ```{"message": "Hello, Inventory!"}```

### Clean Up
To remove the infrastructure and clean up, run:
```
terraform destroy -var-file=./environments/dev/terraform.tfvars
```
Repeat for other environments if necessary:
```
terraform destroy -var-file=./environments/staging/terraform.tfvars
terraform destroy -var-file=./environments/prod/terraform.tfvars
```

## Key Components

### Terraform Configuration ```(main.tf)```:
* Provisions EC2 instances in AWS.
* Uses environment-specific terraform.tfvars files to differentiate configurations (e.g., dev, staging, prod).

### Dynamic Inventory ```(dynamic_inventory.py)```:
* Automatically retrieves the public IP addresses of EC2 instances using terraform output.
* Generates a dynamic inventory for Ansible to target the newly created EC2 instances.

### Ansible Playbook ```(common.yml)```:
* Installs Docker on the EC2 instances.
* Runs a FastAPI application inside a Docker container.

## Author
This project was implemented by [Lucas de Queiroz dos Reis][2]. It is based on the Day 23–24: Automate multi-environment setups using Terraform and Ansible dynamic inventories from the [100 Days System Design for DevOps and Cloud Engineers][1].

[1]: https://deoshankar.medium.com/100-days-system-design-for-devops-and-cloud-engineers-18af7a80bc6f "Medium - Deo Shankar 100 Days"
[2]: https://www.linkedin.com/in/lucas-de-queiroz/ "LinkedIn - Lucas de Queiroz"