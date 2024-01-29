resource "aws_ecr_repository" "foo" {

  for_each = toset(var.ecr-name)
  name                 = each.key
  image_tag_mutability = var.image_tag

  image_scanning_configuration {
    scan_on_push = true  #image will scan after push
  }
  tags=var.tags
}


resource "aws_ecr_lifecycle_policy" "foopolicy" {
  for_each = toset(var.ecr-name)
  repository = each.key

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "keep last 5 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"], 
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}