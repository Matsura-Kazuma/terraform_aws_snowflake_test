{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect":"Allow","Action":[
      "ec2:Describe*","rds:Describe*","s3:Get*","s3:List*","iam:Get*","iam:List*",
      "logs:Describe*","cloudwatch:Describe*","cloudformation:List*","ecr:Describe*",
      "route53:List*"
    ],"Resource":"*" },
    { "Effect":"Deny","Action":"*","Resource":"*",
      "Condition":{"StringNotEquals":{"aws:RequestedRegion":"${requested_region}"}} }
  ]
}
