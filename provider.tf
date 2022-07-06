provider "aws" {
  region  = "us-east-2"
  profile = "Test-Runner"
}

provider "aws" {
  alias   = "target-a"
  region  = "us-east-2"
  profile = "Test-Runner-Target-A"
}

provider "aws" {
  alias   = "target-b"
  region  = "us-east-2"
  profile = "Test-Runner-Target-B"
}

terraform {
  backend "s3" {
  }
}
