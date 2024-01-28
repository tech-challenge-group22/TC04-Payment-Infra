resource "aws_sqs_queue" "payment_response" {
    name                        = "payment-response.fifo"
    delay_seconds               = 0
    visibility_timeout_seconds  = 30
    max_message_size            = 2048
    message_retention_seconds   = 86400
    receive_wait_time_seconds   = 2
    fifo_queue                  = true
    content_based_deduplication = true
}

resource "aws_sqs_queue" "payment_response_deadletter_queue" {
  name                        = "payment_response_deadletter_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = aws_sqs_queue.payment_response.content_based_deduplication
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_response.arn,
    maxReceiveCount     = 5  # Adjust as needed
  })
}