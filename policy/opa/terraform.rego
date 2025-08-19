package terraform.security

default deny = []
required_tags := {"Project","Owner","Environment","DataClass"}

deny[msg] { input.resource_type == "aws_s3_bucket"; input.values.acl == "public-read"; msg := "S3 バケットの public-read は禁止です" }

deny[msg] { input.resource_type == "aws_s3_bucket"; not input.values.server_side_encryption_configuration; msg := "S3 バケットにサーバーサイド暗号化が設定されていません" }

deny[msg] { input.values.tags; some t; required_tags[t]; not input.values.tags[t]; msg := sprintf("必須タグ '%s' が不足しています", [t]) }

deny[msg] { input.resource_type == "aws_security_group_rule"; input.values.cidr_blocks[_] == "0.0.0.0/0"; input.values.from_port == 22; input.values.to_port == 22; msg := "0.0.0.0/0 への 22/tcp 開放は禁止です" }
