#!/bin/bash

#############################
# Configure AWS credentials #
#############################

echo Please enter the credentials for source account :
echo " "
aws configure --profile user01

echo " "

echo Please enter the credentials for target account :
echo " "
aws configure --profile user02

echo " "

#####################
# Create AMI of EC2 #
#####################

read -p "Insert the instance ID :"$'\n' instance_id
echo " "
read -p "Type the name of AMI:"$'\n' ami_name
echo " "
read -p "Type in the description of AMI: "$'\n' description
echo " "

AMI_ID=$(aws ec2 create-image --instance-id $instance_id --name "$ami_name" --description "$description" --output text --profile user01)

###########################################################
# Wait command to bridge time gap until AMI become active #
###########################################################

echo "Waiting until AMI becomes active..."$'\n'

aws ec2 wait image-available --filters "Name=name,Values=$ami_name" --profile user01

echo " "

echo "AMI is active!"$'\n'
################################################
# Fetch aws account number from target account #
################################################

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile user02)

##########################
# Modify AMI permissions #
##########################

# FETCH AMI ID
AMI_ID=$(aws ec2 describe-images --image-ids $AMI_ID --query 'Images[0].ImageId' --output text --profile user01)

# MODIFY PERMISSION
aws ec2 modify-image-attribute --image-id $AMI_ID --launch-permission "Add=[{UserId=$AWS_ACCOUNT_ID}]" --profile user01


#######################
# Create new key-pair #
#######################

echo "Creation of new key-pair"$'\n'

read -p "Type in the name of key-pair: "$'\n' keyPair

OSVERSION=`cat /etc/os-release | sed -n 1p`

if [[ "$OSVERSION" == *"Amazon"* ]]
then 
    aws ec2 create-key-pair --key-name "$keyPair" --query 'KeyMaterial' --output text > /home/cloudshell-user/$keyPair.pem  --profile user02
else
    aws ec2 create-key-pair --key-name "$keyPair" --query 'KeyMaterial' --output text > /root/$keyPair.pem  --profile user02
fi
# SET READ PERMISSIONS FOR PRIVATE KEY

chmod 400 $keyPair.pem


#########################################
# Launch EC2 instance from migrated AMI #
#########################################
echo " "

echo "Creating EC2 instance on target account..."$'\n' 

aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --key-name $keyPair --profile user02