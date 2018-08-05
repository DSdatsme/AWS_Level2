#!/bin/bash
#this script is for resizing an image to 200X200px
#the image is uploaded to same bucket and a prefix is added as "resized_"

REGION='us-east-1'
lambdaFunctionName='compressIt'
echo "Enter the name of bucket"
read myBucket

echo "Creating bucket....."
aws s3 mb s3://${myBucket} \
--region $REGION

echo "Getting your lambda function ready....."
aws lambda create-function \
--function-name $lambdaFunctionName \
--region $REGION \
--runtime python3.7 \
--role arn:aws:iam::488599217855:role/FullAccess \
--timeout 300 \
--memory-size 512 \
--handler lambda_function.lambda_handler \
--code S3Bucket="darshitassig", S3Key="code.zip", S3ObjectVersion="Latest Version"

arn=$(aws lambda get-function-configuration \
--function-name $lambdaFunctionName \
--region $REGION \
--query '{FunctionArn:FunctionArn}' \
--output text)
echo "Adding events json file for S3 trigger"


#time to add permissions to lambda
aws lambda add-permission \
--function-name resize-img \
--region "us-east-1" \
--statement-id "1" \
--action "lambda:InvokeFunction" \
--principal s3.amazonaws.com \
--source-arn arn:aws:s3:::$myBucket 

#configuring trigger for lambda
echo "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\":"\""$arn"\"",
      \"Events\": [\"s3:ObjectCreated:*\"]
    }
  ]
}" > config.json

aws s3api put-bucket-notification-configuration \
--bucket $myBucket \
--notification-configuration file://config.json

rm config.json
echo "Your Image resizer is ready!"
