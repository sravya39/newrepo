# Creating VPC
resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = "false"
    enable_dns_hostnames = "false"
    tags = {
        Name = "test vpc"
    }
}
# Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
    vpc_id = aws_vpc.test_vpc.id
}

resource "aws_subnet" "pub_sub" {
    count = var.num_of_pub_subnets
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = "10.10.${count.index + 2}.0/24"
    vpc_id = aws_vpc.test_vpc.id
    map_public_ip_on_launch = "true"
    tags = {
        Name = "Public_sub_${count.index}"
    }
}


resource "aws_subnet" "pri_sub" {
    count = var.num_of_pri_subnets
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = "10.10.${count.index}.0/24"
    vpc_id = aws_vpc.test_vpc.id
    tags = {
        Name = "Private_sub_${count.index}"
    }
}

resource "aws_route_table" "pub_route_table" {
    vpc_id = aws_vpc.test_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.vpc_igw.id
  }
}

resource "aws_route_table_association" "pub_sub_assoc" {
    count = 2
    subnet_id = aws_subnet.pub_sub.*.id[count.index]
    route_table_id = aws_route_table.pub_route_table.id
}

#Bastion host
resource "aws_security_group" "sg_ssh_bastion" {
    vpc_id = aws_vpc.test_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "SG Bastion Host"
    }
}

resource "aws_security_group" "sg_inst_pri" {
    vpc_id = aws_vpc.test_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.sg_ssh_bastion.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "SG for Priv Instance"
    }
}

resource "aws_instance" "Bastion_host" {
    ami = "ami-0b614a5d911900a9b"
    instance_type = "t2.micro"
    key_name = "devops1"
    user_data = <<-EOF
                #!/bin/bash
                adduser admin
                echo "a_str0ng_p4SS"|passwd --stdin admin
                EOF
    subnet_id = aws_subnet.pub_sub.*.id[0]
    vpc_security_group_ids = [aws_security_group.sg_ssh_bastion.id]
    tags = {
        Name = "Bastion_Host"
    }
}

resource "aws_instance" "inst_priv" {
    ami = "ami-0b614a5d911900a9b"
    instance_type = "t2.micro"
    key_name = "devops1"
    subnet_id = aws_subnet.pri_sub.*.id[0]
    vpc_security_group_ids = [aws_security_group.sg_inst_pri.id]
    tags = {
        Name = "Priv_inst"
    }
}

resource "aws_eip" "eip_nat" {
    vpc = true
    associate_with_private_ip = var.eip_association_address
    tags = {
        Name = "eip_for_nat"
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    depends_on = [aws_eip.eip_nat]
    allocation_id = aws_eip.eip_nat.id
    subnet_id = aws_subnet.pub_sub.*.id[0]
    tags = {
        Name = "nat_gateway_cr"
    }
}

resource "aws_route_table" "pri_route_table" {
    vpc_id = aws_vpc.test_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "pri_sub_assoc" {
    subnet_id = aws_subnet.pri_sub.*.id[0]
    route_table_id = aws_route_table.pri_route_table.id
}