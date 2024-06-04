locals {
  use_acm                  = (var.dns_alias_enabled && length(var.aliases) != 0) || var.certificate_type == "import"
  acm_alt_names            = length(var.aliases) > 1 ? slice(var.aliases, 1, length(var.aliases)) : []
  protocol                 = aws_lb_listener.app[0].protocol == "HTTPS" ? "https" : "http"
  address                  = var.dns_alias_enabled ? var.aliases[0] : data.aws_lb.alb.dns_name
  url                      = "${local.protocol}://${local.address}:${aws_lb_listener.app[0].port}"
  enabled                  = module.this.enabled
  ecs_service_task_sg_name = "${module.this.id}-ecs-service-task"
  health_check_path        = var.healthcheck_path != null ? var.healthcheck_path : var.health_check_path

  listener_target_group_arns = [for listener in var.alb_listeners : listener.default_action.target_group_arn]
  default_action_types       = [for listener in var.alb_listeners : listener.default_action.type]
}

data "aws_lb" "alb" {
  arn = var.alb_arn
}

resource "aws_cloudwatch_log_group" "app" {
  count = local.enabled ? 1 : 0

  name              = module.this.id
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = module.this.tags
}

module "alb_ingress" {
  source  = "cloudposse/alb-ingress/aws"
  version = "0.25.1"

  vpc_id                         = var.vpc_id
  port                           = var.service_container_port
  protocol                       = var.service_container_protocol
  health_check_enabled           = var.health_check_enabled
  health_check_path              = local.health_check_path
  health_check_matcher           = var.health_check_matcher
  health_check_port              = var.health_check_port
  health_check_protocol          = var.health_check_protocol
  health_check_timeout           = var.health_check_timeout
  health_check_healthy_threshold = var.health_check_healthy_threshold
  health_check_interval          = var.health_check_interval
  default_target_group_enabled   = true
  stickiness_type                = var.alb_ingress_stickiness_type
  stickiness_cookie_duration     = var.alb_ingress_stickiness_cookie_duration
  stickiness_enabled             = var.alb_ingress_stickiness_enabled

  context    = module.this.context
  attributes = concat(module.this.attributes, [lower(var.service_container_protocol), var.service_container_port])
}

module "acm_certificate" {
  source  = "nventive/acm-certificate/aws"
  version = "1.0.1"

  enabled = local.use_acm && local.enabled

  providers = {
    aws.route53 = aws.route53
    aws.acm     = aws
  }

  type                                        = var.certificate_type
  wait_for_certificate_issued                 = var.certificate_wait_for_certificate_issued
  domain_name                                 = var.certificate_type == "request" ? var.aliases[0] : ""
  validation_method                           = var.certificate_validation_method
  process_domain_validation_options           = true
  ttl                                         = 300
  subject_alternative_names                   = local.acm_alt_names
  zone_name                                   = var.parent_zone_name
  zone_id                                     = var.parent_zone_id
  certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
  private_key_base64                          = var.certificate_private_key_base64
  certificate_body_base64                     = var.certificate_certificate_body_base64
  certificate_chain_base64                    = var.certificate_chain_base64

  context = module.this.context
}

