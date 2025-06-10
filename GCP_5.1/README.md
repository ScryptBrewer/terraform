# Hammerspace GCP Terraform Deployment

## Introduction

This project uses Terraform/OpenTofu to deploy Hammerspace infrastructure on Google Cloud Platform (GCP). The deployment includes Anvil metadata servers and DSX storage servers with flexible configuration options for different deployment sizes.

## Prerequisites

- Terraform >= 0.12.0 or OpenTofu installed
- Google Cloud SDK configured with appropriate permissions
- GCP project with required APIs enabled
- KMS key for disk encryption (optional)

## Basic Terraform/OpenTofu Setup

### 1. Install Terraform or OpenTofu

**Terraform:**
```bash
# Download from https://www.terraform.io/downloads.html
# Or use package manager (example for Ubuntu):
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**OpenTofu:**
```bash
# Download from https://opentofu.org/docs/intro/install/
# Or use package manager
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh | sh
```

### 2. Configure GCP Authentication
# Authenticate with Google Cloud
```bash
gcloud auth init 

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 3. Initialize Terraform
```bash
# from the hammerspace terraform directory
terraform init
```

# Deployment Configuration Files

## Usage Examples

### Deploy with Pre-defined Size

```bash
# Deploy starter configuration
terraform apply -var="deployment_size=starter"

# Deploy medium configuration <-- Default  
terraform apply

# Deploy large configuration
terraform apply -var="deployment_size=large"
Deploy with Custom Configuration

# Deploy with custom settings
terraform apply \
  -var="deployment_size=custom" \
  -var="custom_anvil_instance_count=3" \
  -var="custom_dsx_instance_count=8" \
  -var="custom_dsx_data_disk_count=4"

#### Run standard commands:
terraform plan
terraform apply
```

# Input Parameters

## Required Parameters (Must be configured in .tfvars files)
| Parameter | Description | Example |
|-----------|-------------|---------|
| project_id | GCP Project ID | "my-gcp-project" |
| zone | GCP Zone for deployment | "us-central1-a" |
| admin_user_password | Admin password for Hammerspace | "SecurePassword123!" |
| networks | Network name | ["projects/my-project/global/networks/my-network"] |
| sub_networks | Subnetwork name | ["projects/my-project/regions/us-central1/subnetworks/my-subnet"] |

## Hammerspace and Security Parameters
| Parameter | Description | Default | Notes |
|----------|-------------|---------|-------|
| goog_cm_deployment_name | Deployment name prefix | "hammerspace-5-1-24-318" | Used for resource naming |
| admin_user_password | Admin user password | "Password" | Change this! |
| kms_key | KMS key for disk encryption | "" | Optional, leave empty to disable |

## Anvil (Metadata Server) Parameters
| Parameter | Description | Default | Range/Options |
|-----------|-------------|---------|---------------|
| anvil_instance_count | Number of Anvil instances | 2 | 1 (Standalone) or 2 (HA) |
| machine_type | Anvil machine type | "n1-standard-4" | Any valid GCP machine type |
| data_disk_type | Anvil data disk type | "pd-standard" | pd-standard, pd-ssd, pd-extreme |
| data_disk_size | Anvil data disk size (GB) | 200 | 100-102400 |

## DSX (Storage Server) Parameters
|Parameter | Description | Default | Range/Options |
|----------|-------------|---------|---------------|
| dsx_instance_count | Number of DSX instances | 5 | 0-100 |
| dsx_instance_type | DSX machine type | "n1-standard-8" | Any valid GCP machine type |
| dsx_disk_size | DSX boot disk size (GB) | 100 | 100+ |
| dsx_data_disk_count | Data disks per DSX server | 1 | 0-20 |
| dsx_data_disk_size | Size per data disk (GB) | 200 | 100+ |
| add_volumes_dsx | Enable volume addition | true | true/false |

## Network Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| networks | List of network names | ["ChangeToYourNetwork"] |
| sub_networks | List of subnetwork names | ["ChangeToYourSubnet"] |

