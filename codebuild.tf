
resource "aws_codebuild_project" "c7n-aws-functional" {
  name           = "c7n-aws-functional"
  description    = "Run Cloud Custodian AWS Functional Tests"
  build_timeout  = "15"
  queued_timeout = "60"
  badge_enabled  = true
  source_version = "master"

  service_role = aws_iam_role.c7n-aws-functional.arn

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
    buildspec       = <<BUILDSPEC
version: 0.2
env:
  variables:
    C7N_FUNCTIONAL: true
  exported-variables:
  - C7N_FUNCTIONAL
phases:
  install:
    runtime-versions:
      python: 3.8
    commands: # todo (mc): build a virtual environment and specify custom pip cache
    - export TEMP_ROLE="$(aws sts assume-role --role-arn ${aws_iam_role.test-runner-test-target.arn} --role-session-name test-runner-test-target)"
    - export AWS_ACCESS_KEY_ID=$(echo "$TEMP_ROLE" | jq -r '.Credentials.AccessKeyId')
    - export AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_ROLE" | jq -r '.Credentials.SecretAccessKey')
    - export AWS_SESSION_TOKEN=$(echo "$TEMP_ROLE" | jq -r '.Credentials.SessionToken')
    - wget -q https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
    - unzip -qq terraform*.zip
    - mv terraform /usr/local/bin
    - pip install --cache-dir=./.pip-cache -qr requirements.txt
  build:
    commands:
    - pytest tests -m terraform -n auto
  post_build:
    commands:
    - echo 'aws_nuke'
cache:
  paths:
    - tests/terraform/.tfcache
    - .pip-cache
BUILDSPEC
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

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "GCP_SERVICE_ACCOUNT"
      type  = "SECRETS_MANAGER"
      value = "functional-testing/c7n-gcp-functional"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/cloud-custodian/cloud-custodian.git"
    git_clone_depth = 1
    buildspec       = <<BUILDSPEC
version: 0.2
env:
  variables:
    C7N_FUNCTIONAL: true
  exported-variables:
  - C7N_FUNCTIONAL
phases:
  install:
    runtime-versions:
      python: 3.8
    commands:
    - python -m venv /venv
    - . /venv/bin/activate
    # SECRETS_MANAGER Does something weird with the credentials.json file, not parsable by Terraform. This script loads it ignoring errors and dumps a cleaner version
    - python -c 'import os; import json; creds = json.loads(os.environ.get("GCP_SERVICE_ACCOUNT"), strict=False); f = open("/google_credentials.json", mode="w"); f.write(json.dumps(creds)); f.close()'
    - export GOOGLE_CLOUD_PROJECT=c7n-test-target
    - export GOOGLE_APPLICATION_CREDENTIALS="/google_credentials.json"
    - wget -q https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
    - unzip -qq terraform*.zip
    - mv terraform /usr/local/bin
    - pip install -qr requirements.txt -r tools/c7n_gcp/requirements.txt
    - python setup.py -q install
    - cd tools/c7n_gcp
    - python setup.py -q install
    - pip install git+https://github.com/cloud-custodian/pytest-terraform.git@better-logging
  build:
    commands:
    - pytest tests -m terraform -n auto
  post_build:
    commands:
    - echo 'gcp_nuke'
cache:
  paths:
    - .pip-cache
BUILDSPEC
  }
}
