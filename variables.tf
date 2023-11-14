variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 60
  description = "Number of days to retain Cloudwatch logs."
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS Key ARN for Cloudwatch logs."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID the DB instance will be created in."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs for the DB. DB instance will be created in the VPC associated with the DB subnet group provisioned using the subnet IDs. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`."
}

variable "service_assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false`."
}

variable "service_container_name" {
  type        = string
  description = "Name of the service to map to the load balancer."
}

variable "service_container_port" {
  type        = number
  description = "Container internal port for the service."
}

variable "service_container_protocol" {
  type        = string
  default     = "HTTP"
  description = "Container protocol for the service."
}

variable "healthcheck_path" {
  type        = string
  description = "Path for the ALB health checks."
}

variable "health_check_matcher" {
  type        = string
  description = "The HTTP response codes to indicate a healthy check."
}

variable "aliases" {
  type        = list(string)
  description = "List of FQDN's - Used to set the Alternate Domain Names (CNAMEs)."
  default     = []
}
variable "dns_alias_enabled" {
  type        = bool
  default     = false
  description = "Create a DNS alias for the CDN. Requires `parent_zone_id` or `parent_zone_name`."
}

variable "certificate_type" {
  type    = string
  default = "request"
  validation {
    condition     = var.certificate_type == "request" || var.certificate_type == "import"
    error_message = "`certificate_type` must be one of `request` or `import`."
  }
  description = "Used to chose a sub-module. Should be either `request` or `import` a certificate."
}

variable "certificate_wait_for_certificate_issued" {
  type        = bool
  default     = false
  description = "Whether to wait for the certificate to be issued by ACM (the certificate status changed from `Pending Validation` to `Issued`)."
}

variable "certificate_validation_method" {
  type        = string
  default     = "DNS"
  description = "Method to use for validation, DNS or EMAIL."
}

variable "certificate_transparency_logging_preference" {
  type        = bool
  default     = true
  description = "Specifies whether certificate details should be added to a certificate transparency log."
}

variable "certificate_private_key_base64" {
  sensitive   = true
  type        = string
  default     = ""
  description = "The certificate's PEM-formatted private key base64-encoded."
}
variable "certificate_certificate_body_base64" {
  sensitive   = true
  type        = string
  default     = ""
  description = "The certificate's PEM-formatted public key base64-encoded."
}
variable "certificate_chain_base64" {
  type        = string
  default     = ""
  description = "The certificate's PEM-formatted chain base64-encoded."
}

variable "parent_zone_id" {
  type        = string
  default     = ""
  description = "ID of the hosted zone to contain this record (or specify `parent_zone_name`). Requires `dns_alias_enabled` set to true."
}

variable "parent_zone_name" {
  type        = string
  default     = ""
  description = "Name of the hosted zone to contain this record (or specify `parent_zone_id`). Requires `dns_alias_enabled` set to true."
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB."
}

variable "alb_listeners" {
  type = list(object({
    port     = number
    protocol = string
  }))
  default     = [{ port = 80, protocol = "HTTP" }]
  description = "A list of map containing a port and a protocol for all ALB listeners."
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB security group id (to allow connection from the ALB to the service)."
}

variable "alb_ingress_stickiness_type" {
  type        = string
  default     = "lb_cookie"
  description = "The type of sticky sessions. The only current possible value is `lb_cookie`"
}

variable "alb_ingress_stickiness_cookie_duration" {
  type        = number
  default     = 86400
  description = "The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)"
}

variable "alb_ingress_stickiness_enabled" {
  type        = bool
  default     = true
  description = "Boolean to enable / disable `stickiness`."
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster."
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster."
}

variable "service_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "The launch type on which to run your service. Valid values are `EC2` and `FARGATE`."
}

variable "service_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of Security Group IDs to allow in Service `network_configuration` if `var.network_mode = \"awsvpc\"`."
}

variable "service_ignore_changes_task_definition" {
  type        = bool
  default     = true
  description = "Whether to ignore changes in container definition and task definition in the ECS service."
}

