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
#Check if inventory.html file exists or not
FILE=/var/www/html/inventory.html
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
    {
	echo "<html>"
	echo "<body>"
	echo "<table>"
	echo "<thead>"
	echo "<tr>"
	echo "<th>Log Type</th>"
	echo "<th>&nbsp;&nbsp;&nbsp;&nbsp;Time Created</th>"
	echo "<th>&nbsp;&nbsp;Type</th>"
	echo "<th>&nbsp;&nbsp;Size</th>"
	echo "</tr>"
	echo "<tbody>"
    }>>/var/www/html/inventory.html
fi
#Append the contents to end of file without overwriting the previous content
TARFILENAME=/tmp/${myname}-httpd-logs-${timestamp}.tar
FILESIZE=$(du -sh "$TARFILENAME" | awk '{print $1}')
echo "<tr><td>httpd-logs</td><td>&nbsp;&nbsp;&nbsp;&nbsp;$timestamp</td><td>&nbsp;&nbsp;&nbsp;&nbsp;tar</td><td>&nbsp;&nbsp;&nbsp;$FILESIZE<td></tr>" | tee -a /var/www/html/inventory.html
#Check if cron file exists or not
CRONFILE=/etc/cron.d/automation
if [ -f "$CRONFILE" ]; then
    echo "$CRONFILE exists."
else
    #If not exists then create a new in /etc/cron.d/ folder
    echo "$CRONFILE does not exist."
    sudo echo "0 0 */1 * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
    sudo chmod 600 /etc/cron.d/automation
fi	
