variable "ecs_cluster_name" {}
variable "ecs_service_name" {}



resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
}


resource "aws_appautoscaling_policy" "ecs_scaling_policy" {
  depends_on = [ aws_appautoscaling_target.ecs_scaling_target ]
  name               = "ecs-autoscaling-policy"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}