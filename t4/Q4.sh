#!/bin/sh
REGION='us-east-1'
echo 'Enter default start time'
read myStartTime
echo 'Enter default stop time'
read myStopTime

echo 'Creating Start Rule.....'
default_start_rule_arn=aws events put-rule \
--name start-rule \
--region $REGION \
--schedule-expression "cron(0 ${myStartTime} ? * MON-FRI *)" \
--query 'RuleArn' \
--output text

echo 'Creating stop rule.....'
default_stop_rule_arn=aws events put-rule \
--name stop-rule \
--region $REGION \
--schedule-expression "cron(0 ${myStopTime} ? * MON-FRI *)" \
--query 'RuleArn' \
--output text
###add lambda functions here...............

#lambda start-func
echo -e "import boto3\nregion = '${REGION}'\ninstances = ['']\ndef lambda_handler(event, context):\n    print(event)\n    ec2 = boto3.client('ec2', region_name=region)\n    ec2.start_instances(InstanceIds=instances)\n    print 'Welcome starting your instances.....'" > start-func.py
zip tempzip.zip start-func.py
temp=$(aws lambda create-function --function-name start-func \
--runtime python3.6 \
--role arn:aws:iam::488599217855:role/FullAccess \
--handler start-func.lambda_handler \
--zip-file fileb://tempzip.zip \
--timeout 300 \
--region $REGION)
startFunctionArn=$(aws lambda get-function-configuration --function-name start-func --region $REGION --query "FunctionArn" --output text)
echo "Your start function is created!"
rm start-func.py tempzip.zip

echo 'Creating start Targets.....'
aws events put-targets \
--rule start-rule \
--targets file://target-start.json
rm target-start.json

#lambda stop-func
echo -e "import boto3\nregion = '${REGION}'\ninstances = ['i-0c88bb86fedfcc299']\ndef lambda_handler(event, context):\n    print(event)\n    ec2 = boto3.client('ec2', region_name=region)\n    ec2.stop_instances(InstanceIds=instances)\n    return 'GoodBye see you soon.....'" > stop-func.py
zip tempzip.zip stop-func.py
temp=$(aws lambda create-function --function-name stop-func \
--runtime python3.6 \
--role arn:aws:iam::488599217855:role/FullAccess \
--handler stop-func.lambda_handler \
--zip-file fileb://tempzip.zip \
--timeout 300 \
--region $REGION)
stopFunctionArn=$(aws lambda get-function-configuration --function-name stop-func --region $REGION --query "FunctionArn" --output text)
echo "Your stop function is created!"
rm stop-func.py tempzip.zip

echo 'Creating stop Targets...'
aws events put-targets \
--rule stop-rule \
--targets file://target-stop.json
rm target-stop.json
#lambda reset-func
echo -e "import boto3\na = ['MON', 'TUE', 'WED', 'THUR', 'FRI', 'SAT', 'SUN']\ndef lambda_handler(event, context):\n    client = boto3.client('events')\n    for i in range(0,7):\n        response = client.disable_rule(Name=a[i]+'-start-rule')\n        response = client.disable_rule(Name=a[i]+'-stop-rule')\n    response = client.enable_rule(Name='start-rule' )\n    response = client.enable_rule(Name='stop-rule')\n    return 'Hello from Lambda'" > reset-func.py
zip tempzip.zip reset-func.py
temp=$(aws lambda create-function --function-name reset-func \
--runtime python3.6 \
--role arn:aws:iam::488599217855:role/FullAccess \
--handler reset-func.lambda_handler \
--zip-file fileb://tempzip.zip \
--timeout 300 \
--region $REGION)
resetFunctionArn=$(aws lambda get-function-configuration --function-name reset-func --region $REGION --query "FunctionArn" --output text)
echo "Your reset function is created!"
rm reset-func.py tempzip.zip

#echo 'Creating Events...'

#aws events put-events \
#--entries file://putevents.json
echo 'adding permissions to lambda...'
aws lambda add-permission \
--function-name start-func \
--statement-id start-event \
--action 'lambda:InvokeFunction' \
--principal events.amazonaws.com \
--source-arn $default_start_rule_arn

aws lambda add-permission \
--function-name stop-func \
--statement-id stop-event \
--action 'lambda:InvokeFunction' \
--principal events.amazonaws.com \
--source-arn $default_stop_rule_arn

