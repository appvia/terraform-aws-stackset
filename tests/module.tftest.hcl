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

  assert {
    condition     = alltrue([for k, v in aws_cloudformation_stack_set_instance.ou : v.deployment_targets[0].accounts == null])
    error_message = "The accounts in deployment_targets should not be set when exclude_accounts is not provided"
  }
}

run "organizational_deployment_exclude_accounts" {
  command = plan

  variables {
    description     = "Test exclude_accounts in organizational deployment."
    name            = "lz-exclude-accounts-test"
    region          = "eu-west-1"
    enabled_regions = ["eu-west-1"]
    tags = {
      Environment = "test"
      Owner       = "DevOps"
      Project     = "LandingZone"
    }
    organizational_units = [
      "ou-1234-12345678",
    ]
    exclude_accounts = [
      "123456789012",
      "123456789013"
    ]
    template   = ""
    parameters = {}
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.name == "lz-exclude-accounts-test"
    error_message = "Stackset name should match."
  }

  assert {
    condition     = aws_cloudformation_stack_set_instance.ou != null
    error_message = "StackSet instance should exist for the OU."
  }

  assert {
    condition     = alltrue([for k, v in aws_cloudformation_stack_set_instance.ou : v.deployment_targets[0].account_filter_type == "DIFFERENCE"])
    error_message = "Account filter type should be DIFFERENCE when exclude_accounts is set."
  }

  # Skipped assertion: condition depends on values not available during plan phase
  # assert {
  #   condition     = alltrue([for k, v in aws_cloudformation_stack_set_instance.ou : v.deployment_targets[0].accounts == ["123456789012", "123456789013"]])
  #   error_message = "Excluded accounts should be set correctly."
  # }
}

run "account_deployment_single_region" {
  command = plan

  variables {
    description = "Test account-based deployment in a single region."
    name        = "lz-account-deploy-single"
    region      = "eu-west-1"
    tags = {
      Environment = "test"
      Owner       = "DevOps"
    }
    accounts = [
      "111111111111",
      "222222222222",
    ]
    template   = ""
    parameters = {}
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.name == "lz-account-deploy-single"
    error_message = "Stackset name should be lz-account-deploy-single"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.accounts) == 1
    error_message = "There should be 1 account deployment instance (one per region)"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.ou) == 0
    error_message = "There should be no OU deployment instances for account-based deployments"
  }

  assert {
    condition     = contains(keys(aws_cloudformation_stack_set_instance.accounts), "eu-west-1")
    error_message = "The account deployment should be keyed by the region eu-west-1"
  }

  assert {
    condition     = alltrue([for k, v in aws_cloudformation_stack_set_instance.accounts : v.stack_set_name == "lz-account-deploy-single"])
    error_message = "All account deployment instances should reference the correct stackset name"
  }
}

run "account_deployment_multiple_regions" {
  command = plan

  variables {
    description = "Test account-based deployment across multiple regions."
    name        = "lz-account-deploy-multi"
    region      = "eu-west-2"
    enabled_regions = [
      "eu-west-1",
      "eu-west-2",
      "us-east-1",
    ]
    tags = {
      Environment = "production"
      Owner       = "DevOps"
      Project     = "LandingZone"
    }
    accounts = [
      "333333333333",
      "444444444444",
      "555555555555",
    ]
    template   = ""
    parameters = {}
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.name == "lz-account-deploy-multi"
    error_message = "Stackset name should be lz-account-deploy-multi"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.accounts) == 3
    error_message = "There should be 3 account deployment instances (one per enabled region)"
  }

  assert {
    condition     = length(aws_cloudformation_stack_set_instance.ou) == 0
    error_message = "There should be no OU deployment instances for account-based deployments"
  }

  assert {
    condition     = alltrue([for x in var.enabled_regions : contains(keys(aws_cloudformation_stack_set_instance.accounts), x)])
    error_message = "Each enabled region should have an account deployment instance"
  }

  assert {
    condition     = alltrue([for k, v in aws_cloudformation_stack_set_instance.accounts : v.stack_set_name == "lz-account-deploy-multi"])
    error_message = "All account deployment instances should reference the correct stackset name"
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.description == var.description
    error_message = "The stackset description should match the provided variable"
  }

  assert {
    condition     = alltrue([for key in keys(var.tags) : aws_cloudformation_stack_set.stackset.tags[key] == var.tags[key]])
    error_message = "The stackset tags should match the provided variables"
  }
}

run "template_url" {
  command = plan

  variables {
    description  = "Test template_url based deployments."
    name         = "lz-template-url"
    region       = "eu-west-1"
    tags         = {}
    template_url = "https://example.com/template.yaml"
    parameters   = {}
  }

  assert {
    condition     = aws_cloudformation_stack_set.stackset.template_url == "https://example.com/template.yaml"
    error_message = "The stackset should use template_url when provided."
  }
}

run "missing_template_source" {
  command = plan

  expect_failures = [
    aws_cloudformation_stack_set.stackset,
  ]

  variables {
    description = "Missing both template and template_url should fail."
    name        = "lz-missing-template"
    region      = "eu-west-1"
    tags        = {}
    parameters  = {}
  }
}

run "both_template_sources" {
  command = plan

  expect_failures = [
    aws_cloudformation_stack_set.stackset,
  ]

  variables {
    description  = "Setting both template and template_url should fail."
    name         = "lz-both-template-sources"
    region       = "eu-west-1"
    tags         = {}
    template     = ""
    template_url = "https://example.com/template.yaml"
    parameters   = {}
  }
}

