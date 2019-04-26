variable "env"                                  {}
variable "azs"                                  {}
variable "vpc_id"                               {}
variable "public_subnet_ids"                    {
  default = ""
}
variable "private_subnet_ids"                   {}
variable "project_name"                         {}

variable "rds_engine_name"                      {
  default = "mysql"
}
variable "rds_engine_version"                   {
  default = "mysql5.6"
}
variable "rds_storage_engine_version"           {
  default = "5.6.35"
}
variable "rds_storage_type"                     {
  default = "gp2"
}
variable "rds_storage_size"                     {
  default = 50
}

variable "rds_instance_name"                    {}
variable "rds_instance_type"                    {
  default = "db.t2.micro"
}

variable "rds_instance_db_name"                 {}
variable "rds_instance_root_user_name"          {
  default = "root"
}
variable "rds_instance_root_user_password"      {}

variable "rds_multi_az"                         {
  default = false
}

variable "rds_backup_retention_period"          {
  default = 30
}

variable "rds_publicly_accessible"              {
  default = false
}

variable "rds_ports"                            {
  type    = "map"
  default = {
    "mysql"     = 3306
    "postgres"  = 5432
  }
}

variable "app_sg_ids"                           {
  default = ""
}

variable "rds_monitoring_interval"              {
  default = 30
}

variable "rds_monitoring_role_arn"              {}

variable "copy_tags_to_snapshot"                {
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

variable "tags" {
  description = "Tagging resources with default values"
  default = {
    "Country" = ""
    "Environment" = ""
    "Repository" = ""
    "Owner" = ""
    "Department" = ""
    "Team" = "shared"
    "Product" = "common"
    "Project" = "common"
    "Stack" = ""
  }
}
