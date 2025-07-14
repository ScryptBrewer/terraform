# Hammerspace AWS Terraform Deployment

## Introduction

This project uses Terraform/OpenTofu to deploy Hammerspace infrastructure on Amazon Web Services (AWS). The deployment includes Anvil metadata servers and DSX storage servers with flexible configuration options for different deployment sizes.

## Prerequisites

- Terraform >= 0.12.0 or OpenTofu installed
- AWS CLI configured with appropriate permissions
- AWS account with required services enabled
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

## 2. Configure AWS Authentication
```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Or create the file directly
create ~/.aws/credentials
[default]
aws_access_key_id = XXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_default_region  = us-east-1
```

## 3. Initialize Terraform

```bash
# from the hammerspace terraform directory
tofu init
```
# Deployment Configuration Files

## Usage Examples

## Deploy with Pre-defined Size

```bash 
# Deploy starter configuration
tofu apply -var="deployment_size=starter"

# Deploy medium configuration <-- Default  
tofu apply

# Deploy large configuration
tofu apply -var="deployment_size=large"
```

## Deploy with Custom Configuration

```bash 
# Deploy with custom settings
tofu apply \
  -var="deployment_size=custom" \
  -var="custom_anvil_instance_count=3" \
  -var="custom_dsx_instance_count=8" \
  -var="custom_dsx_data_disk_count=4"
  ```
## Run standard commands:

```bash
# assuming the terraform.tfvars has been updated
tofu plan
tofu apply
```
# Input Parameters

## Required Parameters (Must be configured in .tfvars files)

| Parameter | Description | Example |
|------------|---------------------------|-------------|
| aws_region | AWS Region for deployment | "us-east-1" |
| availability_zone | AWS Availability Zone | "us-east-1a" |
| admin_user_password | Admin password for Hammerspace | "SecurePassword123!" |
| vpc_id  | VPC ID for deployment | "vpc-12345678" |
| subnet_id | Subnet ID for deployment |  "subnet-12345678" |

## Hammerspace and Security Parameters

| Parameter | | Description | Default Notes|
|-----------|-|-------------|--------------| 
| deployment_name | Deployment name prefix |  "hammerspace-5-1-24-318" |  Used for resource naming |
| admin_user_password | Admin user password | "Password"  Change this! |
| kms_key_id  | KMS key for disk encryption | "" |

## Anvil (Metadata Server) Parameters

| Parameter | Description | Default | Range/Options|
|-----------|-------------|---------|--------------|
| anvil_instance_count | Number of Anvil instances  |  2  |  1 (Standalone) or 2 (HA)| 
| anvil_instance_type | Anvil instance type "m5.xlarge" | Any valid AWS instance type| 
| anvil_data_disk_type | Anvil data disk type |  "gp3"  |  gp2, gp3, io1, io2| 
| anvil_data_disk_size | Anvil data disk size (GB) | 200 | 100-16384| 

## DSX (Storage Server) Parameters

| Parameter | Description | Default | Range/Options |
|-----------|-------------|---------|---------------|
| dsx_instance_count | Number of DSX instances 5 | 0-100 |
| dsx_instance_type | DSX instance type | "m5.2xlarge" | | Any valid AWS instance type |
| dsx_root_disk_size | DSX root disk size (GB) 100 100+ |
| dsx_data_disk_count Data disks per DSX server | 1 | 0-20 |
| dsx_data_disk_size | Size per data disk (GB) 200 100+ |
| dsx_data_disk_type | DSX data disk type | "gp3" | gp2, gp3, io1, io2 |
| add_volumes_dsx Enable volume addition | true |  true/false |

## Network Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| vpc_id | VPC ID | "ChangeToYourVPC" |
| subnet_id | Subnet ID | "ChangeToYourSubnet" |
| security_group_ids | List of security group IDs | [] |

## Existing Solution Parameters

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------------|
| internal_ip Existing Anvil cluster IP | "" | Required when create_new_solution = false |
| create_new_solution Create new Hammerspace solution true | Set to false to add DSX to existing solution |

## System Parameters (Do not modify unless directed)

| Parameter | Description | Default |
|-----------|-------------|---------|
| ami_id | Hammerspace AMI ID | "ami-hammerspace-5-1-24-318" |
| root_disk_type | Root disk type | "gp3" |
| root_disk_size | Root disk size (GB) 100 |
| enable_detailed_monitoring | Enable detailed monitoring | true |
| enable_termination_protection | Enable termination protection | false |






4.  **Verify Configuration (Optional but Recommended):**
 |  You can verify that your AWS CLI is configured correctly by running a simple command, for example, to list your S3 buckets (if you have any):
 |  ```bash
 |  aws s3 ls
 |  ```
 |  Or, to get your caller identity:
 |  ```bash
 |  aws sts get-caller-identity
 |  ```
 |  If these commands execute successfully and return the expected information, your default profile is configured.

