# The AWS region to deploy resources in.
aws_region = "us-west-2"

# Deployment size - choose starter, medium, large, or custom
deployment_size = "medium"

# Required network configuration - MUST BE SPECIFIED
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
az1 = "us-west-2a"
subnet_1_id = "subnet-xxxxxxxxxxxxxxxxx"
sec_ip_cidr = "0.0.0.0/0"

# Optional network configuration
# az2 = "us-west-2b"
# subnet_2_id = "subnet-yyyyyyyyyyyyyyyyy"
# route_table_ids = ""

# Stack configuration
stack_name = "hammerspace-cf-stack"
deployment_type = "Create a new Hammerspace solution"

# Security configuration
key_name = "AWS_KEY_IN_REGION"
profile_id = ""
cluster_ip = ""
iam_user_access = "Disable"
iam_admin_group_id = ""

# CloudFormation template URL
cloudformation_template_url = "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/a858de46-94c0-4c58-8413-348435c234a2/d2f3c37fb3164c9fbe61be602d7ac3b6.template"

# Custom overrides (only used when deployment_size = "custom")
# custom_anvil_configuration = "High Availability"
# custom_anvil_instance_type = "m5.4xlarge (16 vCPUs, 64 GiB Mem)"
# custom_anvil_meta_disk_size = 400
# custom_dsx_instance_count = 3
# custom_dsx_instance_type = "m5.4xlarge (16 vCPUs, 64 GiB Mem)"
# custom_dsx_data_disk_size = 500
# custom_dsx_add_volumes = "Yes"
