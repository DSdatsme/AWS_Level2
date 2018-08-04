#!/bin/sh
days=( [0]="MON" [1]="TUE" [2]="WED" [3]="THUR" [4]="FRI" [5]="SAT" [6]="SUN")
for ((i=0;i<7;i++))
do
	aws events put-targets \
	--rule ${days[i]}-start-rule \
	--targets file://target-start.json

	aws events put-targets \
	--rule ${days[i]}-stop-rule \
	--targets file://target-stop.json
	
	aws lambda add-permission \
	--function-name start-func \
	--statement-id ${days[i]}-start-event \
	--action 'lambda:InvokeFunction' \
	--principal events.amazonaws.com \
	--source-arn arn:aws:events:us-east-1:488599217855:rule/${days[i]}-start-rule

	aws lambda add-permission \
	--function-name stop-func \
	--statement-id ${days[i]}-stop-event \
	--action 'lambda:InvokeFunction' \
	--principal events.amazonaws.com \
	--source-arn arn:aws:events:us-east-1:488599217855:rule/${days[i]}-stop-rule



done
