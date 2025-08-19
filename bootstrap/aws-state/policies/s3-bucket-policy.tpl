{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid":"DenyInsecureTransport","Effect":"Deny","Principal":"*","Action":"s3:*",
      "Resource":[ "arn:${partition}:s3:::${bucket_name}", "arn:${partition}:s3:::${bucket_name}/*" ],
      "Condition":{"Bool":{"aws:SecureTransport":"false"}} },
    { "Sid":"DenyUnEncryptedObjectUploads","Effect":"Deny","Principal":"*","Action":"s3:PutObject",
      "Resource":"arn:${partition}:s3:::${bucket_name}/*",
      "Condition":{"Null":{"s3:x-amz-server-side-encryption":"true"}} }
  ]
}