resource "aws_lb_listener" "app" {
  count = local.enabled ? length(var.alb_listeners) : 0

  load_balancer_arn = var.alb_arn
  port              = var.alb_listeners[count.index].port
  protocol          = var.alb_listeners[count.index].protocol
  certificate_arn   = var.alb_listeners[count.index].protocol == "HTTPS" ? module.acm_certificate.arn : null

  dynamic "default_action" {
    # This for_each basically acts as an if statement.
    for_each = local.default_action_types[count.index] == "forward" ? range(1) : range(0)
    content {
      type             = var.alb_listeners[count.index].default_action.type
      target_group_arn = try(length(local.listener_target_group_arns[count.index]) > 0, false) ? local.listener_target_group_arns[count.index] : module.alb_ingress.target_group_arn
    }
  }

  dynamic "default_action" {
    # This for_each basically acts as an if statement.
    for_each = local.default_action_types[count.index] == "fixed_response" ? range(1) : range(0)
    content {
      type = var.alb_listeners[count.index].default_action.type
      fixed_response {
        content_type = var.alb_listeners[count.index].default_action.fixed_response["content_type"]
        message_body = lookup(var.alb_listeners[count.index].default_action.fixed_response, "message_body", null)
        status_code  = lookup(var.alb_listeners[count.index].default_action.fixed_response, "status_code", null)
      }
    }
  }

  dynamic "default_action" {
    # This for_each basically acts as an if statement.
    for_each = local.default_action_types[count.index] == "redirect" ? range(1) : range(0)
    content {
      type = var.alb_listeners[count.index].default_action.type
      redirect {
        host        = lookup(var.alb_listeners[count.index].default_action.redirect, "host", null)
        path        = lookup(var.alb_listeners[count.index].default_action.redirect, "path", null)
        port        = lookup(var.alb_listeners[count.index].default_action.redirect, "port", null)
        protocol    = lookup(var.alb_listeners[count.index].default_action.redirect, "protocol", null)
        query       = lookup(var.alb_listeners[count.index].default_action.redirect, "query", null)
        status_code = var.alb_listeners[count.index].default_action.redirect["status_code"]
      }
    }
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [module.acm_certificate]

  tags = module.this.tags
}

module "ecs_service_sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  enabled = local.enabled

  name                       = local.ecs_service_task_sg_name
  security_group_description = "ECS service task SG for ${module.this.id}"

  allow_all_egress           = true
  create_before_destroy      = true
  preserve_security_group_id = true
  vpc_id                     = var.vpc_id

  rules = [
    {
      key                      = "container_ingress_port"
      type                     = "ingress"
      from_port                = var.service_container_port
      to_port                  = var.service_container_port
      protocol                 = "tcp"
      cidr_blocks              = []
      source_security_group_id = var.alb_security_group_id
      self                     = false
      description              = "Allow HTTP/S traffic from load balancer"
    }
  ]

  context = module.this.context

  tags = merge(module.this.tags, {
    Name = local.ecs_service_task_sg_name
  })
}

resource "aws_security_group_rule" "opened_to_alb" {
  count = local.enabled ? length(var.alb_listeners) : 0

  type              = "ingress"
  from_port         = var.alb_listeners[count.index].port
  to_port           = var.alb_listeners[count.index].port
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  security_group_id = var.alb_security_group_id
}

module "service" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.58.0"

  container_definition_json          = var.container_definition_json
  ecs_cluster_arn                    = var.ecs_cluster_arn
  launch_type                        = var.service_launch_type
  vpc_id                             = var.vpc_id
  security_group_enabled             = var.default_service_security_group_enabled
  security_groups                    = concat([module.ecs_service_sg.id], var.service_security_groups)
  subnet_ids                         = var.subnet_ids
  ignore_changes_task_definition     = var.service_ignore_changes_task_definition
  ignore_changes_desired_count       = var.service_ignore_changes_desired_count
  network_mode                       = "awsvpc"
  assign_public_ip                   = var.service_assign_public_ip
  propagate_tags                     = "TASK_DEFINITION"
  health_check_grace_period_seconds  = var.service_health_check_grace_period_seconds
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.service_deployment_maximum_percent
  deployment_controller_type         = var.service_deployment_controller_type
  circuit_breaker_deployment_enabled = var.service_circuit_breaker_deployment_enabled
  circuit_breaker_rollback_enabled   = var.service_circuit_breaker_rollback_enabled
  desired_count                      = var.service_desired_count
  task_memory                        = var.service_task_memory
  task_cpu                           = var.service_task_cpu
  task_policy_arns                   = var.service_task_policy_arns
  exec_enabled                       = var.service_exec_enabled
  volumes                            = var.service_volumes
  wait_for_steady_state              = var.wait_for_steady_state
  ecs_load_balancers = [
    {
      container_name   = var.service_container_name
      container_port   = var.service_container_port
      elb_name         = null
      target_group_arn = module.alb_ingress.target_group_arn
    }
  ]

  context = module.this.context
}

module "autoscaling" {
  source  = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.3"

  enabled = var.autoscaling_enabled && local.enabled

  service_name          = module.service.service_name
  cluster_name          = var.ecs_cluster_name
  min_capacity          = var.autoscaling_min_capacity
  max_capacity          = var.autoscaling_max_capacity
  scale_down_adjustment = var.autoscaling_scale_down_adjustment
  scale_down_cooldown   = var.autoscaling_scale_down_cooldown
  scale_up_adjustment   = var.autoscaling_scale_up_adjustment
  scale_up_cooldown     = var.autoscaling_scale_up_cooldown

