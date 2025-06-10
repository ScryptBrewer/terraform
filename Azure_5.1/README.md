# Hammerspace on Azure Deployment with Terraform/OpenTofu & ARM Template

This project automates the deployment of a Hammerspace environment on Microsoft Azure using an Azure Resource Manager (ARM) template, orchestrated by Terraform (or its open-source fork, OpenTofu). It allows for deploying Hammerspace onto either a newly created network or an existing Azure network infrastructure.

## Project Goals

*   Automate the deployment of Hammerspace Anvil and Data Services (DSX) nodes.
*   Provide flexibility to deploy on new or existing Azure networking.
*   Manage Azure authentication securely without hardcoding credentials.
*   Define infrastructure as code for repeatability and version control.

## File Structure

*   `main.tf`: The primary Terraform/OpenTofu configuration file. It defines the Azure provider, the Azure Resource Group, and orchestrates the deployment of the ARM template.
*   `variables.tf`: Declares all input variables used by the Terraform configuration. These variables allow customization of the deployment (e.g., instance types, counts, network details, application settings).
*   `terraform.tfvars`: Provides the actual values for the variables defined in `variables.tf`. **This file should be customized for your specific deployment and sensitive values (like passwords) should be managed securely (e.g., via environment variables or a secrets manager).**
*   `network.tf`: (Optional) If you choose to have Terraform create the network, this file contains the definitions for Azure networking resources (Virtual Network, Subnets, Network Security Group) using native Terraform Azure provider resources. If deploying to an existing network, this file might be omitted or its resources made conditional.
*   `hammerspace_template.json`: The Azure Resource Manager (ARM) template that defines the Hammerspace virtual machines, storage, load balancers, and other necessary Azure resources for the application itself.
*   `minimum_permissions.json`: A sample JSON file outlining the minimum IAM permissions generally required for the Service Principal or user account executing this Terraform/OpenTofu configuration.
*   `README.md`: This file – providing an overview, setup instructions, and other relevant information.

## Prerequisites

1.  **Terraform or OpenTofu**:
    *   **OpenTofu**: Install from [opentofu.org](https://opentofu.org/docs/getting-started/install).
    *   **Terraform**: Install from [terraform.io](https://developer.hashicorp.com/terraform/downloads).
2.  **Azure CLI**: Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3.  **Azure Account & Subscription**: You need an active Azure subscription.
4.  **Hammerspace ARM Template**: Ensure `hammerspace_template.json` is present in the project directory.
5.  **Permissions**: The identity (user or Service Principal) running Terraform/OpenTofu needs adequate permissions in your Azure subscription/resource group. See `minimum_permissions.json` for guidance.

## Authentication

It is strongly recommended **not** to hardcode credentials. Choose one of the following methods:

### 1. Azure CLI (Recommended for Local Development)
   Terraform/OpenTofu can automatically use credentials from an active Azure CLI session.
   1. Login: `az login`
   2. Set Subscription (if multiple): `az account set --subscription "YOUR_SUBSCRIPTION_ID_OR_NAME"`

### 2. Service Principal (Recommended for Automation & CI/CD)
   Create an Azure Service Principal and provide its credentials via environment variables:

# Update configuration

Edit the terraform.tfvars to match your desired configuraiton. There are 4 preset configuraiton starter, medium, large, custom. Custom allows custom manupulation of the deployment to any desired configuraiton provided the machines are defined in hammerspace_template.json which may be modified to accomidate desired configuraitons.

# Deploy vi Tofu / Terraform

```bash
tofu init
tofu plan
tofu apply
```

# Cleanup deployment

```bash
tofu destroy
```




