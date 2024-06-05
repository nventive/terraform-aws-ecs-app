<!-- BEGIN_TF_DOCS -->
![nventive](https://nventive-public-assets.s3.amazonaws.com/nventive_logo_github.svg?v=2)

# terraform-aws-ecs-app

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![Latest Release](https://img.shields.io/github/release/nventive/terraform-aws-ecs-app.svg?style=flat-square)](https://github.com/nventive/terraform-aws-ecs-app/releases/latest)

Terraform module to provision an ECS application.

---

## Providers

This modules uses two instances of the AWS provider. One for Route 53 resources and one for the rest. The reason why is
that Route 53 is often in a different account (ie. in the prod account when creating resources for dev).

You must provide both providers, whether you use Route 53 or not. In any case, you can specify the same provider for
both if need be.

## Examples

> [!IMPORTANT]
>
> We do not pin modules to versions in our examples because of the difficulty of keeping the versions in
> the documentation in sync with the latest released versions. We highly recommend that in your code you pin the version
> to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way
> so that they do not catch you by surprise.

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_certificate"></a> [acm\_certificate](#module\_acm\_certificate) | nventive/acm-certificate/aws | 1.0.1 |
| <a name="module_alb_alarms"></a> [alb\_alarms](#module\_alb\_alarms) | cloudposse/alb-target-group-cloudwatch-sns-alarms/aws | 0.17.0 |
| <a name="module_alb_ingress"></a> [alb\_ingress](#module\_alb\_ingress) | cloudposse/alb-ingress/aws | 0.25.1 |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | cloudposse/ecs-cloudwatch-autoscaling/aws | 0.7.3 |
| <a name="module_ecs_alarms"></a> [ecs\_alarms](#module\_ecs\_alarms) | cloudposse/ecs-cloudwatch-sns-alarms/aws | 0.12.3 |
| <a name="module_ecs_service_sg"></a> [ecs\_service\_sg](#module\_ecs\_service\_sg) | cloudposse/security-group/aws | 2.2.0 |
| <a name="module_service"></a> [service](#module\_service) | cloudposse/ecs-alb-service-task/aws | 0.58.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lb_listener.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_security_group_rule.opened_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_alarms_3xx_threshold"></a> [alb\_alarms\_3xx\_threshold](#input\_alb\_alarms\_3xx\_threshold) | The maximum count of 3XX requests over a period. A negative value will disable the alert. | `number` | `25` | no |
| <a name="input_alb_alarms_4xx_threshold"></a> [alb\_alarms\_4xx\_threshold](#input\_alb\_alarms\_4xx\_threshold) | The maximum count of 4XX requests over a period. A negative value will disable the alert. | `number` | `25` | no |
| <a name="input_alb_alarms_5xx_threshold"></a> [alb\_alarms\_5xx\_threshold](#input\_alb\_alarms\_5xx\_threshold) | The maximum count of 5XX requests over a period. A negative value will disable the alert. | `number` | `25` | no |
| <a name="input_alb_alarms_alarm_actions"></a> [alb\_alarms\_alarm\_actions](#input\_alb\_alarms\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an ALARM state from any other state.  If set, this list takes precedence over notify\_arns. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_alb_alarms_enabled"></a> [alb\_alarms\_enabled](#input\_alb\_alarms\_enabled) | Whether to enable SNS alarms for the ALB target group. | `bool` | `false` | no |
| <a name="input_alb_alarms_evaluation_periods"></a> [alb\_alarms\_evaluation\_periods](#input\_alb\_alarms\_evaluation\_periods) | Number of periods to evaluate for the alarm. | `number` | `1` | no |
| <a name="input_alb_alarms_insufficient_data_actions"></a> [alb\_alarms\_insufficient\_data\_actions](#input\_alb\_alarms\_insufficient\_data\_actions) | A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. If set, this list takes precedence over notify\_arns. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_alb_alarms_ok_actions"></a> [alb\_alarms\_ok\_actions](#input\_alb\_alarms\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an OK state from any other state. If set, this list takes precedence over notify\_arns. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_alb_alarms_period"></a> [alb\_alarms\_period](#input\_alb\_alarms\_period) | Duration in seconds to evaluate for the alarm. | `number` | `300` | no |
| <a name="input_alb_alarms_response_time_threshold"></a> [alb\_alarms\_response\_time\_threshold](#input\_alb\_alarms\_response\_time\_threshold) | The maximum average target response time (in seconds) over a period. A negative value will disable the alert. | `number` | `0.5` | no |
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | ARN of the ALB. | `string` | n/a | yes |
| <a name="input_alb_arn_suffix"></a> [alb\_arn\_suffix](#input\_alb\_arn\_suffix) | The ARN suffix of ALB. | `string` | n/a | yes |
| <a name="input_alb_ingress_stickiness_cookie_duration"></a> [alb\_ingress\_stickiness\_cookie\_duration](#input\_alb\_ingress\_stickiness\_cookie\_duration) | The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds) | `number` | `86400` | no |
| <a name="input_alb_ingress_stickiness_enabled"></a> [alb\_ingress\_stickiness\_enabled](#input\_alb\_ingress\_stickiness\_enabled) | Boolean to enable / disable `stickiness`. | `bool` | `true` | no |
| <a name="input_alb_ingress_stickiness_type"></a> [alb\_ingress\_stickiness\_type](#input\_alb\_ingress\_stickiness\_type) | The type of sticky sessions. The only current possible value is `lb_cookie` | `string` | `"lb_cookie"` | no |
| <a name="input_alb_listeners"></a> [alb\_listeners](#input\_alb\_listeners) | A list of map containing a port and a protocol and optionally a `default_action` for all ALB listeners. | <pre>list(object({<br>    port     = number<br>    protocol = string<br>    default_action = object({<br>      type             = string<br>      target_group_arn = optional(string)<br>      redirect = optional(object({<br>        host        = optional(string)<br>        path        = optional(string)<br>        port        = optional(string)<br>        protocol    = optional(string)<br>        query       = optional(string)<br>        status_code = string<br>      }))<br>      fixed_response = optional(object({<br>        content_type = string<br>        message_body = optional(string)<br>        status_code  = optional(string)<br>      }))<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "default_action": {<br>      "type": "forward"<br>    },<br>    "port": 80,<br>    "protocol": "HTTP"<br>  }<br>]</pre> | no |
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | ALB security group id (to allow connection from the ALB to the service). | `string` | n/a | yes |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | List of FQDN's - Used to set the Alternate Domain Names (CNAMEs). | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_cpu_enabled"></a> [autoscaling\_cpu\_enabled](#input\_autoscaling\_cpu\_enabled) | Whether the ECS service should scale based on CPU utilization. | `bool` | `false` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Whether to enable autoscaling for the ECS service. | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of running instances of a Service. | `number` | `2` | no |
| <a name="input_autoscaling_memory_enabled"></a> [autoscaling\_memory\_enabled](#input\_autoscaling\_memory\_enabled) | Whether the ECS service should scale based on memory utilization. | `bool` | `false` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of running instances of a Service. | `number` | `1` | no |
| <a name="input_autoscaling_scale_down_adjustment"></a> [autoscaling\_scale\_down\_adjustment](#input\_autoscaling\_scale\_down\_adjustment) | Scaling adjustment to make during scale down event. | `number` | `-1` | no |
| <a name="input_autoscaling_scale_down_cooldown"></a> [autoscaling\_scale\_down\_cooldown](#input\_autoscaling\_scale\_down\_cooldown) | Period (in seconds) to wait between scale down events. | `number` | `300` | no |
| <a name="input_autoscaling_scale_up_adjustment"></a> [autoscaling\_scale\_up\_adjustment](#input\_autoscaling\_scale\_up\_adjustment) | Scaling adjustment to make during scale up event. | `number` | `1` | no |
| <a name="input_autoscaling_scale_up_cooldown"></a> [autoscaling\_scale\_up\_cooldown](#input\_autoscaling\_scale\_up\_cooldown) | Period (in seconds) to wait between scale up events. | `number` | `60` | no |
| <a name="input_certificate_certificate_body_base64"></a> [certificate\_certificate\_body\_base64](#input\_certificate\_certificate\_body\_base64) | The certificate's PEM-formatted public key base64-encoded. | `string` | `""` | no |
| <a name="input_certificate_chain_base64"></a> [certificate\_chain\_base64](#input\_certificate\_chain\_base64) | The certificate's PEM-formatted chain base64-encoded. | `string` | `""` | no |
| <a name="input_certificate_private_key_base64"></a> [certificate\_private\_key\_base64](#input\_certificate\_private\_key\_base64) | The certificate's PEM-formatted private key base64-encoded. | `string` | `""` | no |
| <a name="input_certificate_transparency_logging_preference"></a> [certificate\_transparency\_logging\_preference](#input\_certificate\_transparency\_logging\_preference) | Specifies whether certificate details should be added to a certificate transparency log. | `bool` | `true` | no |
| <a name="input_certificate_type"></a> [certificate\_type](#input\_certificate\_type) | Used to chose a sub-module. Should be either `request` or `import` a certificate. | `string` | `"request"` | no |
| <a name="input_certificate_validation_method"></a> [certificate\_validation\_method](#input\_certificate\_validation\_method) | Method to use for validation, DNS or EMAIL. | `string` | `"DNS"` | no |
| <a name="input_certificate_wait_for_certificate_issued"></a> [certificate\_wait\_for\_certificate\_issued](#input\_certificate\_wait\_for\_certificate\_issued) | Whether to wait for the certificate to be issued by ACM (the certificate status changed from `Pending Validation` to `Issued`). | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain Cloudwatch logs. | `number` | `60` | no |
| <a name="input_container_definition_json"></a> [container\_definition\_json](#input\_container\_definition\_json) | A string containing a JSON-encoded array of container definitions<br>(`"[{ "name": "container1", ... }, { "name": "container2", ... }]"`).<br>See [API\_ContainerDefinition](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html),<br>[cloudposse/terraform-aws-ecs-container-definition](https://github.com/cloudposse/terraform-aws-ecs-container-definition), or<br>[ecs\_task\_definition#container\_definitions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#container_definitions) | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_service_security_group_enabled"></a> [default\_service\_security\_group\_enabled](#input\_default\_service\_security\_group\_enabled) | Enables the creation of a default security group for the ECS Service | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_alias_enabled"></a> [dns\_alias\_enabled](#input\_dns\_alias\_enabled) | Create a DNS alias for the CDN. Requires `parent_zone_id` or `parent_zone_name`. | `bool` | `false` | no |
| <a name="input_ecs_alarm_description"></a> [ecs\_alarm\_description](#input\_ecs\_alarm\_description) | The string to format and use as the ECS alarm description. | `string` | `"Average service %v utilization %v last %f minute(s) over %v period(s)"` | no |
| <a name="input_ecs_alarms_cpu_utilization_high_alarm_actions"></a> [ecs\_alarms\_cpu\_utilization\_high\_alarm\_actions](#input\_ecs\_alarms\_cpu\_utilization\_high\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_cpu_utilization_high_evaluation_periods"></a> [ecs\_alarms\_cpu\_utilization\_high\_evaluation\_periods](#input\_ecs\_alarms\_cpu\_utilization\_high\_evaluation\_periods) | Number of periods to evaluate for the alarm. | `number` | `1` | no |
| <a name="input_ecs_alarms_cpu_utilization_high_ok_actions"></a> [ecs\_alarms\_cpu\_utilization\_high\_ok\_actions](#input\_ecs\_alarms\_cpu\_utilization\_high\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_cpu_utilization_high_period"></a> [ecs\_alarms\_cpu\_utilization\_high\_period](#input\_ecs\_alarms\_cpu\_utilization\_high\_period) | Duration in seconds to evaluate for the alarm. | `number` | `300` | no |
| <a name="input_ecs_alarms_cpu_utilization_high_threshold"></a> [ecs\_alarms\_cpu\_utilization\_high\_threshold](#input\_ecs\_alarms\_cpu\_utilization\_high\_threshold) | The maximum percentage of CPU utilization average. | `number` | `80` | no |
| <a name="input_ecs_alarms_cpu_utilization_low_alarm_actions"></a> [ecs\_alarms\_cpu\_utilization\_low\_alarm\_actions](#input\_ecs\_alarms\_cpu\_utilization\_low\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_cpu_utilization_low_evaluation_periods"></a> [ecs\_alarms\_cpu\_utilization\_low\_evaluation\_periods](#input\_ecs\_alarms\_cpu\_utilization\_low\_evaluation\_periods) | Number of periods to evaluate for the alarm. | `number` | `1` | no |
| <a name="input_ecs_alarms_cpu_utilization_low_ok_actions"></a> [ecs\_alarms\_cpu\_utilization\_low\_ok\_actions](#input\_ecs\_alarms\_cpu\_utilization\_low\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_cpu_utilization_low_period"></a> [ecs\_alarms\_cpu\_utilization\_low\_period](#input\_ecs\_alarms\_cpu\_utilization\_low\_period) | Duration in seconds to evaluate for the alarm. | `number` | `300` | no |
| <a name="input_ecs_alarms_cpu_utilization_low_threshold"></a> [ecs\_alarms\_cpu\_utilization\_low\_threshold](#input\_ecs\_alarms\_cpu\_utilization\_low\_threshold) | The minimum percentage of CPU utilization average. | `number` | `20` | no |
| <a name="input_ecs_alarms_enabled"></a> [ecs\_alarms\_enabled](#input\_ecs\_alarms\_enabled) | Whether to enable SNS alarms for the ECS service. | `bool` | `false` | no |
| <a name="input_ecs_alarms_memory_utilization_high_alarm_actions"></a> [ecs\_alarms\_memory\_utilization\_high\_alarm\_actions](#input\_ecs\_alarms\_memory\_utilization\_high\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_memory_utilization_high_evaluation_periods"></a> [ecs\_alarms\_memory\_utilization\_high\_evaluation\_periods](#input\_ecs\_alarms\_memory\_utilization\_high\_evaluation\_periods) | Number of periods to evaluate for the alarm. | `number` | `1` | no |
| <a name="input_ecs_alarms_memory_utilization_high_ok_actions"></a> [ecs\_alarms\_memory\_utilization\_high\_ok\_actions](#input\_ecs\_alarms\_memory\_utilization\_high\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_memory_utilization_high_period"></a> [ecs\_alarms\_memory\_utilization\_high\_period](#input\_ecs\_alarms\_memory\_utilization\_high\_period) | Duration in seconds to evaluate for the alarm. | `number` | `300` | no |
| <a name="input_ecs_alarms_memory_utilization_high_threshold"></a> [ecs\_alarms\_memory\_utilization\_high\_threshold](#input\_ecs\_alarms\_memory\_utilization\_high\_threshold) | The maximum percentage of Memory utilization average. | `number` | `80` | no |
| <a name="input_ecs_alarms_memory_utilization_low_alarm_actions"></a> [ecs\_alarms\_memory\_utilization\_low\_alarm\_actions](#input\_ecs\_alarms\_memory\_utilization\_low\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_memory_utilization_low_evaluation_periods"></a> [ecs\_alarms\_memory\_utilization\_low\_evaluation\_periods](#input\_ecs\_alarms\_memory\_utilization\_low\_evaluation\_periods) | Number of periods to evaluate for the alarm. | `number` | `1` | no |
| <a name="input_ecs_alarms_memory_utilization_low_ok_actions"></a> [ecs\_alarms\_memory\_utilization\_low\_ok\_actions](#input\_ecs\_alarms\_memory\_utilization\_low\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action. | `list(string)` | `[]` | no |
| <a name="input_ecs_alarms_memory_utilization_low_period"></a> [ecs\_alarms\_memory\_utilization\_low\_period](#input\_ecs\_alarms\_memory\_utilization\_low\_period) | Duration in seconds to evaluate for the alarm. | `number` | `300` | no |
| <a name="input_ecs_alarms_memory_utilization_low_threshold"></a> [ecs\_alarms\_memory\_utilization\_low\_threshold](#input\_ecs\_alarms\_memory\_utilization\_low\_threshold) | The minimum percentage of Memory utilization average. | `number` | `20` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | The ARN of the ECS cluster. | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | The name of the ECS cluster. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Indicates whether health checks are enabled. Defaults to `true` | `bool` | `true` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | The number of consecutive health checks successes required before healthy | `number` | `2` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The duration in seconds in between health checks | `number` | `15` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | The HTTP response codes to indicate a healthy check.<br>Example: `"200-399"` | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for the health check request | `string` | `"/"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | The port to use to connect with the target. Valid values are either ports 1-65536, or `traffic-port`. Defaults to `traffic-port` | `string` | `"traffic-port"` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | The protocol to use to connect with the target. Defaults to `HTTP`. Not applicable when `target_type` is `lambda` | `string` | `"HTTP"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | The amount of time to wait in seconds before failing a health check request | `number` | `10` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | The number of consecutive health check failures required before unhealthy | `number` | `2` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | DEPRECATED: Use `health_check_path` instead.<br>Path for the ALB health checks. | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS Key ARN for Cloudwatch logs. | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_parent_zone_id"></a> [parent\_zone\_id](#input\_parent\_zone\_id) | ID of the hosted zone to contain this record (or specify `parent_zone_name`). Requires `dns_alias_enabled` set to true. | `string` | `""` | no |
| <a name="input_parent_zone_name"></a> [parent\_zone\_name](#input\_parent\_zone\_name) | Name of the hosted zone to contain this record (or specify `parent_zone_id`). Requires `dns_alias_enabled` set to true. | `string` | `""` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_service_assign_public_ip"></a> [service\_assign\_public\_ip](#input\_service\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false`. | `bool` | `false` | no |
| <a name="input_service_circuit_breaker_deployment_enabled"></a> [service\_circuit\_breaker\_deployment\_enabled](#input\_service\_circuit\_breaker\_deployment\_enabled) | Whether to enable the deployment circuit breaker logic for the service. | `bool` | `false` | no |
| <a name="input_service_circuit_breaker_rollback_enabled"></a> [service\_circuit\_breaker\_rollback\_enabled](#input\_service\_circuit\_breaker\_rollback\_enabled) | Whether to enable Amazon ECS to roll back the service if a service deployment fails. | `bool` | `false` | no |
| <a name="input_service_container_name"></a> [service\_container\_name](#input\_service\_container\_name) | Name of the service to map to the load balancer. | `string` | n/a | yes |
| <a name="input_service_container_port"></a> [service\_container\_port](#input\_service\_container\_port) | Container internal port for the service. | `number` | n/a | yes |
| <a name="input_service_container_protocol"></a> [service\_container\_protocol](#input\_service\_container\_protocol) | Container protocol for the service. | `string` | `"HTTP"` | no |
| <a name="input_service_deployment_controller_type"></a> [service\_deployment\_controller\_type](#input\_service\_deployment\_controller\_type) | Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS`. | `string` | `"ECS"` | no |
| <a name="input_service_deployment_maximum_percent"></a> [service\_deployment\_maximum\_percent](#input\_service\_deployment\_maximum\_percent) | The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment. | `number` | `200` | no |
| <a name="input_service_deployment_minimum_healthy_percent"></a> [service\_deployment\_minimum\_healthy\_percent](#input\_service\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment. | `number` | `100` | no |
| <a name="input_service_desired_count"></a> [service\_desired\_count](#input\_service\_desired\_count) | The number of instances of the task definition to place and keep running. | `number` | `1` | no |
| <a name="input_service_exec_enabled"></a> [service\_exec\_enabled](#input\_service\_exec\_enabled) | Specifies whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_service_health_check_grace_period_seconds"></a> [service\_health\_check\_grace\_period\_seconds](#input\_service\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers. | `number` | `0` | no |
| <a name="input_service_ignore_changes_desired_count"></a> [service\_ignore\_changes\_desired\_count](#input\_service\_ignore\_changes\_desired\_count) | Whether to ignore changes for desired count in the ECS service. | `bool` | `false` | no |
| <a name="input_service_ignore_changes_task_definition"></a> [service\_ignore\_changes\_task\_definition](#input\_service\_ignore\_changes\_task\_definition) | Whether to ignore changes in container definition and task definition in the ECS service. | `bool` | `true` | no |
| <a name="input_service_launch_type"></a> [service\_launch\_type](#input\_service\_launch\_type) | The launch type on which to run your service. Valid values are `EC2` and `FARGATE`. | `string` | `"FARGATE"` | no |
| <a name="input_service_security_groups"></a> [service\_security\_groups](#input\_service\_security\_groups) | A list of Security Group IDs to allow in Service `network_configuration` if `var.network_mode = "awsvpc"`. | `list(string)` | `[]` | no |
| <a name="input_service_task_cpu"></a> [service\_task\_cpu](#input\_service\_task\_cpu) | The number of CPU units used by the task. If using `FARGATE` launch type `task_cpu` must match [supported memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size). | `number` | `256` | no |
| <a name="input_service_task_memory"></a> [service\_task\_memory](#input\_service\_task\_memory) | The amount of memory (in MiB) used by the task. If using Fargate launch type `task_memory` must match [supported cpu value](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size). | `number` | `512` | no |
| <a name="input_service_task_policy_arns"></a> [service\_task\_policy\_arns](#input\_service\_task\_policy\_arns) | A list of IAM Policy ARNs to attach to the generated task role. | `list(string)` | `[]` | no |
| <a name="input_service_volumes"></a> [service\_volumes](#input\_service\_volumes) | Task volume definitions as list of configuration objects. | <pre>list(object({<br>    host_path = string<br>    name      = string<br>    docker_volume_configuration = list(object({<br>      autoprovision = bool<br>      driver        = string<br>      driver_opts   = map(string)<br>      labels        = map(string)<br>      scope         = string<br>    }))<br>    efs_volume_configuration = list(object({<br>      file_system_id          = string<br>      root_directory          = string<br>      transit_encryption      = string<br>      transit_encryption_port = string<br>      authorization_config = list(object({<br>        access_point_id = string<br>        iam             = string<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the DB. DB instance will be created in the VPC associated with the DB subnet group provisioned using the subnet IDs. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID the DB instance will be created in. | `string` | n/a | yes |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_listener_arns"></a> [alb\_listener\_arns](#output\_alb\_listener\_arns) | The ARN of the ALB listeners. |
| <a name="output_ecs_service_security_group_id"></a> [ecs\_service\_security\_group\_id](#output\_ecs\_service\_security\_group\_id) | The ID of the Security Group for the ECS service. |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ECS Service ARN |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | ECS Service name |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | ECS task definition family |
| <a name="output_task_exec_role_arn"></a> [task\_exec\_role\_arn](#output\_task\_exec\_role\_arn) | ECS Task exec role ARN |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ECS Task role ARN |
| <a name="output_url"></a> [url](#output\_url) | Full URL of the app |

## Breaking Changes

Please consult [BREAKING\_CHANGES.md](BREAKING\_CHANGES.md) for more information about version
history and compatibility.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the process for
contributing to this project.

Be mindful of our [Code of Conduct](CODE\_OF\_CONDUCT.md).

## We're hiring

Look for current openings on BambooHR https://nventive.bamboohr.com/careers/

## Stay in touch

[nventive.com](https://nventive.com/) | [Linkedin](https://www.linkedin.com/company/nventive/) | [Instagram](https://www.instagram.com/hellonventive/) | [YouTube](https://www.youtube.com/channel/UCFQyvGEKMO10hEyvCqprp5w) | [Spotify](https://open.spotify.com/show/0lsxfIb6Ttm76jB4wgutob)
<!-- END_TF_DOCS -->