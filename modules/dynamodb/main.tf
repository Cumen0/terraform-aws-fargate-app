resource "aws_dynamodb_table" "todo_table" {
  name         = "${var.project_name}-${var.env}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-dynamodb-table"
  }
}
