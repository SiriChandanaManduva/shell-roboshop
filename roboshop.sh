#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-037c2a44ad683ef21"
ZONE_ID="Z04821753TYSB7SH0NFJW"
DOMAIN_NAME="sirim.online"

for instance in $@
do 
instance_id=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

 if [ $instance == "frontend" ]; then
  IP=$(
    aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text
 )
   RECORD_NAME=$instance.$DOMAIN_NAME
 else
 IP=$(
    aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text
 )
    RECORD_NAME=$DOMAIN_NAME
 fi
 echo " IP address : $IP "

 aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID\
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "CNAME",
                "TTL": 1,
                "ResourceRecords": [{"Value": "'IP'"}]
            }
        }]
    }'



done



