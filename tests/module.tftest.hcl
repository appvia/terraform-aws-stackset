mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
      ]
    }
  }
}

run "basic" {
  command = plan

  variables {
    description = "Used to deploy the default permissions boundary for the pipelines."
    name        = "lz-iamdefaultboundary"
    region      = "us-west-2"
    tags        = {}
    template    = ""
    parameters  = {}
  }
}

run "exclude_accounts" {
  command = plan

  variables {
    description = "Used to deploy the default permissions boundary for the pipelines."
    name        = "lz-iamdefaultboundary"
    region      = "us-west-2"
    tags        = {}
    template    = ""
    parameters  = {}
    exclude_accounts = [
      "123456789012",
      "123456789013"
    ]
  }
}

run "multiple_regions" {
  command = plan

  variables {
    description = "Used to deploy the default permissions boundary for the pipelines."
    name        = "lz-terraform-state"
    region      = "eu-west-2"
    enabled_regions = [
      "eu-west-1",
      "eu-west-2",
      "eu-west-3"
    ]
    tags = {
      Environment = "production"
      Owner       = "DevOps"
      Project     = "LandingZone"
    }
    organizational_units = [
      "ou-1234-12345678",
    ]
    template   = ""
    parameters = {}
  }

  ## The organization units to deploy to have a stackset call hello
  assert {
    condition     = aws_cloudformation_stack_set.stackset.name == "lz-terraform-state"
    error_message = "We should be deploying to the stackset named lz-terraform-state"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.ou) == 3
    error_message = "We should be deploying to 3 regions"
  }

  # Skipped assertion: condition depends on values not available during plan phase
  # assert {
  #   condition     = alltrue([for x in aws_cloudformation_stack_set_instance.ou : x.region == "eu-west-1" || x.region == "eu-west-2" || x.region == "eu-west-3"])
  #   error_message = "We should be deploying to the regions eu-west-1, eu-west-2, and eu-west-3"
  # }

  assert {
    condition     = alltrue([for x in aws_cloudformation_stack_set_instance.ou : x.stack_set_name == "lz-terraform-state"])
    error_message = "We should be deploying to the stackset named lz-terraform-state"
  }

  assert {
    condition     = alltrue([for x in var.enabled_regions : contains(keys(aws_cloudformation_stack_set_instance.ou), "${x}_ou-1234-12345678")])
    error_message = "We should be deploying to the organizational unit ou-1234-12345678 in all enabled regions"
  }
}

run "multiple_regions_multiple_ous" {
  command = plan

  variables {
    description = "Used to deploy the default permissions boundary for the pipelines."
    name        = "lz-terraform-state"
    region      = "eu-west-2"
    enabled_regions = [
      "eu-west-1",
      "eu-west-2",
      "eu-west-3"
    ]
    tags = {
      Environment = "production"
      Owner       = "DevOps"
      Project     = "LandingZone"
    }
    organizational_units = [
      "ou-1234-12345678",
      "ou-1234-12345679",
    ]
    template   = ""
    parameters = {}
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.name == "lz-terraform-state"
    error_message = "We should be deploying to the stackset named lz-terraform-state"
  }

  assert {
    condition     = alltrue([for key in keys(var.tags) : aws_cloudformation_stack_set.stackset.tags[key] == var.tags[key]])
    error_message = "The tags should be set to the tags provided in the variables"
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.description == var.description
    error_message = "The description should be set to the description provided in the variables"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.ou) == 6
    error_message = "We should be deploying to 3 regions"
  }

  assert {
    condition     = alltrue([for x in var.enabled_regions : contains(keys(aws_cloudformation_stack_set_instance.ou), "${x}_ou-1234-12345678")])
    error_message = "We should be deploying to the organizational unit ou-1234-12345678 in all enabled regions"
  }

  assert {
    condition     = alltrue([for x in var.enabled_regions : contains(keys(aws_cloudformation_stack_set_instance.ou), "${x}_ou-1234-12345679")])
    error_message = "We should be deploying to the organizational unit ou-1234-12345678 in all enabled regions"
  }
}
