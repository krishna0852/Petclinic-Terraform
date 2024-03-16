#!/bin/bash
AWS_ACCOUNT_ID=$1
echo "calling account id: $AWS_ACCOUNT_ID"
aws sts assume-role --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ROLE" --role-session-name "terraform-practice" > assume-role-output.txt
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`

make $execute
#rm -f assume-role-output.txt

#export TF_VAR_account_id=$AWS_ACCOUNT_ID