**Security Note:**
- Your AWS access keys grant significant access to your AWS account. Keep your Secret Access Key confidential.
- Do not commit your `~/.aws/credentials` file to any version control system.
- Consider using IAM roles for EC2 instances or other AWS services if running OpenTofu from within AWS, to avoid storing long-lived credentials.

## IAM Permissions for Deployment

To successfully deploy the Hammerspace CloudFormation stack and manage associated S3 buckets, the IAM user whose credentials you configured above needs specific permissions.

A recommended IAM policy is provided in the file:
**`Hammerspace_CloudFormation_Deployer_IAM_Policy.json`**

This policy grants the minimum necessary permissions for:
- CloudFormation stack operations (create, delete, update, describe).
- Managing EC2 resources (instances, security groups, volumes).
- Managing IAM resources created by the template (roles, instance profiles, groups).
- Passing IAM roles to EC2 instances.
- Fetching the CloudFormation template from S3.
- Creating, deleting, and managing S3 buckets as required by the Hammerspace product.

### Applying the IAM Policy to a User

You can apply this policy to an IAM user in the AWS Management Console:

1.  **Navigate to the IAM Console:**
- Log in to your AWS Management Console.
- Search for and navigate to the "IAM" service.

2.  **Create or Select the User:**
- If you are applying the policy to an existing user (the one whose credentials you configured with `aws configure`), select "Users" from the left navigation pane and find the user in the list. Click on the username.
- If you need to create a new user for this purpose, click "Add users", follow the prompts, and ensure you generate access keys for this new user to configure with the AWS CLI.

3.  **Create and Attach the Policy:**
- In the user's summary page, go to the "Permissions" tab.
- Under "Permissions policies", click "Add permissions" and select "Attach policies directly".
- Click the "Create policy" button. This will open a new tab/window.
- In the policy editor, select the "JSON" tab.
- Open the `Hammerspace_CloudFormation_Deployer_IAM_Policy.json` file from this repository, copy its entire content.
- Paste the JSON content into the policy editor in the AWS console, replacing any existing content.
- Click "Next: Tags" (you can add tags if desired, or skip).
- Click "Next: Review".
- Give the policy a **Name** (e.g., `HammerspaceCloudFormationDeployerPolicy`) and an optional **Description**.
- Review the permissions and click "Create policy".
- Close the policy creation tab/window and return to the user's permissions tab where you clicked "Create policy".
- You may need to refresh the list of policies. Search for the policy you just created by its name (e.g., `HammerspaceCloudFormationDeployerPolicy`).
- Select the checkbox next to your newly created policy.
- Click "Next" and then "Add permissions".

The IAM user should now have the necessary permissions to deploy the Hammerspace CloudFormation stack using OpenTofu.

**IAM Best Practices:**
- **Least Privilege:** Always grant only the permissions necessary. Regularly review this policy to ensure it aligns with the actual requirements of the CloudFormation template.
- **Scope Down `iam:PassRole`:** The `iam:PassRole` permission in the provided policy is broad (`"Resource": ["arn:aws:iam::*:role/*"]`). For enhanced security, restrict this to the specific role ARNs that will be passed to EC2 instances by the CloudFormation template.
- **Regular Audits:** Periodically review IAM user permissions and policies.

## OpenTofu Configuration Files

This project includes the following OpenTofu configuration files:

- `main.tf`: Defines the AWS provider and the `aws_cloudformation_stack` resource that deploys the Hammerspace template. It also includes outputs from the CloudFormation stack.
- `variables.tf`: Declares all input variables used by the OpenTofu configuration, which are passed as parameters to the CloudFormation template.
- `terraform.tfvars`: Sets the values for the variables defined in `variables.tf`. **You will need to customize this file with your specific VPC ID, Subnet ID, AZ, and other required parameters.** (The `.tfvars` extension is standard and used by both OpenTofu and Terraform).

## Usage

1.  **Clone the repository (if applicable) or ensure you have all `.tf`, `.tfvars`, and `.json` policy files.**

2.  **Configure AWS Credentials & IAM Permissions**: Ensure your AWS default profile is configured and the IAM user has the `HammerspaceCloudFormationDeployerPolicy` (or equivalent) attached, as described above.

3.  **Customize `terraform.tfvars`**:
 |  There are 4 deployment-sizes availble [starter, medium, large, or custom]
 |  Open `terraform.tfvars` and update the placeholder values (e.g., `vpc_id`, `subnet_1_id`, `az1`, `sec_ip_cidr`) with your specific environment details. Review all other variables to ensure they match your desired Hammerspace configuration.

