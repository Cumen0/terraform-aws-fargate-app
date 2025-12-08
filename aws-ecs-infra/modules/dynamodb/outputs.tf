output "table_name" {
  value = aws_dynamodb_table.todo_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.todo_table.arn
}
