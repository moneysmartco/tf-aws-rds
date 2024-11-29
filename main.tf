locals {
  # env tag in map structure
  env_tag = {
    Environment = var.env
  }

  # rds instance name tag in map structure
  rds_instance_name_tag = {
    Name = var.rds_instance_name
  }

  # rds security group name tag in map structure
  rds_security_group_name_tag = {
    Name = "${var.rds_instance_name}-${var.rds_engine_name}-rds-sg"
  }

  # rds subnet group name tag in map structure
  rds_private_subnet_group_name_tag = {
    Name = "${var.rds_instance_name}-private-subnet"
  }
  rds_public_subnet_group_name_tag = {
    Name = "${var.rds_instance_name}-public-subnet"
  }

  #------------------------------------------------------------
  # variables that will be mapped to the various resource block
  #------------------------------------------------------------

  # rds instance tags
  aws_db_instance_tags = merge(var.tags, local.env_tag, local.rds_instance_name_tag)

  # rds security group name tags
  aws_security_group_tags = merge(var.tags, local.env_tag, local.rds_security_group_name_tag)

  # rds private subnet group name tags
  private_subnet_group_tags = merge(
    var.tags,
    local.env_tag,
    local.rds_private_subnet_group_name_tag,
  )

  # rds public subnet group name tags
  public_subnet_group_tags = merge(
    var.tags,
    local.env_tag,
    local.rds_public_subnet_group_name_tag,
  )
}

#--------------------
# Subnet Groups
#--------------------
resource "aws_db_subnet_group" "rds_private_subnet" {
  count       = var.private_subnet_ids == "" ? 0 : 1
  name        = "${var.rds_instance_name}-private-subnet"
  description = "${var.rds_instance_name} RDS Private Subnet"
  subnet_ids  = split(",", var.private_subnet_ids)

  lifecycle {
    create_before_destroy = true
  }

  tags = local.private_subnet_group_tags
}

resource "aws_db_subnet_group" "rds_public_subnet" {
  count       = var.public_subnet_ids == "" ? 0 : 1
  name        = "${var.rds_instance_name}-public-subnet"
  description = "${var.rds_instance_name} RDS Public Subnet"
  subnet_ids  = split(",", var.public_subnet_ids)

  lifecycle {
    create_before_destroy = true
  }

  tags = local.public_subnet_group_tags
}

#--------------------
# Params group
#--------------------
resource "aws_db_parameter_group" "rds_params" {
  name   = "${var.rds_instance_name}-params"
  family = var.rds_engine_version

  lifecycle {
    create_before_destroy = true
  }
  ## Need to handle a default params here for mysql, postgresl, etc
}

#--------------------
# Security Group
#--------------------
resource "aws_security_group" "rds_sg" {
  name        = "tf-${var.rds_instance_name}-${var.rds_engine_name}-rds-sg"
  description = "${var.rds_instance_name} ${var.rds_engine_name} rds secgroup"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.aws_security_group_tags
}

resource "aws_security_group_rule" "allow_connect_from_app" {
  count                    = length(compact(split(",", var.app_sg_ids)))
  type                     = "ingress"
  from_port                = var.rds_ports[var.rds_engine_name]
  to_port                  = var.rds_ports[var.rds_engine_name]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = element(split(",", var.app_sg_ids), count.index)

  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------
# Master Node
#-------------------------
resource "aws_db_instance" "rds_master" {
  count                      = var.rds_create && !var.rds_multi_az ? 1 : 0
  storage_type               = var.rds_storage_type
  allocated_storage          = var.rds_storage_size
  max_allocated_storage      = var.rds_max_storage_size
  storage_encrypted          = var.rds_storage_encrypted
  engine                     = var.rds_engine_name
  engine_version             = var.rds_storage_engine_version
  instance_class             = var.rds_instance_type
  identifier                 = var.rds_instance_name
  db_name                    = var.rds_instance_db_name
  username                   = var.rds_instance_root_user_name
  password                   = var.rds_instance_root_user_password
  db_subnet_group_name       = var.rds_master_id == "" ? aws_db_subnet_group.rds_private_subnet[0].name : ""
  parameter_group_name       = var.custom_parameter_group_name == null ? aws_db_parameter_group.rds_params.name : var.custom_parameter_group_name
  availability_zone          = element(split(",", var.azs), 0)
  multi_az                   = false
  publicly_accessible        = var.rds_publicly_accessible
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  apply_immediately          = true
  backup_retention_period    = var.rds_master_id == "" ? var.rds_backup_retention_period : 0
  auto_minor_version_upgrade = true
  skip_final_snapshot        = var.rds_skip_final_snapshot
  final_snapshot_identifier  = "${var.rds_instance_name}-final-snapshot"
  monitoring_interval        = var.rds_monitoring_interval
  monitoring_role_arn        = var.rds_monitoring_role_arn
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  #snapshot_identifier        = var.snapshot_identifier
  deletion_protection        = var.deletion_protection
  ca_cert_identifier         = var.rds_ca_cert_identifier
  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period

  # Build a read replica from another RDS
  # replicate_source_db = var.rds_master_id

  lifecycle {
    create_before_destroy = true
  }

  tags = local.aws_db_instance_tags
}

resource "aws_db_instance" "rds_master_multi_az" {
  count                      = var.rds_create && var.rds_multi_az ? 1 : 0
  storage_type               = var.rds_storage_type
  allocated_storage          = var.rds_storage_size
  max_allocated_storage      = var.rds_max_storage_size
  storage_encrypted          = var.rds_storage_encrypted
  engine                     = var.rds_engine_name
  engine_version             = var.rds_storage_engine_version
  instance_class             = var.rds_instance_type
  identifier                 = var.rds_instance_name
  db_name                    = var.rds_instance_db_name
  username                   = var.rds_instance_root_user_name
  password                   = var.rds_instance_root_user_password
  db_subnet_group_name       = var.rds_master_id == "" ? aws_db_subnet_group.rds_private_subnet[0].name : ""
  parameter_group_name       = var.custom_parameter_group_name == null ? aws_db_parameter_group.rds_params.name : var.custom_parameter_group_name
  multi_az                   = true
  publicly_accessible        = var.rds_publicly_accessible
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  apply_immediately          = true
  backup_retention_period    = var.rds_master_id == "" ? var.rds_backup_retention_period : 0
  auto_minor_version_upgrade = true
  skip_final_snapshot        = var.rds_skip_final_snapshot
  final_snapshot_identifier  = "${var.rds_instance_name}-final-snapshot"
  monitoring_interval        = var.rds_monitoring_interval
  monitoring_role_arn        = var.rds_monitoring_role_arn
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  #snapshot_identifier        = var.snapshot_identifier
  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  deletion_protection        = var.deletion_protection
  ca_cert_identifier         = var.rds_ca_cert_identifier
  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period

  # Build a read replica from another RDS
  # replicate_source_db = var.rds_master_id



  tags = local.aws_db_instance_tags
}

