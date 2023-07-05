output "subnet_arns" {
  value = [aws_subnet.this["public"].arn, aws_subnet.this["private"].arn]
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
