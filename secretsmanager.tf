data "aws_secretsmanager_secret" "c7n-gcp-functional" {
  name = "functional-testing/c7n-gcp-functional"
}

data "aws_secretsmanager_secret" "c7n-azure-functional" {
  name = "functional-testing/c7n-azure-functional"
}
