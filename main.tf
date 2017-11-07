#--------------------
# Subnet Groups
#--------------------
resource "aws_db_subnet_group" "rds_private_subnet" {
  name        = "${var.rds_instance_name}-private-subnet"
  description = "${var.rds_instance_name} RDS Private Subnet"
  subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
  tags {
    Name = "${var.rds_instance_name}-private-subnet"
  }
}

resource "aws_db_subnet_group" "rds_public_subnet" {
  count       = "${var.public_subnet_ids == "" ? 0 : 1}"
  name        = "${var.rds_instance_name}-public-subnet"
  description = "${var.rds_instance_name} RDS Public Subnet"
  subnet_ids  = ["${split(",", var.public_subnet_ids)}"]
  tags {
    Name = "${var.rds_instance_name}-public-subnet"
  }
}

#--------------------
# Params group
#--------------------
resource "aws_db_parameter_group" "rds_params" {
  name = "${var.rds_instance_name}-params"
  family = "${var.rds_engine_version}"

  ## Need to handle a default params here for mysql, postgresl, etc
}


#--------------------
# Security Group
#--------------------
resource "aws_security_group" "rds_sg" {
  name        = "${var.rds_instance_name}-${var.rds_engine_name}-rds-sg"
  description = "${var.rds_instance_name} ${var.rds_engine_name} rds secgroup"

  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.rds_instance_name}-${var.rds_engine_name}-rds-sg"
  }
}

resource "aws_security_group_rule" "allow_connect_from_app" {
  count           = "${var.app_sg_ids == "" ? 0 : 1}"
  type            = "ingress"
  from_port       = "${lookup(var.rds_ports, var.rds_engine_name)}"
  to_port         = "${lookup(var.rds_ports, var.rds_engine_name)}"
  protocol        = "tcp"
  security_group_id         = "${aws_security_group.rds_sg.id}"
  source_security_group_id  = ["${split(",", var.app_sg_ids)}"]
}


#-------------------------
# Master Node
#-------------------------
resource "aws_db_instance" "rds_master" {
  count                       = "${var.rds_multi_az ? 0 : 1}"
  storage_type                = "${var.rds_storage_type}"
  allocated_storage           = "${var.rds_storage_size}"
  engine                      = "${var.rds_engine_name}"
  engine_version              = "${var.rds_storage_engine_version}"
  instance_class              = "${var.rds_instance_type}"
  identifier                  = "${var.rds_instance_name}"
  name                        = "${var.rds_instance_db_name}"
  username                    = "${var.rds_instance_root_user_name}"
  password                    = "${var.rds_instance_root_user_password}"
  db_subnet_group_name        = "${aws_db_subnet_group.rds_private_subnet.name}"
  parameter_group_name        = "${aws_db_parameter_group.rds_params.name}"
  availability_zone           = "${element(split(",", var.azs), 0)}"
  multi_az                    = false
  publicly_accessible         = "${var.rds_publicly_accessible}"
  vpc_security_group_ids      = ["${aws_security_group.rds_sg.id}"]
  apply_immediately           = true
  backup_retention_period     = "${var.rds_backup_retention_period}"
  auto_minor_version_upgrade  = true
  skip_final_snapshot         = true
  final_snapshot_identifier   = "${var.rds_instance_name}-final-snapshot"
  monitoring_interval         = "${var.rds_monitoring_interval}"
  monitoring_role_arn         = "${var.rds_monitoring_role_arn}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"
  tags {
    Name        = "${var.rds_instance_name}",
    Project     = "${var.project_name}",
    Type        = "rds",
    Layer       = "rds",
    Environment = "${var.env}"
  }
}

resource "aws_db_instance" "rds_master_multi_az" {
  count                       = "${var.rds_multi_az ? 1 : 0}"
  storage_type                = "${var.rds_storage_type}"
  allocated_storage           = "${var.rds_storage_size}"
  engine                      = "${var.rds_engine_name}"
  engine_version              = "${var.rds_storage_engine_version}"
  instance_class              = "${var.rds_instance_type}"
  identifier                  = "${var.rds_instance_name}"
  name                        = "${var.rds_instance_db_name}"
  username                    = "${var.rds_instance_root_user_name}"
  password                    = "${var.rds_instance_root_user_password}"
  db_subnet_group_name        = "${aws_db_subnet_group.rds_private_subnet.name}"
  parameter_group_name        = "${aws_db_parameter_group.rds_params.name}"
  multi_az                    = "${var.rds_multi_az}"
  publicly_accessible         = "${var.rds_publicly_accessible}"
  vpc_security_group_ids      = ["${aws_security_group.rds_sg.id}"]
  apply_immediately           = true
  backup_retention_period     = "${var.rds_backup_retention_period}"
  auto_minor_version_upgrade  = true
  skip_final_snapshot         = true
  final_snapshot_identifier   = "${var.rds_instance_name}-final-snapshot"
  monitoring_interval         = "${var.rds_monitoring_interval}"
  monitoring_role_arn         = "${var.rds_monitoring_role_arn}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"
  tags {
    Name        = "${var.rds_instance_name}",
    Project     = "${var.project_name}",
    Type        = "rds",
    Layer       = "rds",
    Environment = "${var.env}"
  }
}

