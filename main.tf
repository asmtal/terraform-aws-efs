module "label" {
  source     = "r0ck40k/label/generic"
  version    = "0.1.0"
  context    = var.context
  attributes = ["storage", "efs", var.name]
}

resource "aws_efs_file_system" "this" {
  tags = {
    Name = module.label.id
  }
  kms_key_id = var.kms_arn
  encrypted  = true
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}
module "security-group" {
  source             = "r0ck40k/security-group/aws"
  version            = "0.1.0"
  description        = "EFC Access group for volume ${var.name}"
  allow_self_ingress = true
  context            = var.context
  egress             = {}
  ingress = {
    tcp = {
      to          = 2049
      from        = 2049
      protocol    = "tcp"
      cidr_blocks = [var.vpc.cidr]
    }
    udp = {
      to          = 2049
      from        = 2049
      protocol    = "udp"
      cidr_blocks = [var.vpc.cidr]

    }
  }
  name   = var.name
  vpc_id = var.vpc.id
}

resource "aws_efs_mount_target" "this" {
  for_each        = { for x in var.vpc.subnet_ids : x => x }
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.key
  security_groups = [module.security-group.id]
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
  for_each       = var.users
  tags = {
    name = each.key
  }
  posix_user {
    gid = each.value.gid
    uid = each.value.uid
  }

  root_directory {
    path = each.value.path
    creation_info {
      owner_gid   = each.value.gid
      owner_uid   = each.value.uid
      permissions = 755
    }
  }
}
