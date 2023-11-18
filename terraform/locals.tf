locals {
  mappings = {
    S3Buckets = {
      us-east-1 = {
        Bucket = "aws-fullstack-template"
        SeederFunctionBucket = "fsd-aws-wildrydes-us-east-1"
      }
      us-west-2 = {
        Bucket = "aws-fullstack-template-us-west-2"
        SeederFunctionBucket = "fsd-aws-wildrydes-us-west-2"
      }
      eu-central-1 = {
        Bucket = "aws-fullstack-template-eu-central-1"
        SeederFunctionBucket = "fsd-aws-wildrydes-eu-central-1"
      }
      eu-west-1 = {
        Bucket = "aws-fullstack-template-eu-west-1"
        SeederFunctionBucket = "fsd-aws-wildrydes-eu-west-1"
      }
    }
    Constants = {
      AppKeys = {
        SeedRepository = "https://s3.amazonaws.com/aws-fullstack-template/goals-webapp.zip"
      }
      S3Keys = {
        ListGoalsCode = "functions/ListGoals.zip"
        CreateGoalCode = "functions/CreateGoal.zip"
        DeleteGoalCode = "functions/DeleteGoal.zip"
        UpdateGoalCode = "functions/UpdateGoal.zip"
        GetGoalCode = "functions/GetGoal.zip"
        UpdateConfigCode = "functions/UpdateConfig.zip"
        SeederFunctionCode = "aws-serverless-codecommit-seeder.zip"
        PythonLambdaLayer = "functions/PythonLambdaLayer.zip"
        DeleteBucketsCode = "functions/DeleteBuckets.zip"
      }
    }
  }
  IADRegion = data.aws_region.current.name == "us-east-1"
}

