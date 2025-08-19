{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid":"TagGuard","Effect":"Deny","Action":"*","Resource":"*",
      "Condition":{"StringNotEquals":{"aws:ResourceTag/Project":"${project_tag_value}"}} },
    { "Sid":"RegionGuard","Effect":"Deny","Action":"*","Resource":"*",
      "Condition":{"StringNotEquals":{"aws:RequestedRegion":"${requested_region}"}} }
  ]
}
