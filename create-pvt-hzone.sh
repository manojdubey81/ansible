#!/bin/bash

if [ -z "$1" ]; then
  echo -e '\e[32mPlease pass private hosted zone name too!\e[0m'
  exit 1
fi

COMPONENT=$1

VPC_ID=$(aws ec2 describe-vpcs | jq '.Vpcs[].VpcId' | sed -e 's/"//g')
PVT_HZ=$(aws route53 list-hosted-zones-by-name | jq '.HostedZone.Id' | sed -e 's/"//g' | sed -e 's/\/hostedzone\// /')


#PVT_HOST_ZONE=$PVT_HZ.HostedZone.Id.replace("/hostedzone/","")


echo "---------------------------------"
echo "Pvt_hosted-zone :" "${PVT_HZ}"