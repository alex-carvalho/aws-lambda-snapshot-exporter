### Project to automate RDS snapshot export to S3

- AWS Lambda in Golang
- AWS infrastructure built using terraform

----
Terraform output:
 - IAM Role Arn
 - KMS Key Id

Payload to test lambda
```
{  
  "region": "",
  "s3BucketName": "",
  "s3BucketPrefix": "",
  "instanceIdentifier": "",
  "iamRoleArn": "",
  "kmsKeyId": ""
} 
```