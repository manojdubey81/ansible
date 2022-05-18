#!bin/bash

if [ -z "$1" ]; then
  echo -e '\e[32mPlease Select Component Name to terminate!!\e[0m'
  exit 1
fi

COMPONENT="$1"

PVT_HZONE_ID=$(aws route53 list-hosted-zones-by-name \
                --dns-name roboshop.internal | jq '.HostedZone.Id' | sed -e 's/"//g' | sed -e 's/\/hostedzone\// /')

terminate_instance() {

  PVT_IP=$(aws ec2 describe-instances \
           --query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
           --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
           --output text | awk '{print$2}')

  if [ ! -z "${PVT_ID}" ]; then
     sed -e "s/IPADDRESS/${PVT_IP}/" -e "s/COMPONENT/${COMPONENT}-dev/" -e "s/ACTION/DELETE/" route53.json >/tmp/record.json
     aws route53 change-resource-record-sets --hosted-zone-id ${PVT_HOST_ZONE} --change-batch file:///tmp/record.json | jq
  fi

  INST_ID=$(aws ec2 describe-instances \
                 --filters "Name=tag:Name,Values=${COMPONENT}" \
                 --query "Reservations[*].Instances[*].InstanceId" \
                 --output text)

    if [ ! -z "${INST_ID}" ]; then
            aws ec2 terminate-instances --instance-ids ${INST_ID} | jq
    fi
}


if [ "$1" == "all" ]; then
  echo  "  "
  echo -e "\e[31mAll application termination started:-\e[0m"
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis dispatch ; do
    COMPONENT=$component
    terminate_instance
  done
  echo -e "---------------------------------------------------------------------------------\n"
else
  echo  "  "
  echo -e "\e[31m${COMPONENT} termination started:-\e[0m"
  terminate_instance
fi