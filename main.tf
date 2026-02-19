
# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_cloudformation_stack_set" "stackset" {
  call_as          = var.call_as
  capabilities     = var.capabilities
  description      = var.description
  name             = var.name
  parameters       = var.parameters
  permission_model = var.permission_model
  tags             = var.tags
  template_body    = var.template

  operation_preferences {
    failure_tolerance_count = var.failure_tolerance_count
    max_concurrent_count    = var.max_concurrent_count
  }

  dynamic "auto_deployment" {
    for_each = var.permission_model == "SERVICE_MANAGED" ? [1] : []

    content {
      enabled                          = true
      retain_stacks_on_account_removal = var.retain_stacks_on_account_removal
    }
  }

  lifecycle {
    ignore_changes = [
      administration_role_arn,
    ]
  }
}

## Deploy the stackset to the following organizational units
resource "aws_cloudformation_stack_set_instance" "ou" {
  for_each = local.organizational_deployments

  call_as                   = var.call_as
  stack_set_name            = aws_cloudformation_stack_set.stackset.name
  stack_set_instance_region = each.value.region

  operation_preferences {
    failure_tolerance_count = var.failure_tolerance_count
    max_concurrent_count    = var.max_concurrent_count
    region_concurrency_type = "PARALLEL"
  }

  deployment_targets {
    accounts                = length(local.exclude_accounts) > 0 ? var.exclude_accounts : null
    account_filter_type     = length(local.exclude_accounts) > 0 ? "DIFFERENCE" : null
    organizational_unit_ids = [each.value.organization_unit]
  }

  depends_on = [
    aws_cloudformation_stack_set.stackset,
  ]
}

## Deploy the stackset to the following accounts
resource "aws_cloudformation_stack_set_instance" "accounts" {
  for_each = local.account_deployments

  call_as                   = var.call_as
  stack_set_name            = aws_cloudformation_stack_set.stackset.name
  stack_set_instance_region = each.key

  operation_preferences {
    failure_tolerance_count = var.failure_tolerance_count
    max_concurrent_count    = var.max_concurrent_count
    region_concurrency_type = "PARALLEL"
  }

  deployment_targets {
    accounts = each.value
  }

  depends_on = [
    aws_cloudformation_stack_set.stackset,
  ]
}