4.  **Initialize OpenTofu**:
Navigate to the directory containing the OpenTofu files and run:
```bash
tofu init
```

5.  **Plan the Deployment**:
Review the execution plan to see what resources OpenTofu will manage (in this case, the CloudFormation stack):
```bash
tofu plan
```

6.  **Apply the Configuration**:
If the plan looks correct, apply the configuration to deploy the Hammerspace stack:
```bash
tofu apply
```
OpenTofu will prompt for confirmation before proceeding. Type `yes` to approve.

7.  **Access Outputs**:
Once the deployment is complete, OpenTofu will display any defined outputs, such as the `ManagementIp` and `ManagementUrl`. You can also view them later with:
```bash
tofu output
```

## Destroying Resources

To remove the resources created by this OpenTofu configuration (i.e., delete the CloudFormation stack):

1.  Navigate to the directory containing the OpenTofu files.
2.  Run the destroy command:
```bash
tofu destroy
```
OpenTofu will prompt for confirmation. Type `yes` to approve.

**Caution**: This will delete the CloudFormation stack and all resources it manages. Ensure you want to remove the entire Hammerspace deployment.

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
| 20 | 1024 | Large | 200.00 | $128.00 | $409.60 | $537.60 | $12,902.40 | $387,072.00 |


## Drive costs Assuming 50% overhead total capacity is 2x.
| DSX | Drive Size | Config | Usable TB | gp2 (General Purpose SSD) | gp3 (General Purpose SSD) | io1/io2 (Provisioned IOPS) | st1 (Throughput Optimized HDD) |
|-----|------------|--------|-----------|-------------|-------------|--------|------------|
|  |  |  | $/Hour | $/Day | $/Month | $/Hour | $/Day | $/Month | $/Hour | $/Day | $/Month | $/Hour | $/Day | $/Month |
| 5 | 100GB | Starter | 4.88 | $25 | $600 | $18,000 | $20 | $480 | $14,400 | $65 | $1,560 | $46,800 | $15 | $360 | $10,800 |
| 5 | 200GB | Starter | 9.77 | $35 | $840 | $25,200 | $30 | $720 | $21,600 | $95 | $2,280 | $68,400 | $22 | $528 | $15,840 |
| 5 | 1024GB | Starter | 50.00 | $110 | $2,640 | $79,200 | $95 | $2,280 | $68,400 | $320 | $7,680 | $230,400 | $70 | $1,680 | $50,400 |
| 10 | 100GB | Standard | 9.77 | $45 | $1,080 | $32,400 | $38 | $912 | $27,360 | $125 | $3,000 | $90,000 | $28 | $672 | $20,160 |
| 10 | 200GB | Standard | 19.53 | $65 | $1,560 | $46,800 | $55 | $1,320 | $39,600 | $185 | $4,440 | $133,200 | $40 | $960 | $28,800 |
| 10 | 1024GB | Standard | 100.00 | $215 | $5,160 | $154,800 | $185 | $4,440 | $133,200 | $630 | $15,120 | $453,600 | $135 | $3,240 | $97,200 |
| 15 | 100GB | Large | 14.65 | $115 | $2,760 | $82,800 | $95 | $2,280 | $68,400 | $185 | $4,440 | $133,200 | $70 | $1,680 | $50,400 |
| 15 | 200GB | Large | 29.30 | $140 | $3,360 | $100,800 | $120 | $2,880 | $86,400 | $275 | $6,600 | $198,000 | $85 | $2,040 | $61,200 |
| 15 | 1024GB | Large | 150.00 | $365 | $8,760 | $262,800 | $315 | $7,560 | $226,800 | $950 | $22,800 | $684,000 | $205 | $4,920 | $147,600 |
| 20 | 100GB | Large | 19.53 | $150 | $3,600 | $108,000 | $125 | $3,000 | $90,000 | $245 | $5,880 | $176,400 | $90 | $2,160 | $64,800 |
| 20 | 200GB | Large | 39.06 | $185 | $4,440 | $133,200 | $160 | $3,840 | $115,200 | $365 | $8,760 | $262,800 | $110 | $2,640 | $79,200 |
| 20 | 1024GB | Large | 200.00 | $485 | $11,640 | $349,200 | $420 | $10,080 | $302,400 | $1,265 | $30,360 | $910,800 | $275 | $6,600 | $198,000 |

## Disclaimer: Preliminary Cost Estimates
* These figures are high-level estimates for planning purposes only and are not official quotes.Actual costs will vary based on your final configuration, including AWS Region, provisioned storage performance (IOPS/throughput), data transfer fees, and the purchasing model used (e.g., On-Demand vs. Savings Plans). These estimates do not include all potential service charges.For an accurate quote, please use the official AWS Pricing Calculator.