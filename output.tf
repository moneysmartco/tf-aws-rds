output "rds_url" {
  value = "${aws_db_instance.rds_master.address}"
}

output "rds_multi_az_url" {
  value = "${aws_db_instance.rds_master_multi_az.address}"
}
