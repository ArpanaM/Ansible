#!/bin/bash
#
#aws ec2 request-spot-instances --instance-count 1 --type "persistent" --launch-specification file://spot.json --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=name,Value=frontend}]" | jq
#

TEMP_ID="ami-0f3c7d07486cad139"
TEMP_VER=3

aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER}| jq