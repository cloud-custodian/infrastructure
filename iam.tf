#
# C7N AWS Functional Test Runner
data "aws_iam_policy_document" "c7n-aws-functional-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "c7n-aws-functional" {
  name = "c7n-aws-functional"

  assume_role_policy = data.aws_iam_policy_document.c7n-aws-functional-assume-role.json
}

data "aws_iam_policy_document" "c7n-aws-functional-test-runner" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [
      aws_iam_role.test-runner-test-target.arn,
    ]
  }

  statement {
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]

  }

  statement {
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "c7n-aws-functional-test-runner" {
  name   = "c7n-aws-functional-test-runner"
  policy = data.aws_iam_policy_document.c7n-aws-functional-test-runner.json
}

resource "aws_iam_policy_attachment" "c7n-aws-functional-test-runner" {
  name       = "c7n-aws-functional-test-runner"
  policy_arn = aws_iam_policy.c7n-aws-functional-test-runner.arn

  roles = [
    aws_iam_role.c7n-aws-functional.name,
  ]
}
#

#
# C7N AWS Test Target A Account
data "aws_iam_policy_document" "test-runner-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.c7n-aws-functional.arn]
    }
  }
}

data "aws_iam_policy_document" "test-runner-test-target-access" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "test-runner-test-target-access" {
  provider = aws.target-a
  name     = "test-runner-test-target-access"
  policy   = data.aws_iam_policy_document.test-runner-test-target-access.json
}

resource "aws_iam_policy_attachment" "test-runner-test-target-access" {
  provider   = aws.target-a
  name       = "test-runner-test-target-access"
  policy_arn = aws_iam_policy.test-runner-test-target-access.arn

  roles = [
    aws_iam_role.test-runner-test-target.id
  ]
}

resource "aws_iam_role" "test-runner-test-target" {
  provider           = aws.target-a
  name               = "test-runner-test-target"
  assume_role_policy = data.aws_iam_policy_document.test-runner-assume-role.json
}
#


#
# C7N GCP Functional Test Runner
data "aws_iam_policy_document" "c7n-gcp-functional-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "c7n-gcp-functional" {
  name = "c7n-gcp-functional"

  assume_role_policy = data.aws_iam_policy_document.c7n-gcp-functional-assume-role.json
}

data "aws_iam_policy_document" "c7n-gcp-functional-test-runner" {
  statement {
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }

  statement {
    resources = [
      data.aws_secretsmanager_secret.c7n-gcp-functional.arn,
    ]

    actions = [
      "secretsmanager:GetSecretValue",
    ]
  }

  statement {
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "c7n-gcp-functional-test-runner" {
  name   = "c7n-gcp-functional-test-runner"
  policy = data.aws_iam_policy_document.c7n-gcp-functional-test-runner.json
}

resource "aws_iam_policy_attachment" "c7n-gcp-functional-test-runner" {
  name       = "c7n-gcp-functional-test-runner"
  policy_arn = aws_iam_policy.c7n-gcp-functional-test-runner.arn

  roles = [
    aws_iam_role.c7n-gcp-functional.name,
  ]
}
#


#
# C7N Azure Functional Test Runner
data "aws_iam_policy_document" "c7n-azure-functional-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "c7n-azure-functional" {
  name = "c7n-azure-functional"

  assume_role_policy = data.aws_iam_policy_document.c7n-azure-functional-assume-role.json
}

data "aws_iam_policy_document" "c7n-azure-functional-test-runner" {
  statement {
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }

  statement {
    resources = [
      data.aws_secretsmanager_secret.c7n-azure-functional.arn,
    ]

    actions = [
      "secretsmanager:GetSecretValue",
    ]
  }

  statement {
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "c7n-azure-functional-test-runner" {
  name   = "c7n-azure-functional-test-runner"
  policy = data.aws_iam_policy_document.c7n-azure-functional-test-runner.json
}

resource "aws_iam_policy_attachment" "c7n-azure-functional-test-runner" {
  name       = "c7n-azure-functional-test-runner"
  policy_arn = aws_iam_policy.c7n-azure-functional-test-runner.arn

  roles = [
    aws_iam_role.c7n-azure-functional.name,
  ]
}
#


#
# C7N CloudWatch Codebuild
data "aws_iam_policy_document" "c7n-nightly-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "c7n-nightly" {
  name = "c7n-nightly"

  assume_role_policy = data.aws_iam_policy_document.c7n-nightly-assume-role.json
}

data "aws_iam_policy_document" "c7n-nightly" {
  statement {
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    actions   = ["codebuild:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "c7n-nightly" {
  name   = "c7n-nightly"
  policy = data.aws_iam_policy_document.c7n-nightly.json
}

resource "aws_iam_policy_attachment" "c7n-nightly" {
  name       = "c7n-nightly"
  policy_arn = aws_iam_policy.c7n-nightly.arn

  roles = [
    aws_iam_role.c7n-nightly.name,
  ]
}
#
