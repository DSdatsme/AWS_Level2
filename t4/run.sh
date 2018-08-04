#!/bin/sh
days=( [0]="MON" [1]="TUE" [2]="WED" [3]="THUR" [4]="FRI" [5]="SAT" [6]="SUN")
for ((i=0;i<7;i++))
do
	echo 'Enter Start Time..'
	read starttime
	echo 'Enter End Time'
	read endtime

	aws events put-rule \
	--name ${days[i]}-start-rule \
	--schedule-expression "cron(0 ${starttime} ? * ${days[i]} *)"

	aws events put-rule \
	--name ${days[i]}-stop-rule \
	--schedule-expression "cron(0 ${endtime} ? * ${days[i]} *)"

done

bash rule-to-func.sh
