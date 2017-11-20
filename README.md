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