# Writing a bash script to configure the Virtual Machine for hosting a web server and later automating some maintainance tasks
# Hosting Web Server: 
  The first step is to set up a web server on the EC2 instance for hosting a website. It is also important to ensure that the apache2 server is running and it restarts automatically in case the EC2 instance reboots.
# Archiving Logs: 
  Daily requests to web servers generate lots of access logs. These log files  serve as an  important tool for troubleshooting.  However, these logs can also result in the servers running out of disk space and can make them stop working. To avoid this, one of the best practices is to create a backup of these logs by compressing the logs directory and archiving it to the s3 bucket (Storage). 
