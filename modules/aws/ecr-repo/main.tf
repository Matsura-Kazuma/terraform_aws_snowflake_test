resource "aws_ecr_repository" "this" {
  name = var.name
  image_scanning_configuration { scan_on_push = var.image_scan_on_push }
  image_tag_mutability = "IMMUTABLE"
  tags = var.tags
}