## Existing Solution Parameters

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|-------|
| internal_ip | Existing Anvil cluster IP | "" | Required when create_new_solution = false |
| create_new_solution | Create new Hammerspace solution | true | Set to false to add DSX to existing solution |

## System Parameters (Do not modify unless directed)

| Parameter | Description | Default |
|--|--|--|
| image | Hammerspace VM image | "projects/hammerspace-public/global/images/hammerspace-5-1-24-318" |
| boot_disk_type | Boot disk type | "pd-standard" |
| boot_disk_size | Boot disk size (GB) | 100 |
| enable_logging | Enable cloud logging | true |
| enable_monitoring | Enable cloud monitoring | true |
| enable_https | Enable HTTPS traffic | false |



# Deployment Workflow

## 1. Configure Variables

Edit your chosen .tfvars file and set required parameters:
```bash
# Edit the configuration file
nano terraform.tfvars.starter  # or terraform.tfvars.large

# Set required values:
project_id = "your-gcp-project-id"
zone = "us-central1-a"
admin_user_password = "YourSecurePassword123!"
networks = ["projects/your-project/global/networks/your-network"]
sub_networks = ["projects/your-project/regions/us-central1/subnetworks/your-subnet"]
```
## 2. Rename Configuration File

```bash
# Use starter configuration
mv terraform.tfvars.starter terraform.tfvars
```

## 3. Deploy Infrastructure

```bash
# Review the deployment plan
terraform plan

# Apply the configuration
terraform apply

# Confirm with 'yes' when prompted
```

## 4. Access Hammerspace

After deployment, use the output values to access your Hammerspace cluster:
```bash
# View outputs
terraform output

# Access management interface
# URL will be displayed in management_url output
```

# DSX Data Disk Configuration

The deployment supports flexible data disk configuration for DSX servers:
dsx_data_disk_count: 0-20 data disks per DSX server
dsx_data_disk_size: Size of each data disk in GB
Examples:

```hcl
# High-capacity configuration
dsx_data_disk_count = 8
dsx_data_disk_size = 1024

# Minimal configuration
dsx_data_disk_count = 1
dsx_data_disk_size = 200

# No additional data disks
dsx_data_disk_count = 0
```

## Adding DSX to Existing Solution

To add DSX servers to an existing Hammerspace deployment:
```bash
Set create_new_solution = false
Provide the existing Anvil cluster IP in internal_ip
Configure DSX parameters as needed
Set anvil_instance_count = 0
```

## Cleanup

To destroy the infrastructure:
```bash

terraform destroy
```

# Best Practices

Always backup your .tfvars files before making changes
Use version control to track configuration changes
Run terraform plan before applying changes
Use consistent configuration files for plan, apply, and destroy operations
Secure your admin password - don't use default values
Test with starter configuration before deploying large environments

# Troubleshooting

## Common Issues

- Authentication errors: Ensure gcloud auth application-default login is run
- Permission errors: Verify your GCP account has necessary IAM roles
- Network errors: Ensure specified networks and subnets exist
- Resource quotas: Check GCP quotas for compute instances and disks

# Support

For Hammerspace-specific issues, refer to Hammerspace documentation or contact support.

# Solution Cost estiments
Assuming the use of on-demand. Addtional discounts may apply (Sustained Use Discounts) (Committed Use Discounts) could reduce costs. 

