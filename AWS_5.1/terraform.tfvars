# The AWS region to deploy resources in.
aws_region = "us-west-2"

# Parameter for CloudFormation: Availability Zone for Anvil.
az1 = "us-west-2a" # Replace with your AZ

# Parameter for CloudFormation: VPC ID.
vpc_id = "vpc-xxxxxxxxxxxxxxxxx" 

# Parameter for CloudFormation: Data/Management Subnet ID.
subnet_1_id = "subnet-xxxxxxxxxxxxxxxxx"

# Parameter for CloudFormation: Availability Zone for Anvil.
#az2 = "us-west-2b" # Replace with your AZ

# Name for the CloudFormation stack.
stack_name = "hammerspace-cf-stack"

# Parameter for CloudFormation: Choose to deploy a new stack or add DSX nodes.
deployment_type = "Create a new Hammerspace solution"

# Parameter for CloudFormation: High availability or Standalone Anvil.
anvil_configuration = "High Availability"

# Parameter for CloudFormation: EC2 instance type for Anvil. This must match the stack Exactly
anvil_type = "m5.2xlarge (8 vCPUs, 32 GiB Mem)"

# Parameter for CloudFormation: Anvil Metadata Disk Size in GB.
anvil_meta_disk_size = 200

# Parameter for CloudFormation: EC2 instance type for DSX. This must match the stack Exactly
dsx_type = "m5.2xlarge (8 vCPUs, 32 GiB Mem)"

# Parameter for CloudFormation: Number of DSX instances.
dsx_count = 1

# Parameter for CloudFormation: DSX Data Store Size in GB.
dsx_data_disk_sz = 200

# Parameter for CloudFormation: Automatically add additional volumes to Hammerspace.
dsx_add_vols = "Yes"

# Parameter for CloudFormation: Admin KeyPair Name (optional).
key_name = "AWS_KEY_IN_REGION"

# Parameter for CloudFormation: Security Group IP/CIDR.
sec_ip_cidr = "0.0.0.0/0" # Replace with your desired CIDR

# MultiAZ deployments
subnet_2_id = ""
route_table_ids = ""

# Parameter for CloudFormation: Instance Profile ID (optional).
profile_id = ""

# Less commonly used parameters
# Parameter for CloudFormation: Anvil Cluster IP Existing reqiored with ADD DSX workflow.
cluster_ip = ""

# URL of the CloudFormation template.
cloudformation_template_url = "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/a858de46-94c0-4c58-8413-348435c234a2/d2f3c37fb3164c9fbe61be602d7ac3b6.template"

# Parameter for CloudFormation: Admin IAM Group Access.
iam_user_access = "Disable"

# Parameter for CloudFormation: Admin IAM Group ID (optional).
iam_admin_group_id = ""
