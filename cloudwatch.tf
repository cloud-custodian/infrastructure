resource "aws_cloudwatch_event_rule" "c7n-nightly" {
  name        = "c7n-nightly"
  description = "Trigger a codebuild run on a daily basis"

  schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "c7n-nightly-aws-functional" {
  rule      = aws_cloudwatch_event_rule.c7n-nightly.name
  target_id = "c7n-nightly-aws-functional"
  arn       = aws_codebuild_project.c7n-aws-functional.arn
  role_arn  = aws_iam_role.c7n-nightly.arn
}

resource "aws_cloudwatch_event_target" "c7n-nightly-gcp-functional" {
  rule      = aws_cloudwatch_event_rule.c7n-nightly.name
  target_id = "c7n-nightly-gcp-functional"
  arn       = aws_codebuild_project.c7n-gcp-functional.arn
  role_arn  = aws_iam_role.c7n-nightly.arn
}

resource "aws_cloudwatch_event_target" "c7n-nightly-azure-functional" {
  rule      = aws_cloudwatch_event_rule.c7n-nightly.name
  target_id = "c7n-nightly-azure-functional"
  arn       = aws_codebuild_project.c7n-azure-functional.arn
  role_arn  = aws_iam_role.c7n-nightly.arn
}
