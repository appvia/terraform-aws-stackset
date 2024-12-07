

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_cloudformation_stack_set" "stackset" {
  name             = var.name
  capabilities     = var.capabilities
  description      = var.description
  parameters       = var.parameters
  permission_model = "SERVICE_MANAGED"
  template_body    = var.template
  tags             = var.tags

  operation_preferences {
    failure_tolerance_count = var.failure_tolerance_count
    max_concurrent_count    = var.max_concurrent_count
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = var.retain_stacks_on_account_removal
  }

  lifecycle {
    ignore_changes = [
      administration_role_arn,
    ]
  }
}

## Deploy the stackset to the following organizational units
resource "aws_cloudformation_stack_set_instance" "ou" {
  for_each = local.deployments

  region         = each.value.region
  stack_set_name = aws_cloudformation_stack_set.stackset.name

  deployment_targets {
    accounts                = var.exclude_accounts
    account_filter_type     = var.exclude_accounts != null ? "DIFFERENCE" : null
    organizational_unit_ids = [each.value.organization_unit]
  }
}
