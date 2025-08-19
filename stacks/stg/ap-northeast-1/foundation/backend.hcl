bucket = "tfstate-yourorg-STG"
key = "stg/ap-northeast-1/foundation/terraform.tfstate"
region = "ap-northeast-1"
dynamodb_table = "tf-locks"
encrypt = true
kms_key_id = "arn:aws:kms:ap-northeast-1:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
