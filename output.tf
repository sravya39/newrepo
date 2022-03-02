output "vpc_id" {
    description = "Generated vpc id"
    value = aws_vpc.test_vpc.id
}

output "bastion_instance_id" {
    value = aws_instance.Bastion_host.id
}

output "pri_instance_id" {
    value = aws_instance.inst_priv.id
}

output "nat_gateway_id" {
    value = aws_nat_gateway.nat_gateway.id
}