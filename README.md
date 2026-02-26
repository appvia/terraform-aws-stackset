<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-stackset/blob/main/docs/banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/stackset/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-stackset/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-stackset.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-stackset/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-stackset.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-stackset/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Stackset

## Introduction

Deploying consistent infrastructure and security controls across multiple AWS accounts and regions is a critical challenge for organizations managing large-scale AWS environments. This module solves the operational complexity of distributing CloudFormation templates organization-wide by providing a Terraform-native interface to AWS CloudFormation StackSets.

The primary use case is enabling centralized infrastructure provisioning in AWS Organizations environments—whether rolling out IAM permissions boundaries, deploying security baselines, distributing networking configurations, or ensuring compliance controls are consistently applied across development, staging, and production accounts.

### Architecture Overview

The module orchestrates three key AWS StackSet capabilities:

- **StackSet Definition**: Creates a CloudFormation StackSet with your inline template or template URL, parameters, and operational preferences
- **Organizational Unit Deployment**: Automatically deploys stack instances to all accounts within specified OUs, with optional account exclusions
- **Account-Based Deployment**: Explicitly targets specific account IDs across one or more regions

When using the `SERVICE_MANAGED` permission model (recommended for AWS Organizations), the module enables auto-deployment, ensuring new accounts automatically receive the stack as they join targeted OUs. Stack instances are deployed with configurable concurrency controls and failure tolerance thresholds to balance speed and safety during multi-account rollouts.

### Cloud Context

This module is designed for AWS Organizations environments and supports both:
- **SERVICE_MANAGED mode**: Leverages AWS Organizations integration for automatic stack distribution to OUs without manual IAM role management (recommended)
- **SELF_MANAGED mode**: Requires pre-configured IAM roles (`AWSCloudFormationStackSetAdministrationRole` and `AWSCloudFormationStackSetExecutionRole`) for cross-account deployments

The module is commonly used in AWS Landing Zone architectures, AWS Control Tower environments, and multi-account governance strategies where centralized infrastructure distribution is required.

## Features

### Security by Default

- **Service-Managed IAM Roles**: Defaults to `SERVICE_MANAGED` permission model, eliminating the need to manually provision cross-account IAM roles and reducing misconfiguration risk
- **CloudFormation Capabilities**: Pre-configured with `CAPABILITY_IAM`, `CAPABILITY_NAMED_IAM`, and `CAPABILITY_AUTO_EXPAND` to support IAM resource provisioning and nested stacks
- **Stack Retention Control**: Configurable retention behavior when accounts are removed from organizational units, preventing accidental resource deletion (default: retain)

### Flexibility

- **Multi-Region Deployment**: Deploy to a single region or broadcast across multiple regions simultaneously with parallel execution
- **Hybrid Targeting**: Supports both OU-based deployment (for organizational governance) and explicit account-based targeting (for exceptions or testing)
- **Account Exclusions**: Fine-grained control to exclude specific accounts from OU-level deployments without modifying organizational structure
- **Template Parameterization**: Pass CloudFormation parameters dynamically, enabling per-environment customization of the same template
- **Template Source Flexibility**: Provide templates inline (`template`) or via URL (`template_url`) for larger CloudFormation documents

### Operational Excellence

- **Concurrency Management**: Configurable `max_concurrent_count` (default: 10 concurrent deployments) to control rollout velocity and API throttling
- **Failure Tolerance**: Define acceptable failure thresholds before halting organization-wide operations, preventing cascading failures
- **Auto-Deployment**: Automatically provisions stacks to newly created accounts in targeted OUs without manual intervention
- **Terraform State Integration**: Full Terraform lifecycle management with proper dependency handling and minimal drift risk

### Compliance

- **Centralized Policy Enforcement**: Enable organization-wide compliance by distributing security controls, tagging policies, or permissions boundaries via CloudFormation
- **Audit-Ready Deployment**: CloudFormation stacksets provide built-in change tracking and drift detection capabilities
- **Consistent Configuration**: Ensures identical resource configurations across accounts, reducing compliance audit surface area

## Usage Examples

### The "Golden Path" (Simple)

This is the most common deployment pattern—distributing a CloudFormation template to all accounts in specific organizational units across multiple regions:

```hcl
module "security_baseline" {
  source = "appvia/stackset/aws"

  name        = "security-baseline"
  description = "Deploys mandatory security controls across production accounts"
  template    = file("${path.module}/templates/security-baseline.yml")
  
  # Deploy to production and infrastructure OUs in two regions
  organizational_units = [
    "ou-xxxx-production",
    "ou-xxxx-infrastructure"
  ]
  
  enabled_regions = ["us-east-1", "eu-west-1"]
  
  # CloudFormation parameters
  parameters = {
    SecurityContactEmail = "security@example.com"
    EnableGuardDuty     = "true"
  }
  
  # Standard concurrency settings
  max_concurrent_count    = 10
  failure_tolerance_count = 2
  
  tags = {
    ManagedBy   = "terraform"
    Purpose     = "security-compliance"
    Environment = "production"
  }
}
```

