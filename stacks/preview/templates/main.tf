terraform {
  required_version = "~> 1.8"
  backend "s3" {}
}

# 日本語コメント: プレビュー環境の最小リソース例（必要に応じて差し替え）
resource "null_resource" "preview" {
  triggers = {
    pr = "true"
  }
}
