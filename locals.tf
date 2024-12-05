
locals {
  ## The current region we are provisioning resources in
  region = coalesce(var.region, data.aws_region.current.name)
  ## Enabled regions to deploy the stackset to
  enabled_regions = var.enabled_regions == null ? [local.region] : sort(var.enabled_regions)

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

  deployments = { for x in local.organization_unit_deployments : x.key => x }
}

