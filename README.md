# RDS Module

Need to resolve this issue when we have `multi_az = true` then we don't need `availability_zone`, but will need to specify a zone when `multi_az = false`

```
availability_zone     = "${element(split(",", var.azs), 0)}"
multi_az              = "${var.rds_multi_az}"
```