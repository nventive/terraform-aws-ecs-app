output "service_name" {
  value       = module.service.service_name
  description = "ECS Service name"
}

output "service_arn" {
  value       = module.service.service_arn
  description = "ECS Service ARN"
}

output "url" {
  value       = local.url
  description = "Full URL of the app"
}

output "task_definition_family" {
  value       = module.service.task_definition_family
  description = "ECS task definition family"
}

output "alb_listener_arns" {
  description = "The ARN of the ALB listeners."
  value       = aws_lb_listener.app.*.arn
}

output "ecs_service_security_group_id" {
  value = module.ecs_service_sg.id
}
