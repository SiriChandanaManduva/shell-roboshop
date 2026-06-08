#!/bin/bash

set -e # this will be checking for errors, if errors it will exit

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
echo " please run the script using root access" | tee -a $LOGS_FILE
exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
echo -e "$2 ... $R failure $N " | tee -a $LOGS_FILE 
exit 1
else
echo -e "$2 ... $G success $N" | tee -a $LOGS_FILE
fi

}
  
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MONGODB sever"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MONGODB"

systemctl start mongod 
VALIDATE $? "Start MONGODB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MONGODB"