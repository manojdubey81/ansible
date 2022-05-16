#!bin/bash


if [ -z "$1" ]; then
  echo -e '\e[32mPlease Select Component Name to display the details!!\e[0m'
  exit 1
fi


COMPONENT="$1"


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
               --output text | awk '{print$2}')

  if [ ! -z "${PUBLIC_IP}" ]; then
          echo  "  "
          echo -e "\e[33mName = ${INST_NAME}\e[0m, \e[32mPublicIP = ${PUBLIC_IP}\e[0m, \e[33mPrivateIp = ${PRIVATE_IP}\e[0m"
  fi
}

if [ "$1" == "all" ]; then
  echo  "  "
  echo -e "\e[31mAll application running instance are with below details:-\e[0m"
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq radis dispatch ; do
    COMPONENT=$component
    display_instance
  done
  echo -e "---------------------------------------------------------------------------------\n"
else
  echo  "  "
  echo -e "\e[31m${COMPONENT} running instance is with below details:-\e[0m"
  display_instance
fi