variable "service_ignore_changes_desired_count" {
  type        = bool
  default     = false
  description = "Whether to ignore changes for desired count in the ECS service."
}

variable "service_health_check_grace_period_seconds" {
  type        = number
  default     = 0
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers."
}

variable "service_deployment_minimum_healthy_percent" {
  type        = number
  default     = 100
  description = "The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment."
}

variable "service_deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment."
}

variable "service_deployment_controller_type" {
  type        = string
  default     = "ECS"
  description = "Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS`."
}

variable "service_circuit_breaker_deployment_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the deployment circuit breaker logic for the service."
}

variable "service_circuit_breaker_rollback_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Amazon ECS to roll back the service if a service deployment fails."
}

variable "service_desired_count" {
  type        = number
  default     = 1
  description = "The number of instances of the task definition to place and keep running."
}

variable "service_task_memory" {
  type        = number
  default     = 512
  description = "The amount of memory (in MiB) used by the task. If using Fargate launch type `task_memory` must match [supported cpu value](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)."
}

variable "service_task_cpu" {
  type        = number
  default     = 256
  description = "The number of CPU units used by the task. If using `FARGATE` launch type `task_cpu` must match [supported memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)."
}

variable "service_exec_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
}

variable "service_task_policy_arns" {
  type        = list(string)
  default     = []
  description = "A list of IAM Policy ARNs to attach to the generated task role."
}

variable "service_volumes" {
  type = list(object({
    host_path = string
    name      = string
    docker_volume_configuration = list(object({
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
      scope         = string
    }))
    efs_volume_configuration = list(object({
      file_system_id          = string
      root_directory          = string
      transit_encryption      = string
      transit_encryption_port = string
      authorization_config = list(object({
        access_point_id = string
        iam             = string
      }))
    }))
  }))
  description = "Task volume definitions as list of configuration objects."
  default     = []
}

variable "wait_for_steady_state" {
  type        = bool
  description = "If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing."
  default     = false
}

variable "autoscaling_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable autoscaling for the ECS service."
}

variable "autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of running instances of a Service."
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = 2
  description = "Maximum number of running instances of a Service."
}

variable "autoscaling_scale_down_adjustment" {
  type        = number
  default     = -1
  description = "Scaling adjustment to make during scale down event."
}

variable "autoscaling_scale_down_cooldown" {
  type        = number
  default     = 300
  description = "Period (in seconds) to wait between scale down events."
}

variable "autoscaling_scale_up_adjustment" {
  type        = number
  default     = 1
  description = "Scaling adjustment to make during scale up event."
}

variable "autoscaling_scale_up_cooldown" {
  type        = number
  default     = 60
  description = "Period (in seconds) to wait between scale up events."
}

variable "autoscaling_cpu_enabled" {
  type        = bool
  default     = false
  description = "Whether the ECS service should scale based on CPU utilization."
}

variable "autoscaling_memory_enabled" {
  type        = bool
  default     = false
  description = "Whether the ECS service should scale based on memory utilization."
}

variable "ecs_alarms_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable SNS alarms for the ECS service."
}

variable "ecs_alarm_description" {
  type        = string
  default     = "Average service %v utilization %v last %f minute(s) over %v period(s)"
  description = "The string to format and use as the ECS alarm description."
}

variable "ecs_alarms_cpu_utilization_high_threshold" {
  type        = number
  default     = 80
  description = "The maximum percentage of CPU utilization average."
}

variable "ecs_alarms_cpu_utilization_high_evaluation_periods" {
  type        = number
  default     = 1
  description = "Number of periods to evaluate for the alarm."
}

variable "ecs_alarms_cpu_utilization_high_period" {
  type        = number
  default     = 300
  description = "Duration in seconds to evaluate for the alarm."
}

variable "ecs_alarms_cpu_utilization_high_alarm_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action."
}

variable "ecs_alarms_cpu_utilization_high_ok_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action."
}

variable "ecs_alarms_cpu_utilization_low_threshold" {
  type        = number
  default     = 20
  description = "The minimum percentage of CPU utilization average."
}

