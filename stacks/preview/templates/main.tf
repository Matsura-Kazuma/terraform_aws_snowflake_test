terraform { required_version="~> 1.8" backend "s3" {} }
resource "null_resource" "preview" { triggers = { pr = "true" } }
