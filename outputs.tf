output "filesystem_id" {
  value      = aws_efs_file_system.this.id
  depends_on = [aws_efs_mount_target.this]
}

output "access_points" {
  value = aws_efs_access_point.this
}

output "security_group" {
  value = module.security-group.id
}
