#!/bin/bash
#This script automates the process of SSH-ing two EC2 instances without password
echo "Enter public IP of First Instance"
read ipInstance1
echo "add path to key for instance 1"
read path1
echo "Enter public IP of Second Instance"
read ipInstance2
echo "add path to key for instance 2"
read path2

#exchanging public keys of instances.....
myScript="ssh-keygen -f .ssh/id_rsa -t rsa -N ''"
echo "Generating public keys in both the instances"
ssh -i $path1 ec2-user@$ipInstance1 "${myScript}"
ssh -i $path2 ec2-user@$ipInstance2 "${myScript}"
scp -i $path1 ec2-user@$ipInstance1:.ssh/id_rsa.pub publicKey1.txt
scp -i $path2 ec2-user@$ipInstance2:.ssh/id_rsa.pub publicKey2.txt

#adding keys.....
publicKey1=`cat publicKey1.txt`
publicKey2=`cat publicKey2.txt`
echo "Connecting the two instances"
atuh1="echo $publicKey2 >> .ssh/authorized_keys;"
auth2="echo $publicKey1 >> .ssh/authorized_keys;"
ssh -i $path1 ec2-user@$ipInstance1 "${S1}"
ssh -i $path2 ec2-user@$ipInstance2 "${S2}"

rm publicKey1.txt publicKey2.txt
echo "Done.....!"
