<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-stackset/blob/main/docs/banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/stackset/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-stackset/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-stackset.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-stackset/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-stackset.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-stackset/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Stackset

## Overview

This module provides a simple way to deploy a CloudFormation stack to multiple accounts and regions using AWS StackSets.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the cloudformation stack | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the cloudformation stack | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the cloudformation stack | `map(string)` | n/a | yes |
| <a name="input_template"></a> [template](#input\_template) | The body of the cloudformation template to deploy | `string` | n/a | yes |
| <a name="input_accounts"></a> [accounts](#input\_accounts) | A list of account IDs used as a target | `list(string)` | `null` | no |
| <a name="input_call_as"></a> [call\_as](#input\_call\_as) | Specifies whether you are acting as an account administrator in the organization's management account or as a delegated administrator in a member account | `string` | `"SELF"` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | The capabilities required to deploy the cloudformation template | `list(string)` | <pre>[<br/>  "CAPABILITY_NAMED_IAM",<br/>  "CAPABILITY_AUTO_EXPAND",<br/>  "CAPABILITY_IAM"<br/>]</pre> | no |
| <a name="input_enable_exclude"></a> [enable\_exclude](#input\_enable\_exclude) | Indicates the accounts list will be used as an exclusion list | `bool` | `false` | no |
| <a name="input_enabled_regions"></a> [enabled\_regions](#input\_enabled\_regions) | The regions to deploy the cloudformation stack to (if empty, deploys to current region) | `list(string)` | `null` | no |
| <a name="input_failure_tolerance_count"></a> [failure\_tolerance\_count](#input\_failure\_tolerance\_count) | The number of failures that are tolerated before the stack operation is stopped | `number` | `0` | no |
| <a name="input_max_concurrent_count"></a> [max\_concurrent\_count](#input\_max\_concurrent\_count) | The maximum number of concurrent deployments | `number` | `10` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organizational units to deploy the stackset to | `list(string)` | `[]` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | The parameters to pass to the cloudformation template | `map(string)` | `{}` | no |
| <a name="input_permission_model"></a> [permission\_model](#input\_permission\_model) | Describes how the IAM roles required for your StackSet are created | `string` | `"SERVICE_MANAGED"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the cloudformation template | `string` | `null` | no |
| <a name="input_retain_stacks_on_account_removal"></a> [retain\_stacks\_on\_account\_removal](#input\_retain\_stacks\_on\_account\_removal) | Whether to retain stacks on account removal | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