  context = module.this.context
}

locals {
  cpu_utilization_high_alarm_actions    = var.autoscaling_enabled && var.autoscaling_cpu_enabled ? module.autoscaling.scale_up_policy_arn : ""
  cpu_utilization_low_alarm_actions     = var.autoscaling_enabled && var.autoscaling_cpu_enabled ? module.autoscaling.scale_down_policy_arn : ""
  memory_utilization_high_alarm_actions = var.autoscaling_enabled && var.autoscaling_memory_enabled ? module.autoscaling.scale_up_policy_arn : ""
  memory_utilization_low_alarm_actions  = var.autoscaling_enabled && var.autoscaling_memory_enabled ? module.autoscaling.scale_down_policy_arn : ""
}

module "ecs_alarms" {
  source  = "cloudposse/ecs-cloudwatch-sns-alarms/aws"
  version = "0.12.3"

  enabled = var.ecs_alarms_enabled && local.enabled

  cluster_name = var.ecs_cluster_name
  service_name = module.service.service_name

  cpu_utilization_high_threshold          = var.ecs_alarms_cpu_utilization_high_threshold
  cpu_utilization_high_evaluation_periods = var.ecs_alarms_cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period             = var.ecs_alarms_cpu_utilization_high_period
  cpu_utilization_high_alarm_actions = compact(concat(
    var.ecs_alarms_cpu_utilization_high_alarm_actions,
    [local.cpu_utilization_high_alarm_actions]
  ))
  cpu_utilization_high_ok_actions        = var.ecs_alarms_cpu_utilization_high_ok_actions
  cpu_utilization_low_threshold          = var.ecs_alarms_cpu_utilization_low_threshold
  cpu_utilization_low_evaluation_periods = var.ecs_alarms_cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period             = var.ecs_alarms_cpu_utilization_low_period
  cpu_utilization_low_alarm_actions = compact(concat(
    var.ecs_alarms_cpu_utilization_low_alarm_actions,
    [local.cpu_utilization_low_alarm_actions]
  ))
  cpu_utilization_low_ok_actions = var.ecs_alarms_cpu_utilization_low_ok_actions

  memory_utilization_high_threshold          = var.ecs_alarms_memory_utilization_high_threshold
  memory_utilization_high_evaluation_periods = var.ecs_alarms_memory_utilization_high_evaluation_periods
  memory_utilization_high_period             = var.ecs_alarms_memory_utilization_high_period
  memory_utilization_high_alarm_actions = compact(concat(
    var.ecs_alarms_memory_utilization_high_alarm_actions,
    [local.memory_utilization_high_alarm_actions]
  ))
  memory_utilization_high_ok_actions        = var.ecs_alarms_memory_utilization_high_ok_actions
  memory_utilization_low_threshold          = var.ecs_alarms_memory_utilization_low_threshold
  memory_utilization_low_evaluation_periods = var.ecs_alarms_memory_utilization_low_evaluation_periods
  memory_utilization_low_period             = var.ecs_alarms_memory_utilization_low_period
  memory_utilization_low_alarm_actions = compact(concat(
    var.ecs_alarms_memory_utilization_low_alarm_actions,
    [local.memory_utilization_low_alarm_actions]
  ))
  memory_utilization_low_ok_actions = var.ecs_alarms_memory_utilization_low_ok_actions

  alarm_description = var.ecs_alarm_description

  context = module.this.context
}

module "alb_alarms" {
  source  = "cloudposse/alb-target-group-cloudwatch-sns-alarms/aws"
  version = "0.17.0"

  enabled = var.alb_alarms_enabled && local.enabled

  alarm_actions                  = var.alb_alarms_alarm_actions
  ok_actions                     = var.alb_alarms_ok_actions
  insufficient_data_actions      = var.alb_alarms_insufficient_data_actions
  alb_arn_suffix                 = var.alb_arn_suffix
  target_group_arn_suffix        = module.alb_ingress.target_group_arn_suffix
  target_3xx_count_threshold     = var.alb_alarms_3xx_threshold
  target_4xx_count_threshold     = var.alb_alarms_4xx_threshold
  target_5xx_count_threshold     = var.alb_alarms_5xx_threshold
  target_response_time_threshold = var.alb_alarms_response_time_threshold
  period                         = var.alb_alarms_period
  evaluation_periods             = var.alb_alarms_evaluation_periods

  context = module.this.context
}
