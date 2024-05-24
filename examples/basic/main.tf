#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "stackset" {
  source = "../.."

  description = "Used to deploy the default permissions boundary for the pipelines."
  name        = "LZA-IAM-DefaultBoundary"
  region      = "us-west-2"
  tags        = {}
  template    = file("assets/default-boundary.yml")
  parameters  = {}
}
