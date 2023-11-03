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
