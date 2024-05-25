![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS StackSet Module

## Description

The purpose of this module is to deploy a cloudformation stack to an AWS account. The module will also deploy a stackset to multiple accounts if required.

## Usage

Add example usage here

```hcl
module "stackset" {
  source = "../.."

  description               = "Used to deploy the default permissions boundary for the pipelines."
  enable_management_account = true
  name                      = "LZA-IAM-DefaultBoundary"
  region                    = "us-west-2"
  tags                      = {}
  template                  = file("assets/default-boundary.yml")
  parameters                = {}
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.stackset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.ou](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the cloudformation stack | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the cloudformation stack | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the cloudformation stack | `map(string)` | n/a | yes |
| <a name="input_template"></a> [template](#input\_template) | The body of the cloudformation template to deploy | `string` | n/a | yes |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | The capabilities required to deploy the cloudformation template | `list(string)` | <pre>[<br>  "CAPABILITY_NAMED_IAM",<br>  "CAPABILITY_AUTO_EXPAND",<br>  "CAPABILITY_IAM"<br>]</pre> | no |
| <a name="input_failure_tolerance_count"></a> [failure\_tolerance\_count](#input\_failure\_tolerance\_count) | The number of failures that are tolerated before the stack operation is stopped | `number` | `0` | no |
| <a name="input_max_concurrent_count"></a> [max\_concurrent\_count](#input\_max\_concurrent\_count) | The maximum number of concurrent deployments | `number` | `10` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organizational units to deploy the stackset to | `list(string)` | `[]` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | The parameters to pass to the cloudformation template | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the cloudformation template | `string` | `null` | no |
| <a name="input_retain_stacks_on_account_removal"></a> [retain\_stacks\_on\_account\_removal](#input\_retain\_stacks\_on\_account\_removal) | Whether to retain stacks on account removal | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
