# CloudWatch Alarm for monitoring SQS queue age
resource "aws_cloudwatch_metric_alarm" "sqs_age_alarm" {
  alarm_name          = "${var.prefix}_sqs_age_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "60"  
  statistic           = "Maximum"
  threshold           = var.threshold   
  alarm_description   = "Alarm if messages in SQS queue are delayed over threshold."
  actions_enabled     = true

  dimensions = {
    QueueName = aws_sqs_queue.sqs_queue.name
  }

  alarm_actions = [aws_sns_topic.sqs_notification.arn]
}

# SNS Topic for CloudWatch Alarm notifications
resource "aws_sns_topic" "sqs_notification" {
  name = "${var.prefix}_sqs_alarm_topic"
}

# SNS Topic Subscription for email notifications
resource "aws_sns_topic_subscription" "sqs_email_subscription" {
  topic_arn = aws_sns_topic.sqs_notification.arn
  protocol  = "email"
  endpoint  = var.alarm_email
  
  lifecycle {
    ignore_changes = [endpoint]
  }
}

