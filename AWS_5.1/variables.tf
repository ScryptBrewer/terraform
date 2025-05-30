# Modifications to this file are not required unless you plan to update defaults
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "stack_name" {
  description = "Name for the CloudFormation stack."
  type        = string
  default     = "hammerspace-cf-stack"
}

variable "cloudformation_template_url" {
  description = "URL of the CloudFormation template."
  type        = string
  default     = "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/a858de46-94c0-4c58-8413-348435c234a2/d2f3c37fb3164c9fbe61be602d7ac3b6.template"
}

variable "deployment_type" {
  description = "Parameter for CloudFormation: Choose to deploy a new stack or add DSX nodes."
  type        = string
  default     = "Create a new Hammerspace solution"
}

variable "anvil_configuration" {
  description = "Parameter for CloudFormation: High availability or Standalone Anvil."
  type        = string
  default     = "High Availability"
}

variable "anvil_type" {
  description = "Parameter for CloudFormation: EC2 instance type for Anvil."
  type        = string
  default     = "m5.2xlarge" # CF default is "m5.2xlarge (8 vCPUs, 32 GiB Mem)"
}

variable "dsx_type" {
  description = "Parameter for CloudFormation: EC2 instance type for DSX."
  type        = string
  default     = "m5.xlarge" # CF default is "m5.xlarge (4 vCPUs, 16 GiB Mem)"
}

variable "dsx_count" {
  description = "Parameter for CloudFormation: Number of DSX instances."
  type        = number
  default     = 1
}

variable "anvil_meta_disk_size" {
  description = "Parameter for CloudFormation: Anvil Metadata Disk Size in GB."
  type        = number
  default     = 200
}

variable "dsx_data_disk_sz" {
  description = "Parameter for CloudFormation: DSX Data Store Size in GB."
  type        = number
  default     = 200
}

variable "dsx_add_vols" {
  description = "Parameter for CloudFormation: Automatically add additional volumes to Hammerspace."
  type        = string
  default     = "Yes"
}

variable "vpc_id" {
  description = "Parameter for CloudFormation: VPC ID."
  type        = string
}

variable "az1" {
  description = "Parameter for CloudFormation: Availability Zone for Anvil."
  type        = string
  # No default in CloudFormation.
}

variable "subnet_1_id" {
  description = "Parameter for CloudFormation: Data/Management Subnet ID."
  type        = string
}

variable "cluster_ip" {
  description = "Parameter for CloudFormation: Anvil Cluster IP (optional)."
  type        = string
  default     = ""
}

variable "sec_ip_cidr" {
  description = "Parameter for CloudFormation: Security Group IP/CIDR."
  type        = string
  # No default in CloudFormation.
}

variable "profile_id" {
  description = "Parameter for CloudFormation: Instance Profile ID (optional)."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Parameter for CloudFormation: Admin KeyPair Name (optional)."
  type        = string
  default     = ""
}

variable "iam_user_access" {
  description = "Parameter for CloudFormation: Admin IAM Group Access."
  type        = string
  default     = "Disable"
}

variable "iam_admin_group_id" {
  description = "Parameter for CloudFormation: Admin IAM Group ID (optional)."
  type        = string
  default     = ""
}

variable "az2" {
  description = "Parameter for CloudFormation: Second AZ to use (optional)."
  type        = string
  default     = ""
}

variable "subnet_2_id" {
  description = "Parameter for CloudFormation: Second Subnet ID (optional)."
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "Parameter for CloudFormation: Route Table ID (optional)."
  type        = string
  default     = ""
}
