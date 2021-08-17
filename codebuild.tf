locals {
  build_tf_version = "0.13.4"
}


resource "aws_codebuild_project" "c7n-aws-functional" {
  name           = "c7n-aws-functional"
  description    = "Run Cloud Custodian AWS Functional Tests"
  build_timeout  = "60"
  queued_timeout = "60"
  badge_enabled  = true
  source_version = "master"

  service_role = aws_iam_role.c7n-aws-functional.arn

  # TODO - move to S3 Cache, local is useless for our use cases.
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/cloud-custodian/cloud-custodian.git"
    git_clone_depth = 1
    buildspec       = templatefile("buildspecs/aws.yml", {
      terraform_version = local.build_tf_version,
      target_role = aws_iam_role.test-runner-test-target.arn})
  }
}


resource "aws_codebuild_project" "c7n-gcp-functional" {
  name           = "c7n-gcp-functional"
  description    = "Run Cloud Custodian GCP Functional Tests"
  build_timeout  = "15"
  queued_timeout = "60"
  badge_enabled  = true
  source_version = "master"

  service_role = aws_iam_role.c7n-gcp-functional.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  # TODO - move to S3 Cache, local is useless for our use cases.
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/cloud-custodian/cloud-custodian.git"
    git_clone_depth = 1
    buildspec       = templatefile("buildspecs/gcp.yml", {
      terraform_version = local.build_tf_version})
  }
}

resource "aws_codebuild_project" "c7n-azure-functional" {
  name           = "c7n-azure-functional"
  description    = "Run Cloud Custodian Azure Functional Tests"
  build_timeout  = "180"
  queued_timeout = "60"
  badge_enabled  = true
  source_version = "master"

  service_role = aws_iam_role.c7n-azure-functional.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  # TODO - move to S3 Cache, local is useless for our use cases.
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/cloud-custodian/cloud-custodian.git"
    git_clone_depth = 1
    buildspec       = templatefile("buildspecs/azure.yml", {
      terraform_version = local.build_tf_version})
  }
}
