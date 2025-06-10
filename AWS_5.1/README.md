# Hammerspace Deployment with OpenTofu using CloudFormation

This OpenTofu configuration deploys a Hammerspace environment by leveraging an existing AWS CloudFormation template hosted on S3.

*(This configuration is also fully compatible with Terraform. Simply replace `tofu` with `terraform` in the commands below if you are using Terraform.)*

## Prerequisites

1.  **OpenTofu Installed**: Ensure you have OpenTofu installed on your system. You can find installation instructions on the [OpenTofu official website](https://opentofu.org/docs/intro/install/).
2.  **AWS Account**: You need an active AWS account.
3.  **AWS CLI Installed**: The AWS Command Line Interface (CLI) is required for configuring AWS credentials. If you don't have it, install it from the [AWS CLI official page](https://aws.amazon.com/cli/).
4.  **AWS Access Keys**: You must have an AWS Access Key ID and Secret Access Key for an IAM user.
    *   If you don't have keys, you can generate them from the AWS Management Console under "My Security Credentials" or via IAM for an IAM user.
    *   **Important**: It is highly recommended to use IAM user credentials with the least privilege necessary, rather than root account credentials.

## AWS Credentials Setup (Default Profile)

This OpenTofu configuration will use the AWS provider, which typically relies on credentials configured for the AWS CLI. Follow these steps to set up your AWS access keys using a default profile:

1.  **Open your terminal or command prompt.**

2.  **Run the AWS configure command:**
    ```bash
    aws configure
    ```

3.  **Enter your credentials and default settings when prompted:**
    *   **AWS Access Key ID \[None]:** Enter your AWS Access Key ID and press Enter.
        ```
        AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
        ```
    *   **AWS Secret Access Key \[None]:** Enter your AWS Secret Access Key and press Enter.
        ```
        AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
        ```
    *   **Default region name \[None]:** Enter your preferred default AWS region (e.g., `us-west-2`, `eu-central-1`). This should match the region you intend to deploy the Hammerspace stack in.
        ```
        Default region name [None]: us-west-2
        ```
    *   **Default output format \[None]:** You can choose `json`, `text`, or `table`. `json` is a common default.
        ```
        Default output format [None]: json
        ```

    This command creates or updates two files in your home directory:
    *   `~/.aws/credentials` (on Linux/macOS) or `%USERPROFILE%\.aws\credentials` (on Windows) stores your access keys.
    *   `~/.aws/config` (on Linux/macOS) or `%USERPROFILE%\.aws\config` (on Windows) stores your default region and output format.

4.  **Verify Configuration (Optional but Recommended):**
    You can verify that your AWS CLI is configured correctly by running a simple command, for example, to list your S3 buckets (if you have any):
    ```bash
    aws s3 ls
    ```
    Or, to get your caller identity:
    ```bash
    aws sts get-caller-identity
    ```
    If these commands execute successfully and return the expected information, your default profile is configured.

**Security Note:**
*   Your AWS access keys grant significant access to your AWS account. Keep your Secret Access Key confidential.
*   Do not commit your `~/.aws/credentials` file to any version control system.
*   Consider using IAM roles for EC2 instances or other AWS services if running OpenTofu from within AWS, to avoid storing long-lived credentials.

## IAM Permissions for Deployment

To successfully deploy the Hammerspace CloudFormation stack and manage associated S3 buckets, the IAM user whose credentials you configured above needs specific permissions.

A recommended IAM policy is provided in the file:
**`Hammerspace_CloudFormation_Deployer_IAM_Policy.json`**

This policy grants the minimum necessary permissions for:
*   CloudFormation stack operations (create, delete, update, describe).
*   Managing EC2 resources (instances, security groups, volumes).
*   Managing IAM resources created by the template (roles, instance profiles, groups).
*   Passing IAM roles to EC2 instances.
*   Fetching the CloudFormation template from S3.
*   Creating, deleting, and managing S3 buckets as required by the Hammerspace product.

### Applying the IAM Policy to a User

You can apply this policy to an IAM user in the AWS Management Console:

1.  **Navigate to the IAM Console:**
    *   Log in to your AWS Management Console.
    *   Search for and navigate to the "IAM" service.

2.  **Create or Select the User:**
    *   If you are applying the policy to an existing user (the one whose credentials you configured with `aws configure`), select "Users" from the left navigation pane and find the user in the list. Click on the username.
    *   If you need to create a new user for this purpose, click "Add users", follow the prompts, and ensure you generate access keys for this new user to configure with the AWS CLI.

3.  **Create and Attach the Policy:**
    *   In the user's summary page, go to the "Permissions" tab.
    *   Under "Permissions policies", click "Add permissions" and select "Attach policies directly".
    *   Click the "Create policy" button. This will open a new tab/window.
    *   In the policy editor, select the "JSON" tab.
    *   Open the `Hammerspace_CloudFormation_Deployer_IAM_Policy.json` file from this repository, copy its entire content.
    *   Paste the JSON content into the policy editor in the AWS console, replacing any existing content.
    *   Click "Next: Tags" (you can add tags if desired, or skip).
    *   Click "Next: Review".
    *   Give the policy a **Name** (e.g., `HammerspaceCloudFormationDeployerPolicy`) and an optional **Description**.
    *   Review the permissions and click "Create policy".
    *   Close the policy creation tab/window and return to the user's permissions tab where you clicked "Create policy".
    *   You may need to refresh the list of policies. Search for the policy you just created by its name (e.g., `HammerspaceCloudFormationDeployerPolicy`).
    *   Select the checkbox next to your newly created policy.
    *   Click "Next" and then "Add permissions".

The IAM user should now have the necessary permissions to deploy the Hammerspace CloudFormation stack using OpenTofu.

**IAM Best Practices:**
*   **Least Privilege:** Always grant only the permissions necessary. Regularly review this policy to ensure it aligns with the actual requirements of the CloudFormation template.
*   **Scope Down `iam:PassRole`:** The `iam:PassRole` permission in the provided policy is broad (`"Resource": ["arn:aws:iam::*:role/*"]`). For enhanced security, restrict this to the specific role ARNs that will be passed to EC2 instances by the CloudFormation template.
*   **Regular Audits:** Periodically review IAM user permissions and policies.

## OpenTofu Configuration Files

This project includes the following OpenTofu configuration files:

*   `main.tf`: Defines the AWS provider and the `aws_cloudformation_stack` resource that deploys the Hammerspace template. It also includes outputs from the CloudFormation stack.
*   `variables.tf`: Declares all input variables used by the OpenTofu configuration, which are passed as parameters to the CloudFormation template.
*   `terraform.tfvars`: Sets the values for the variables defined in `variables.tf`. **You will need to customize this file with your specific VPC ID, Subnet ID, AZ, and other required parameters.** (The `.tfvars` extension is standard and used by both OpenTofu and Terraform).

## Usage

1.  **Clone the repository (if applicable) or ensure you have all `.tf`, `.tfvars`, and `.json` policy files.**

2.  **Configure AWS Credentials & IAM Permissions**: Ensure your AWS default profile is configured and the IAM user has the `HammerspaceCloudFormationDeployerPolicy` (or equivalent) attached, as described above.

3.  **Customize `terraform.tfvars`**:
    There are 4 deployment-sizes availble [starter, medium, large, or custom]
    Open `terraform.tfvars` and update the placeholder values (e.g., `vpc_id`, `subnet_1_id`, `az1`, `sec_ip_cidr`) with your specific environment details. Review all other variables to ensure they match your desired Hammerspace configuration.

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