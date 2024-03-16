#!/bin/bash
ACCOUNT_ID=$1
echo "calling generateCreds function to generate credentials for accoount in : $ACCOUNT_ID"

validateCmndStatus(){
  
  cmndsts=$1
  description=$2
  if [ $cmndsts -ne 0 ]; then 
    echo  "$description failure"
    exit 1
  else 
    echo "$description success"
  fi
}


generateCreds(){


AWS_ACCOUNT_ID=$1

echo "displaying account id in generateCredes method: $AWS_ACCOUNT_ID"

aws sts assume-role --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ROLE" --role-session-name "terraform-practice" > assume-role-output.txt
validateCmndStatus $? "role creation" 
export AWS_ACCESS_KEY_ID=`cat assume-role-output.txt | jq -c '.Credentials.AccessKeyId' | tr -d '"' | tr -d ' '`
validateCmndStatus $? "exporting access_key" 
export AWS_SECRET_ACCESS_KEY=`cat assume-role-output.txt | jq -c '.Credentials.SecretAccessKey' | tr -d '"' | tr -d ' '`
validateCmndStatus $? "exporting secret_key" 
export AWS_SESSION_TOKEN=`cat assume-role-output.txt | jq -c '.Credentials.SessionToken' | tr -d '"' | tr -d ' '`
validateCmndStatus $? "exporting session_token" 

}


generateCreds $ACCOUNT_ID





make $execute
#rm -f assume-role-output.txt

#export TF_VAR_account_id=$AWS_ACCOUNT_ID

