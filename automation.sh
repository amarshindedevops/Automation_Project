#!/bin/bash
s3_bucket="upgrad-amarshinde"
myname="amar"
timestamp=$(date '+%d%m%Y-%H%M%S')
sudo apt update -y
#Check if apache2 is installed.
dpkg -s apache2 &> /dev/null  
if [ $? -ne 0 ]
then
    echo "apache2 not installed"  
    sudo apt install apache2
else
    echo "apache2 installed"
fi
#Check if apache2 is running
servstat=$(service apache2 status)
if [[ $servstat == *"active (running)"* ]]; then
  echo "apache2 process is running"
else 
  echo "apache2 process is not running"
  sudo systemctl start apache2.service	
fi
#Enable Apache2 to start in the event of reboots(AutoStart)
sudo systemctl enable apache2.service
#tar logs and copy it into /tmp/ directory
tar czvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.logs
#Check if aws cli is installed
dpkg -s awscli &> /dev/null
if [ $? -ne 0 ]
then
    echo "aws cli not installed"  
    sudo apt install awscli
else
    echo "aws cli installed"
fi
#aws configure
aws configure set aws_access_key_id AKIAWYTXKV4XLPN2YPPR
aws configure set aws_secret_access_key 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
aws configure set default.region us-east-1
aws configure set default.output json
aws s3 \
#Copy the /tmp/${myname}-httpd-logs-${timestamp}.tar to s3 bucket(upgrad-amarshinde)
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
