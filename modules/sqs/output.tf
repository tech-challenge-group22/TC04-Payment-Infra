output "output_sqs_url" {
  value = "${aws_sqs_queue.payment_response.url}"
}