variable "ecs_alarms_cpu_utilization_low_evaluation_periods" {
  type        = number
  default     = 1
  description = "Number of periods to evaluate for the alarm."
}

variable "ecs_alarms_cpu_utilization_low_period" {
  type        = number
  default     = 300
  description = "Duration in seconds to evaluate for the alarm."
}

variable "ecs_alarms_cpu_utilization_low_alarm_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action."
}

variable "ecs_alarms_cpu_utilization_low_ok_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action."
}

variable "ecs_alarms_memory_utilization_high_threshold" {
  type        = number
  default     = 80
  description = "The maximum percentage of Memory utilization average."
}

variable "ecs_alarms_memory_utilization_high_evaluation_periods" {
  type        = number
  default     = 1
  description = "Number of periods to evaluate for the alarm."
}

variable "ecs_alarms_memory_utilization_high_period" {
  type        = number
  default     = 300
  description = "Duration in seconds to evaluate for the alarm."
}

variable "ecs_alarms_memory_utilization_high_alarm_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action."
}

variable "ecs_alarms_memory_utilization_high_ok_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action."
}

variable "ecs_alarms_memory_utilization_low_threshold" {
  type        = number
  default     = 20
  description = "The minimum percentage of Memory utilization average."
}

variable "ecs_alarms_memory_utilization_low_evaluation_periods" {
  type        = number
  default     = 1
  description = "Number of periods to evaluate for the alarm."
}

variable "ecs_alarms_memory_utilization_low_period" {
  type        = number
  default     = 300
  description = "Duration in seconds to evaluate for the alarm."
}

variable "ecs_alarms_memory_utilization_low_alarm_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action."
}

variable "ecs_alarms_memory_utilization_low_ok_actions" {
  type        = list(string)
  default     = []
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action."
}

variable "alb_alarms_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable SNS alarms for the ALB target group."
}

variable "alb_arn_suffix" {
  type        = string
  description = "The ARN suffix of ALB."
}

variable "alb_alarms_alarm_actions" {
  type        = list(string)
  default     = [""]
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an ALARM state from any other state.  If set, this list takes precedence over notify_arns."
}

variable "alb_alarms_ok_actions" {
  type        = list(string)
  default     = [""]
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an OK state from any other state. If set, this list takes precedence over notify_arns."
}
variable "alb_alarms_insufficient_data_actions" {
  type        = list(string)
  default     = [""]
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. If set, this list takes precedence over notify_arns."
}

variable "alb_alarms_3xx_threshold" {
  type        = number
  default     = 25
  description = "The maximum count of 3XX requests over a period. A negative value will disable the alert."
}

variable "alb_alarms_4xx_threshold" {
  type        = number
  default     = 25
  description = "The maximum count of 4XX requests over a period. A negative value will disable the alert."
}

variable "alb_alarms_5xx_threshold" {
  type        = number
  default     = 25
  description = "The maximum count of 5XX requests over a period. A negative value will disable the alert."
}

variable "alb_alarms_response_time_threshold" {
  type        = number
  default     = 0.5
  description = "The maximum average target response time (in seconds) over a period. A negative value will disable the alert."
}
variable "alb_alarms_period" {
  type        = number
  default     = 300
  description = "Duration in seconds to evaluate for the alarm."
}

variable "alb_alarms_evaluation_periods" {
  type        = number
  default     = 1
  description = "Number of periods to evaluate for the alarm."
}

variable "container_definition_json" {
  type        = string
  description = <<-EOT
    A string containing a JSON-encoded array of container definitions
    (`"[{ "name": "container1", ... }, { "name": "container2", ... }]"`).
    See [API_ContainerDefinition](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html),
    [cloudposse/terraform-aws-ecs-container-definition](https://github.com/cloudposse/terraform-aws-ecs-container-definition), or
    [ecs_task_definition#container_definitions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#container_definitions)
    EOT
}

variable "default_service_security_group_enabled" {
  type        = bool
  default     = true
  description = "Enables the creation of a default security group for the ECS Service"
}
