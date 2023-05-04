

This project will be related to creating script for automated migration of ec2 instances from one aws account to another.

=============================================
Project summary
=============================================



- First I will need to go through some research so this project will have phase dedicated only to do reseach and gather all the informations that are needed for project realization.

- Second phase will be phase named experiment. During that phase I will install aws cli on my machine and try to create some resources just for learning purposes and trying to understand how aws cli works.


## Research 

- [x] Check if shell scripts can interfere with AWS
- [x] Check if aws resources(in my case the AMI image of ec2) can be created through shell script
- [x] API of AWS if they are needed.


## Experiment 

- [x] Install AWS cli on machine
- [x] Check how it works and understand the mechanism of aws cli
- [x] Create one resource through aws cli

## Steps to reproduce


- Have already provisioned EC2 instance that is intended for migration
- Create AMI image snapshot of EC2 instance
- Modify Image Permissions and enter the aws account number of the account that AMI instance is going to be shared with.
- Since already existing machine has key-pair we need to extract the public key from the key file and import it later to the target account.(ssh-keygen -y -f TestKey.pem > TestKey.txt)
- After the key has been imported EC2 instance can be launched - *Important thing to watch out is that AMI's are regional resources so therfore we need to be in the same AWS region when deploying machine*


### Script flow

Part where ec2 instance is provisioned, snapshot taken and modified permission of snapshot are preformed on first aws account. On the second aws account snapshot is going to be shared and based on that snapshot new ec2 instance is going to be created. Prior to creation of ec2 instance new key pair is  going to be created.



Useful tips and explanations
========================================================================================================================================

#### AWS CLI Installation

So I had a confusion when I was installing AWS CLI on my linux machine and here is why.

Firstly I have installed aws cli with apt package manager and whenever I run command to check version, as output I get the old version :

```
root@localhost:~# aws --v
aws-cli/1.22.34 Python/3.10.6 Linux/5.15.0-70-generic botocore/1.29.120
```

With apt package manager it was installed globally and was added to the system path.

I wanted to use newer version of aws cli (2.11.15) and I have installed it via script. After installation when I run command to check version I get: 

```
root@localhost:~# aws --v
-bash: /usr/bin/aws: No such file or directory

```

but since I have installed it aws cli via script when i run command in /usr/local/bin :

```
root@localhost:~# /usr/local/bin/aws --v
aws-cli/2.11.15 Python/3.11.3 Linux/5.15.0-70-generic exe/x86_64.ubuntu.22 prompt/off

```


So thing about this confusing case  was that when i install aws cli via script it was not installed golbally therefore I have added `/usr/local/bin` to the system path with command :

```
export PATH=$PATH:/usr/local/bin/
```

So by running this command I have added new directory to the systme path. System path is a list of directories. Whenever command is being runned, shell look for that command in one of the directories listed in system path file. If that command is not listed in any of those directories then we will get an error as output. 


#### Key-pair creation and checking where script is being executed

Part of the project where I spent some time wandering about how to approach the solution is key-pair creation. So I have decided to create new key-pair and private key is going to be downloaded on machine where script is executed so users can later ssh to ec2 instance using that private key. Related to that I needed to overcome problem with place of execution. At first this script was executed on Ubuntu server but later  I needed to configure code so It can be executed on cloud shell since key-pair is saved on different location.

```
#######################

# Create new key-pair #

#######################

echo "Creation of new key-pair"$'\n'

read -p "Type in the name of key-pair: "$'\n' keyPair

OSVERSION=`cat /etc/os-release | sed -n 1p`


if [[ "$OSVERSION" == *"Amazon"* ]]

then

    aws ec2 create-key-pair --key-name "$keyPair" --query 'KeyMaterial' --output text > /home/cloudshell-user/$keyPair.pem  --profile user02

else

    aws ec2 create-key-pair --key-name "$keyPair" --query 'KeyMaterial' --output text > /root/$keyPair.pem  --profile user02

fi
```


========================================================================================================================================

