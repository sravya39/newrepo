provider "aws" {
    region = var.region 
    access_key = "XXXXXXXXXXXXXX"
    secret_key ="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}


data "aws_region" "current" {}
data "aws_availability_zones" "available" {}