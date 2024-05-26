locals {
  retain_max_images   = 5
  repository_provided = var.image_repository_name != null
  repository_url      = var.image_repository_name != null ? data.aws_ecr_repository.provided[0].repository_url : aws_ecr_repository.dedicated[0].repository_url
}

data "aws_ecr_repository" "provided" {
  count = local.repository_provided ? 1 : 0
  name  = var.image_repository_name
}



resource "aws_ecr_repository" "dedicated" {
  count                = local.repository_provided ? 0 : 1
  name                 = lower(local.qualified_name)
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = local.encryption_key.arn
  }
}

resource "aws_ecr_lifecycle_policy" "lambda" {
  count      = local.repository_provided ? 0 : 1
  repository = aws_ecr_repository.dedicated[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "retain last ${local.retain_max_images} image(s)"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = local.retain_max_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