This configuration will:
- Deploy the CloudFormation template to all accounts in the specified OUs
- Automatically provision to new accounts as they join these OUs
- Roll out to both us-east-1 and eu-west-1 regions in parallel
- Tolerate up to 2 failures before halting the operation

### Using `template_url` for Large Templates

For templates that exceed CloudFormation inline body limits, use `template_url` instead of `template`:

```hcl
module "security_baseline_large_template" {
  source = "appvia/stackset/aws"

  name         = "security-baseline-large-template"
  description  = "Deploy security controls using a template stored in S3"
  template_url = "https://s3.amazonaws.com/example-bucket/security-baseline.yml"

  organizational_units = ["ou-xxxx-production"]
  enabled_regions      = ["us-east-1"]
  parameters           = {}
  tags                 = {}
}
```

Exactly one of `template` or `template_url` must be set.

### The "Power User" (Advanced)

Advanced scenarios requiring account exclusions, single-region deployment, and integration with data sources:

```hcl
# Fetch current region dynamically
data "aws_region" "current" {}

# Read organizational units from a data source
data "aws_organizations_organizational_units" "workloads" {
  parent_id = "r-xxxx"
}

module "permissions_boundary" {
  source = "appvia/stackset/aws"

  name        = "pipeline-permissions-boundary"
  description = "IAM permissions boundary for CI/CD pipelines"
  template    = templatefile("${path.module}/templates/boundary.yml.tpl", {
    allowed_services = ["s3", "dynamodb", "lambda", "cloudwatch"]
    denied_actions   = ["iam:*", "organizations:*"]
  })
  
  # Deploy to all workload OUs except sandbox accounts
  organizational_units = [
    for ou in data.aws_organizations_organizational_units.workloads.children : ou.id
  ]
  
  # Explicitly exclude test accounts that need unrestricted permissions
  exclude_accounts = [
    "123456789012",  # test-account-1
    "234567890123",  # test-account-2
  ]
  
  # Deploy only to current region (avoid duplicating regional resources)
  region = data.aws_region.current.name
  
  # Higher concurrency for faster rollout across many accounts
  max_concurrent_count    = 25
  failure_tolerance_count = 5
  
  # CloudFormation parameters with conditional logic
  parameters = {
    BoundaryName        = "PipelineBoundary"
    MaxSessionDuration  = "3600"
    Environment         = terraform.workspace
  }
  
  tags = merge(
    var.common_tags,
    {
      StackSetType = "permissions-boundary"
      Compliance   = "required"
    }
  )
}
```

This advanced example demonstrates:
- Dynamic OU discovery using data sources
- Templating CloudFormation with Terraform's `templatefile` function
- Excluding specific accounts from OU-wide deployments
- Single-region deployment to avoid regional resource conflicts
- Increased concurrency for large-scale rollouts
- Tag merging for inheritance patterns

### The "Migration" (Edge Case)

When migrating existing manually-created StackSets to Terraform management or deploying to specific accounts instead of OUs:

```hcl
# Import existing StackSet:
# terraform import module.legacy_stackset.aws_cloudformation_stack_set.stackset LegacyStackSetName

module "legacy_stackset" {
  source = "appvia/stackset/aws"

  name        = "legacy-stackset"  # Must match existing StackSet name for import
  description = "Migrated from manual CloudFormation StackSet"
  template    = file("${path.module}/templates/legacy-template.yml")
  
  # Use account-based deployment instead of OU targeting
  # Useful for controlled migration or when OU structure is unavailable
  accounts = [
    "111111111111",
    "222222222222",
    "333333333333",
  ]
  
  enabled_regions = ["us-east-1"]
  
  # SELF_MANAGED mode if using existing IAM roles
  permission_model = "SELF_MANAGED"
  
  # Conservative settings for migration safety
  max_concurrent_count    = 3
  failure_tolerance_count = 0  # Stop immediately on any failure
  
  # Preserve stacks if accounts are later removed from the list
  retain_stacks_on_account_removal = true
  
  parameters = {}
  
  tags = {
    ManagedBy     = "terraform"
    MigratedFrom  = "manual-cloudformation"
    MigrationDate = "2026-02-12"
  }
  
  lifecycle {
    # Prevent accidental changes to critical stack name
    prevent_destroy = true
  }
}

# Account-based deployment for selective rollout to specific environments
module "testing_stackset" {
  source = "appvia/stackset/aws"

  name        = "feature-test-stack"
  description = "Testing new feature in specific accounts before org-wide rollout"
  template    = file("${path.module}/templates/new-feature.yml")
  
  # Explicitly target test accounts only
  accounts = [
    "444444444444",  # dev-test-account
    "555555555555",  # staging-test-account
  ]
  
  enabled_regions = ["us-west-2", "eu-central-1"]
  
  parameters = {
    FeatureFlag = "enabled"
    LogLevel    = "debug"
  }
  
  tags = {
    Environment = "test"
    Purpose     = "feature-validation"
  }
}
```

