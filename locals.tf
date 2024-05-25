
locals {
  ## The current region we are provisioning resources in 
  region = coalesce(var.region, data.aws_region.current.name)
}

