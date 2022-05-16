#!/bin/bash

if [ -z "$1" ]; then
  echo -e '\e[32mPlease Select Component Name in first occurrence in command line after script!!\e[0m'
  exit 1
fi

if [ -z "$2" ]; then
  echo -e '\e[32mProvide Instances Type in second occurrence in after component name\e[0m  \e[34mi.e. t2.micro etc..\e[0m'
  exit 2
fi


COMPONENT="$1"
INST_TYPE="$2"

INST_NAME=$(aws ec2 describe-instances \
             --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
             --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
             --output text | awk '{print$1}')

PRIVATE_IP=$(aws ec2 describe-instances \
             --query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
             --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
             --output text | awk '{print$2}')

PUBLIC_IP=$(aws ec2 describe-instances \
             --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
             --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
             --output text | awk '{print$2}')


if [ ! -z "${PRIVATE_IP}" ]; then
    echo  "  "
    echo -e "\e[33mThis Instance is already running, Please see below instance details:-\e[0m"
    echo -e "\e[34mName Tag = ${INST_NAME}, PublicIP = ${PUBLIC_IP}, PrivateIp = ${PRIVATE_IP}\e[0m"
    echo -e "---------------------------------------------------------------------------------\n"
    exit 3
else
    echo  "  "
    echo -e "\e[33mRequested Instance is ${COMPONENT}\e[0m"
    echo -e "----------------------------------------------------\n"
fi



SG_ID=$(aws ec2 describe-security-groups \
          --filters Name=group-name,Values=allow-all-sgp \
            | jq '.SecurityGroups[].GroupId' \
            | sed -e 's/"//g')

if [ -z "{SG_ID}" ] ; then
    echo -e "\e[1;33m Security Group allow-all-sgp does not exist"
    echo -e "----------------------------------------------------\n"
    exit 4
else
    echo -e "\e[1;32mSecurity GroupId = ${SG_ID}\e[0m"
    echo -e "----------------------------------------------------\n"
fi

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" \
        | jq '.Images[].ImageId' | sed -e 's/"//g')

if [ -z "${AMI_ID}" ]; then
    echo -e "\e[1;31mUnable to find Image AMI_ID\e[0m"
    echo -e "----------------------------------------------------\n"
    exit 5
else
    echo -e "\e[1;32mAMI ID = ${AMI_ID}\e[0m"
    echo -e "----------------------------------------------------\n"
fi

create_ec2()  {
  check_instance_existance
  if [ ! -z "${PRIVATE_IP}" ]; then
        echo  "  "
        echo -e "\e[33mThis Instance is already running, Please see below instance details:-\e[0m"
        echo -e "\e[34mName Tag = ${INST_NAME}, PublicIP = ${PUBLIC_IP}, PrivateIp = ${PRIVATE_IP}\e[0m"
        echo -e "---------------------------------------------------------------------------------\n"
    else
        echo  "  "
        echo -e "\e[33mRequested Instance is ${COMPONENT}\e[0m"
        echo -e "----------------------------------------------------\n"
        assign_ec2
    fi
}

check_instance_existance(){
  INST_NAME=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$1}')

  PRIVATE_IP=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$2}')

  PUBLIC_IP=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$2}')
}

assign_ec2()  {
  aws ec2 run-instances \
        --image-id "${AMI_ID}" \
        --instance-type "${INST_TYPE}" \
        --security-group-ids "${SG_ID}" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" \
        | jq
}


if [ "$1" == "all" ]; then
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq radis dispatch ; do
    COMPONENT=$component
    create_ec2
  done
else
  assign_ec2
fi


display_instance() {
  INST_NAME=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$1}')

  PRIVATE_IP=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$2}')

  PUBLIC_IP=$(aws ec2 describe-instances \
               --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" \
               --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${COMPONENT}" \
               --output text | awk '{print$2}'

  if [ ! -z "${PRIVATE_IP}" ]; then
          echo  "  "
          echo -e "\e[33mThis Instance is already running, Please see below instance details:-\e[0m"
          echo -e "\e[34mName Tag = ${INST_NAME}, PublicIP = ${PUBLIC_IP}, PrivateIp = ${PRIVATE_IP}\e[0m"
          echo -e "---------------------------------------------------------------------------------\n"
  fi
}

if [ "$1" == "all" ]; then
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq radis dispatch ; do
    COMPONENT=$component
    display_instance
  done
fi