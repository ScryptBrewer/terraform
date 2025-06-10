# Instructions: refer to the readme.md You should only need to modify the terraform.tfvars file
# You can add DI Hosts or Jump hosts by simply adding the appropriate configs
# into this directory. Its not recommended to modify the main.tf

provider "aws" {
  region = var.aws_region
}

locals {
  # Get base configuration for selected deployment size
  base_config = var.deployment_configs[var.deployment_size == "custom" ? "custom" : var.deployment_size]

  # Apply custom overrides if deployment_size is "custom"
  anvil_config = var.deployment_size == "custom" ? {
    configuration  = coalesce(var.custom_anvil_configuration, local.base_config.anvil.configuration)
    instance_type  = coalesce(var.custom_anvil_instance_type, local.base_config.anvil.instance_type)
    meta_disk_size = coalesce(var.custom_anvil_meta_disk_size, local.base_config.anvil.meta_disk_size)
  } : local.base_config.anvil

  dsx_config = var.deployment_size == "custom" ? {
    instance_count = coalesce(var.custom_dsx_instance_count, local.base_config.dsx.instance_count)
    instance_type  = coalesce(var.custom_dsx_instance_type, local.base_config.dsx.instance_type)
    data_disk_size = coalesce(var.custom_dsx_data_disk_size, local.base_config.dsx.data_disk_size)
    add_volumes    = coalesce(var.custom_dsx_add_volumes, local.base_config.dsx.add_volumes)
  } : local.base_config.dsx

  # Parameters that are generally always passed to CloudFormation
  always_present_parameters = {
    DeploymentType     = var.deployment_type
    AnvilConfiguration = local.anvil_config.configuration
    AnvilType          = local.anvil_config.instance_type
    DsxCount           = local.dsx_config.instance_count
    DsxType            = local.dsx_config.instance_type
    AnvilMetaDiskSize  = local.anvil_config.meta_disk_size
    DsxDataDiskSz      = local.dsx_config.data_disk_size
    DsxAddVols         = local.dsx_config.add_volumes
    AZ1                = var.az1
    SecIpCidr          = var.sec_ip_cidr
    VpcId              = var.vpc_id
    Subnet1Id          = var.subnet_1_id
    ProfileId          = var.profile_id
    IamAdminGroupId    = var.iam_admin_group_id 
    ClusterIp          = var.cluster_ip 
    IamUserAccess      = var.iam_user_access
  }

  # Conditionally included parameters
  conditionally_included_parameters = merge(
    var.key_name != "" ? { KeyName = var.key_name } : {},
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
  parameters     = local.cfn_parameters

  tags = {
    Name         = var.stack_name
    DeployedBy   = "Terraform"
    DeploymentSize = var.deployment_size
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

output "deployment_configuration" {
  description = "Deployed configuration details"
  value = {
    deployment_size = var.deployment_size
    anvil_config    = local.anvil_config
    dsx_config      = local.dsx_config
  }
}