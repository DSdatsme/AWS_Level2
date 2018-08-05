#this script is for resizing an image to 200X200px
#the image is uploaded to same bucket and a prefix is added as "resized_"
#the python code and the 'Pillo' library to resize image is inside the S3 bucket named "darshitassig"
REGION='us-east-1'
echo "Enter the name of bucket"
read myBucket
echo "Enter function name"
read myLambda
echo "Creating bucket....."
aws s3 mb s3://${myBucket} \
--region $REGION

echo "Creating lambda function....."
aws lambda create-function --function-name $myLambda \
--runtime python3.7 \
--role arn:aws:iam::488599217855:role/FullAccess \
--handler lambbda_function.lambda_handler \
--code S3Bucket="darshitassig",S3Key="code.zip",S3ObjectVersion="Latest Version" \
--memory-size 512 \
--timeout 300 \
--region $REGION

#time to add permissions to lambda
aws lambda add-permission \
--function-name $myLambda \
--region $REGION \
--statement-id "1" \
--action "lambda:InvokeFunction" \
--principal s3.amazonaws.com \
--source-arn arn:aws:s3:::$myBucket

arn=$(aws lambda get-function-configuration \
--function-name $myLambda \
--region $REGION \
--query '{FunctionArn:FunctionArn}' \
--output text)

#configuring trigger for lambda
echo "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\":"\""$arn"\"",
      \"Events\": [\"s3:ObjectCreated:*\"]
    }
  ]
}" > config.json

#adding trigger event(config.json) to S3
aws s3api put-bucket-notification-configuration \
--bucket $myBucket \
--notification-configuration file://config.json


rm config.json

echo "Your Image resizer is ready!"

