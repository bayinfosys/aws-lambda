# AWS Lambda Function Terraform Module

This module configures AWS Lambda Functions for simple use cases:

+ deployment of an existing zip file to lambda
+ creation of an innvocation event source mapping (SQS, etc)
+ creation of a function alias for versioning

## Notes

Each module has an associated IAM policy document which describes
the resource access permissions of the lambda function.

A log group is created by the module with the same name as the function.

Metrics for `WARNING`, `ERROR`, and `CRITICAL` are created under a
`metric_namespace` variable. An `SNS` topic is also created for the alerts.

## References

+ https://docs.aws.amazon.com/lambda
+ https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html
+ https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html
