
locals {
  ## The current region we are provisioning resources in
  region = coalesce(var.region, data.aws_region.current.region)
  ## Enabled regions to deploy the stackset to
  enabled_regions = var.enabled_regions == null ? [local.region] : sort(var.enabled_regions)
  ## List of exclude accounts for organizational deployments
  exclude_accounts = try(var.exclude_accounts, [])

  ## Deployments to be created
  organization_unit_deployments = flatten([
    for region in local.enabled_regions : [
      for unit in var.organizational_units : {
        key               = "${region}_${unit}"
        region            = region
        organization_unit = unit
      }
    ]
  ])

  ## All the account deployments to be created
  account_deployments = length(var.accounts) > 0 ? {
    for region in local.enabled_regions : region => var.accounts
  } : {}

  ## All the organizational deployment by key
  organizational_deployments = { for x in local.organization_unit_deployments : x.key => x }
}

