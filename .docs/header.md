![nventive](https://nventive-public-assets.s3.amazonaws.com/nventive_logo_github.svg?v=2)

# terraform-aws-ecs-app

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![Latest Release](https://img.shields.io/github/release/nventive/terraform-aws-ecs-app.svg?style=flat-square)](https://github.com/nventive/terraform-aws-ecs-app/releases/latest)

Terraform module to create an ECS application.

---

## Providers

This modules uses two instances of the AWS provider. One for Route 53 resources and one for the rest. The reason why is
that Route 53 is often in a different account (ie. in the prod account when creating resources for dev).

You must provide both providers, whether you use Route 53 or not. In any case, you can specify the same provider for
both if need be.

## Examples

**IMPORTANT:** We do not pin modules to versions in our examples because of the difficulty of keeping the versions in
the documentation in sync with the latest released versions. We highly recommend that in your code you pin the version
to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way
so that they do not catch you by surprise.

```hcl
module "container_definition_1" {
  source = "nventive/ecs-container-definition/aws"
  # We recommend pinning every module to a specific version
  # version = "x.x.x"

  container_name = "test_1"
  environment = [{
    name  = "NODE_ENV"
    value = "production"
  }]
}

module "container_definition_2" {
  source = "nventive/ecs-container-definition/aws"
  # We recommend pinning every module to a specific version
  # version = "x.x.x"

  container_name = "test_2"
  environment = [{
    name  = "NODE_ENV"
    value = "production"
  }]
}

module "ecs_app" {
  source = "nventive/ecs-app/aws"
  # We recommend pinning every module to a specific version
  # version = "x.x.x"

  providers = {
    aws.route53 = aws.route53
    aws         = aws
  }
  
  alb_arn                    = "arn:aws:elasticloadbalancing:us-east-1:999999999999:loadbalancer/app/xxxxxx/xxxxxxxxxxxxxxxx"
  alb_listeners              = [{ port = 443, protocol = "HTTPS" }, { port = 80, protocol = "HTTP" }]
  alb_security_group_id      = "sg-xxxxxxxxxxxxxxxxx"
  alb_arn_suffix             = "xxxxx/xxxxxxxxxxxxxxxx"
  ecs_cluster_name           = "arn:aws:ecs:us-east-1:999999999999:cluster/xxxxxxxxxxxx"
  ecs_cluster_arn            = dependency.cluster.outputs.cluster_arn
  health_check_matcher       = "200"
  healthcheck_path           = "/"
  service_container_port     = 8080
  service_container_protocol = "HTTP"
  vpc_id                     = "vpc-xxxxxxxxxxxxxxxxx"
  container_definition_json = jsonencode([
    module.container_definition_1.json_map_object,
    module.container_definition_2.json_map_object
  ])
}
```
