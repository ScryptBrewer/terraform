# Instructions: refer to the readme.md You should only need to modify the terraform.tfvars file
# You can add DI Hosts or Jump hosts by simply adding the appropriate configs
# into this directory. Its not recomende to modify the main.tf

provider "aws" {
  region = var.aws_region
  # Ensure your AWS provider is configured for authentication (e.g., via
  # environment variables, shared credentials file, or instance profile).
  # For consistency and best practice, my dear, consider using a named
  # profile from your ~/.aws/credentials file, often 'default' if not
  # specified otherwise.
}

locals {
  # Parameters that are generally always passed to CloudFormation
  always_present_parameters = {
    DeploymentType     = var.deployment_type
    AnvilConfiguration = var.anvil_configuration
    AnvilType          = var.anvil_type
    DsxCount           = var.dsx_count
    AnvilMetaDiskSize  = var.anvil_meta_disk_size
    AZ1                = var.az1
    SecIpCidr          = var.sec_ip_cidr
    ProfileId         = var.profile_id
    IamAdminGroupId   = var.iam_admin_group_id
    ClusterIp         = var.cluster_ip
    VpcId             = var.vpc_id
    Subnet1Id         = var.subnet_1_id
  }

  # Conditionally included parameters.
  conditionally_included_parameters = merge(
    var.dsx_type != "" ? { DsxType = var.dsx_type } : {},
    var.dsx_data_disk_sz != "" ? { DsxDataDiskSz = var.dsx_data_disk_sz } : {},
    var.dsx_add_vols != "" ? { DsxAddVols = var.dsx_add_vols } : {},
    var.key_name != "" ? { KeyName = var.key_name } : {},
    var.iam_user_access != "" ? { IamUserAccess = var.iam_user_access } : {},
    var.az2 != "" ? { AZ2 = var.az2 } : {},
    var.subnet_2_id != "" ? { Subnet2Id = var.subnet_2_id } : {},
    var.route_table_ids != "" ? { RouteTableIDs = var.route_table_ids } : {},
    )

  # Final parameters map to be passed to the CloudFormation stack
  cfn_parameters = merge(
    local.always_present_parameters,
    local.conditionally_included_parameters
  )
}

resource "aws_cloudformation_stack" "hammerspace_stack" {
  name           = var.stack_name
  template_url   = var.cloudformation_template_url
  capabilities   = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  parameters = local.cfn_parameters
  # timeout_in_minutes = 60

  tags = {
    Name       = var.stack_name
    DeployedBy = "Terraform"
  }
}

# --- Outputs from the CloudFormation Stack ---
output "management_ip" {
  description = "Management IP address from CloudFormation stack."
  value       = aws_cloudformation_stack.hammerspace_stack.outputs["ManagementIp"]
}

output "management_url" {
  description = "Management URL from CloudFormation stack."
  value       = aws_cloudformation_stack.hammerspace_stack.outputs["ManagementUrl"]
}

output "management_instance_id" {
  description = "Management Instance ID/ Default password from CloudFormation stack."

  value = try(
    aws_cloudformation_stack.hammerspace_stack.outputs["ManagementInstanceId"],
    null
  )
}

output "iam_admin_group_url" {
  description = "IAM Admin Group URL from CloudFormation stack."
  value = aws_cloudformation_stack.hammerspace_stack.outputs["IAMAdminGroupUrl"]
}