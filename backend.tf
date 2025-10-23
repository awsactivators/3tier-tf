terraform {
  backend "s3" {
    bucket = "mytumisbucket"
    key    = "tfstate"
    region = "us-east-2"
  }
}