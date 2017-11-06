/**
 * Subnet outputs
 */

// List of subnet ids
output "subnet_ids" {
  description = "List of subnet ids"
  value = ["${aws_subnet.subnet.*.id}"]
}
// List of route table ids
output "subnet_route_table_ids" {
  description = "List of route table ids"
  value = ["${aws_route_table.subnet.*.id}"]
}
// The list of availability zones of the VPC.
output "availability_zones" {
  value = ["${aws_subnet.subnet.*.availability_zone}"]
}