This migration example shows:
- Importing existing StackSets into Terraform management
- Using `SELF_MANAGED` mode for environments without AWS Organizations integration
- Account-based targeting for gradual rollouts or testing
- Conservative concurrency and failure settings for risk mitigation
- Lifecycle rules to prevent accidental destruction

## Operational Context

### Known Limitations

- **Deployment Time**: StackSet operations can take 15-30 minutes for large-scale OU deployments (50+ accounts). CloudFormation executes stack creation sequentially within each account, regardless of concurrency settings
- **OU Changes Not Tracked**: If accounts are moved between OUs outside of Terraform, the module does not automatically detect and update stack instances. You must manually update the `organizational_units` variable
- **Regional Dependencies**: CloudFormation StackSets deploy identically to all specified regions. If your template requires region-specific parameters or resources, consider using separate StackSets per region
- **Service-Managed Requirement**: The `SERVICE_MANAGED` permission model requires AWS Control Tower or Organizations to be enabled with trusted access. New AWS accounts may take several hours to fully support StackSet deployments
- **Template Size Limit**: CloudFormation templates are limited to 51,200 bytes when passed inline (`template`). Use `template_url` for larger templates hosted in S3 or other supported locations
- **Stack Instance Limits**: AWS enforces a soft limit of 2,000 stack instances per StackSet. For organizations exceeding this, consider partitioning deployments across multiple StackSets

### Breaking Changes

**v2.0.0 (Planned)**:
- Minimum AWS provider version will increase to 6.0.0

**v1.0.0**:
- Initial stable release
- Requires AWS provider >= 5.0.0
- Defaults to `SERVICE_MANAGED` permission model

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the cloudformation stack | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the cloudformation stack | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the cloudformation stack | `map(string)` | n/a | yes |
| <a name="input_accounts"></a> [accounts](#input\_accounts) | When using an account deployments, the following accounts will be included | `list(string)` | `[]` | no |
| <a name="input_call_as"></a> [call\_as](#input\_call\_as) | Specifies whether you are acting as an account administrator in the organization's management account or as a delegated administrator in a member account | `string` | `"SELF"` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | The capabilities required to deploy the cloudformation template | `list(string)` | <pre>[<br/>  "CAPABILITY_NAMED_IAM",<br/>  "CAPABILITY_AUTO_EXPAND",<br/>  "CAPABILITY_IAM"<br/>]</pre> | no |
| <a name="input_enabled_regions"></a> [enabled\_regions](#input\_enabled\_regions) | The regions to deploy the cloudformation stack to (if empty, deploys to current region) | `list(string)` | `null` | no |
| <a name="input_exclude_accounts"></a> [exclude\_accounts](#input\_exclude\_accounts) | When using an organizational deployments, the following accounts will be excluded | `list(string)` | `[]` | no |
| <a name="input_failure_tolerance_count"></a> [failure\_tolerance\_count](#input\_failure\_tolerance\_count) | The number of failures that are tolerated before the stack operation is stopped | `number` | `0` | no |
| <a name="input_max_concurrent_count"></a> [max\_concurrent\_count](#input\_max\_concurrent\_count) | The maximum number of concurrent deployments | `number` | `10` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organizational units to deploy the stackset to | `list(string)` | `[]` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | The parameters to pass to the cloudformation template | `map(string)` | `{}` | no |
| <a name="input_permission_model"></a> [permission\_model](#input\_permission\_model) | Describes how the IAM roles required for your StackSet are created | `string` | `"SERVICE_MANAGED"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the cloudformation template | `string` | `null` | no |
| <a name="input_retain_stacks_on_account_removal"></a> [retain\_stacks\_on\_account\_removal](#input\_retain\_stacks\_on\_account\_removal) | Whether to retain stacks on account removal | `bool` | `true` | no |
| <a name="input_template"></a> [template](#input\_template) | The body of the cloudformation template to deploy | `string` | `null` | no |
| <a name="input_template_url"></a> [template\_url](#input\_template\_url) | The URL of the cloudformation template to deploy | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
