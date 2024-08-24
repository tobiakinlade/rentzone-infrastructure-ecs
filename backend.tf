# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "tobi-terraform-rentzone-state-file"
    key            = "terraform-module/rentzone/terraform.tfstate"
    region         = "eu-west-2"
    profile        = "tee"
    dynamodb_table = "terraform-state-lock"
  }
}