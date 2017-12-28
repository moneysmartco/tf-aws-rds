# RDS Module

Need to resolve this issue when we have `multi_az = true` then we don't need `availability_zone`, but will need to specify a zone when `multi_az = false`

```
availability_zone     = "${element(split(",", var.azs), 0)}"
multi_az              = "${var.rds_multi_az}"
```

### Notes

- `allow_connect_from_app` cannot be created on single `terraform apply` since `var.app_sg_ids` cannot be determinted at first. 
  Solution:
  - Let `app_sg_ids` as blank when including module and create your own `allow_connect_from_app`, or
  - Execute `terraform apply` with temporary comment tf-aws-rds block and then re-run uncomment block when resource of `var.app_sg_ids` is created

## Usage

Create a master RDS node

```
module "pg_master" {
  source = "git@github.com:moneysmartco/tf-aws-rds.git?ref=replica-setup"
  env                             = "${var.env}"
  azs                             = "${var.azs}"
  vpc_id                          = "${var.vpc_id}"
  private_subnet_ids              = "${var.private_subnet_ids}"
  project_name                    = "${var.app_name}"
  rds_engine_name                 = "${var.rds_engine_name}"
  rds_engine_version              = "${var.rds_engine_version}"
  rds_storage_size                = "${var.rds_storage_size}"
  rds_storage_engine_version      = "${var.rds_storage_engine_version}"
  rds_instance_type               = "${var.rds_instance_type}"
  rds_instance_name               = "${var.rds_instance_name}"
  rds_instance_db_name            = "${var.rds_instance_db_name}"
  rds_instance_root_user_name     = "${var.rds_instance_root_user_name}"
  rds_instance_root_user_password = "${var.rds_instance_root_user_password}"
  rds_monitoring_role_arn         = "${var.rds_monitoring_role_arn}"
  rds_multi_az                    = "${var.rds_multi_az}"
  app_sg_ids                      = "${module.ms_sg.app_sg_id}"
  rds_skip_final_snapshot         = "${var.rds_skip_final_snapshot}"
}
```

Create a read replica replica

```
module "pg_replica" {
  source = "git@github.com:moneysmartco/tf-aws-rds.git?ref=vx.x"
  env                             = "${var.env}"
  azs                             = "${var.azs}"
  vpc_id                          = "${var.vpc_id}"
  # You can set to use public_subnet or private
  #public_subnet_ids               = "${var.public_subnet_ids}"
  private_subnet_ids              = "${var.private_subnet_ids}"
  project_name                    = "${var.app_name}"
  rds_engine_name                 = "${var.rds_engine_name}"
  rds_engine_version              = "${var.rds_engine_version}"
  rds_storage_size                = "${var.rds_storage_size}"
  rds_storage_engine_version      = "${var.rds_storage_engine_version}"
  rds_instance_type               = "${var.rds_instance_type}"
  rds_instance_name               = "${var.rds_instance_name}"
  rds_instance_db_name            = "${var.rds_instance_db_name}"
  rds_instance_root_user_name     = "${var.rds_instance_root_user_name}"
  rds_instance_root_user_password = "${var.rds_instance_root_user_password}"
  rds_monitoring_role_arn         = "${var.rds_monitoring_role_arn}"
  rds_multi_az                    = "${var.rds_multi_az}"
  app_sg_ids                      = "${module.ms_sg.app_sg_id}"

  rds_master_id                   = "master-rds-name"
}
```

If you create the read replica then you have to run terraform apply twice - because the limit of AWS API (Just like when you create replica manually you will have to modify the replica RDS to set a different subnet or security group after you create it)
