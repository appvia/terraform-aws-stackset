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
    name        = "LZA-IAM-DefaultBoundary"
    region      = "us-west-2"
    tags        = {}
    template    = ""
    parameters  = {}
  }
}
