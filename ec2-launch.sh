#!/bin/bash
#
#aws ec2 request-spot-instances --instance-count 1 --type "persistent" --launch-specification file://spot.json --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=name,Value=frontend}]" | jq
#
 #aws ec2 describe-instances --filters "Name=tag:Name,Values=frontend" | jq .Reservations[].Instances[].State.Name="running" | sed 's/"//g'
if [ -z "$1" ]; then
  echo -e "\e[1;31mInput is missing\e[0m"
  exit 1
fi

COMPONENT=$1  # first argument
TEMP_ID="lt-07e05017fc2ec8348"
TEMP_VER=5
ZONE_ID=Z04776882HVJTCOQ8IAU3
CREATE_INSTANCE()
{

aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep -E 'running|stopped' &>/dev/null
if [ $? -eq -0 ]; then
  echo -e "\e[1;33minstance already there\e[0m"
else

aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]" "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq
  fi


IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=frontend" | jq .Reservations[].Instances[].PrivateIpAddress | sed 's/"//g' | grep -v null)
# Update the DNS Record
sed -e "s/IPADDRESS/${IPADDRESS}/" -e "s/COMPONENT/${COMPONENT}/" record.json >/tmp/record.json
aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:////tmp/record.json | jq

}

if [ "$COMPONENT" == "all" ]; then
  for comp in frontend mongodb catalogue cart ; do
    COMPONENT=$comp
    CREATE_INSTANCE
  done

  else
   CREATE_INSTANCE
fi
