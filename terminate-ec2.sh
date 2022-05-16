#!bin/bash

if [ -z "$1" ]; then
  echo -e '\e[32mPlease Select Component Name to terminate!!\e[0m'
  exit 1
fi

COMPONENT="$1"

terminate_instance() {
  INST_ID=$(aws ec2 describe-instances \
               --filters "Name=tag:Name,Values=${COMPONENT}" \
               --query "Reservations[*].Instances[*].InstanceId" \
               --output text)

  if [ ! -z "${INST_ID}" ]; then
          aws ec2 describe-instances --instance-ids ${INST_ID}
  fi
}

if [ "$1" == "all" ]; then
  echo  "  "
  echo -e "\e[31mAll application termination started:-\e[0m"
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq radis dispatch ; do
    COMPONENT=$component
    terminate_instance
  done
  echo -e "---------------------------------------------------------------------------------\n"
else
  echo  "  "
  echo -e "\e[31m${COMPONENT} termination started:-\e[0m"
  terminate_instance
fi