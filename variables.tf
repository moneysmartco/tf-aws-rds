

variable "env" {
}

variable "azs" {
}

variable "vpc_id" {
}

variable "public_subnet_ids" {
  default = ""
}

variable "private_subnet_ids" {
}

variable "project_name" {
}

variable "rds_engine_name" {
  default = "mysql"
}

variable "deletion_protection" {
  default = "true"
}

variable "rds_ca_cert_identifier" {
  default = "rds-ca-2019"
}

variable "rds_engine_version" {
  default = "mysql5.6"
}

variable "rds_storage_engine_version" {
  default = "5.6.35"
}

variable "rds_storage_type" {
  default = "gp2"
}

# minimum storage allocation is 20gib
variable "rds_storage_size" {
  default = 50
}

# maximum storage allocation for autoscaling is 1000gib
variable "rds_max_storage_size" {
  default = 100
}

variable "rds_storage_encrypted" {
  default = false
}

variable "rds_instance_name" {
}

# DB Instance class db.t2.micro does not support encryption at rest
variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_instance_db_name" {
}

variable "rds_instance_root_user_name" {
  default = "root"
}

variable "rds_instance_root_user_password" {
}

variable "rds_multi_az" {
  default = false
}

variable "create_rds" {
  default = false
}

variable "rds_backup_retention_period" {
  default = 30
}

variable "rds_allow_major_version_upgrade" {
  default = true
}

variable "rds_publicly_accessible" {
  default = false
}

variable "rds_ports" {
  type = map(string)
  default = {
    "mysql"    = 3306
    "postgres" = 5432
  }
}

variable "app_sg_ids" {
  default = ""
}

variable "rds_monitoring_interval" {
  default = 30
}

variable "rds_monitoring_role_arn" {
}

variable "copy_tags_to_snapshot" {
  default = true
}

 variable "snapshot_identifier" {
   default = ""
 }

variable "rds_master_id" {
  description = "Create a read replica from this RDS master id"
  default     = ""
}

variable "rds_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  default     = true
}

variable "custom_parameter_group_name" {
  type = string
  default = null
  
}

variable "rds_performance_insights_enabled" {
  default    = false
}

variable "rds_performance_insights_retention_period" {
  default = 7
}

variable "tags" {
  description = "Tagging resources with default values"
  default = {
    "Name"        = ""
    "Country"     = ""
    "Environment" = ""
    "Repository"  = ""
    "Owner"       = ""
    "Department"  = ""
    "Team"        = "shared"
    "Product"     = "common"
    "Project"     = "common"
    "Stack"       = ""
  }
}

