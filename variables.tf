variable "region" {
    default = "us-east-2"
}

variable "vpc_cidr" {
      default = "10.10.0.0/16"
}


variable "num_of_pub_subnets" {
    default = 2
}

variable "num_of_pri_subnets" {
    default = 2
}

variable "eip_association_address" {
    default = "10.10.2.91"
}

##variable "az" {
#     type = list
#     default = ["us-east-2a","us-east-2b"]
#}