# Compute costs
| DSX Servers | Drive Size (GB) | Config Type | Usable Capacity (TB) | Instance Cost/Hour | Storage Cost/Hour | Total Cost/Hour | Total Cost/Day | Total Cost/Month |
|-------------|-----------------|-------------|----------------------|--------------------|-------------------|-----------------|----------------|------------------|
| 5 | 100 | Starter | 4.88 | $20.00 | $10.00 | $30.00 | $720.00 | $21,600.00 |
| 5 | 200 | Starter | 9.77 | $20.00 | $20.00 | $40.00 | $960.00 | $28,800.00 |
| 5 | 1024 | Starter | 50.00 | $20.00 | $102.40 | $122.40 | $2,937.60 | $88,128.00 |
| 10 | 100 | Standard | 9.77 | $32.00 | $20.00 | $52.00 | $1,248.00 | $37,440.00 |
| 10 | 200 | Standard | 19.53 | $32.00 | $40.00 | $72.00 | $1,728.00 | $51,840.00 |
| 10 | 1024 | Standard | 100.00 | $32.00 | $204.80 | $236.80 | $5,683.20 | $170,496.00 |
| 15 | 100 | Large | 14.65 | $96.00 | $30.00 | $126.00 | $3,024.00 | $90,720.00 |
| 15 | 200 | Large | 29.30 | $96.00 | $60.00 | $156.00 | $3,744.00 | $112,320.00 |
| 15 | 1024 | Large | 150.00 | $96.00 | $307.20 | $403.20 | $9,676.80 | $290,304.00 |
| 20 | 100 | Large | 19.53 | $128.00 | $40.00 | $168.00 | $4,032.00 | $120,960.00 |
| 20 | 200 | Large | 39.06 | $128.00 | $80.00 | $208.00 | $4,992.00 | $149,760.00 |
| 20 | 1024 | Large | 200.00 | $128.00 | $409.60 | $537.60 | $12,902.40 | $387,072.00

## Drive costs Assuming 50% overhead. 
| DSX | Drive Size | Config | Usable TB | pd-standard | pd-balanced | pd-ssd | pd-extreme |
|-----|------------|--------|-----------|-------------|-------------|--------|------------|
| | | | | $/Hour $/Day $/Month | $/Hour $/Day $/Month | $/Hour $/Day $/Month | $/Hour $/Day $/Month |
| 5 | 100GB | Starter | 4.88 | $30 $720 $21,600 | $40 $960 $28,800 | $54 $1,296 $38,880 | $70 $1,680 $50,400 |
| 5 | 200GB | Starter | 9.77 | $40 $960 $28,800 | $60 $1,440 $43,200 | $88 $2,112 $63,360 | $120 $2,880 $86,400 |
| 5 | 1024GB | Starter | 50.00 | $122 $2,938 $88,128 | $225 $5,395 $161,856 | $368 $8,836 $265,075 | $532 $12,768 $383,040 |
| 10 | 100GB | Standard | 9.77 | $52 $1,248 $37,440 | $72 $1,728 $51,840 | $100 $2,400 $72,000 | $132 $3,168 $95,040 |
| 10 | 200GB | Standard | 19.53 | $72 $1,728 $51,840 | $112 $2,688 $80,640 | $168 $4,032 $120,960 | $232 $5,568 $167,040 |
| 10 | 1024GB | Standard | 100.00 | $237 $5,683 $170,496 | $442 $10,598 $317,952 | $728 $17,480 $524,390 | $1,056 $25,344 $760,320 |
| 15 | 100GB | Large | 14.65 | $126 $3,024 $90,720 | $156 $3,744 $112,320 | $198 $4,752 $142,560 | $246 $5,904 $177,120 |
| 15 | 200GB | Large | 29.30 | $156 $3,744 $112,320 | $216 $5,184 $155,520 | $300 $7,200 $216,000 | $396 $9,504 $285,120 |
| 15 | 1024GB | Large | 150.00 | $403 $9,677 $290,304 | $710 $17,050 $511,488 | $1,140 $27,372 $821,146 | $1,632 $39,168 $1,175,040 |
| 20 | 100GB | Large | 19.53 | $168 $4,032 $120,960 | $208 $4,992 $149,760 | $264 $6,336 $190,080 | $328 $7,872 $236,160 |
| 20 | 200GB | Large | 39.06 | $208 $4,992 $149,760 | $288 $6,912 $207,360 | $400 $9,600 $288,000 | $528 $12,672 $380,160 |
| 20 | 1024GB | Large | 200.00 | $538 $12,902 $387,072 | $947 $22,733 $681,984 | $1,521 $36,495 $1,094,861 | $2,176 $52,224 $1,566,720 |