#!/bin/bash

# Usage : AutoScale4EIP.sh <Allocation ID>

InstanceID=`curl http://169.254.169.254/latest/meta-data/instance-id`

SetEIP(){
	AllocationID=$1
	aws ec2 associate-address \
		--region ap-northeast-1 \
		--instance-id ${InstanceID} \
		--allocation-id ${AllocationID} \
		| grep "true"
	if [ $? -eq 0 ] ; then
		return 0
	else
		return 2
	fi
}

CheckLaunchAutoScale(){
	aws autoscaling describe-auto-scaling-instances \
		--region ap-northeast-1 \
		--instance-ids ${InstanceID} \
		| jq '.AutoScalingInstances[] | .InstanceId' \
		| grep ${InstanceID}
	if [ $? -eq 0 ] ; then
		return 0
	else
		return 2
	fi
}

## オートスケールで起動したインスタンスであることを確認
CheckLaunchAutoScale
if [ $? -ne 0 ] ;then
	exit 2
fi

## EIPをAssociateする
SetEIP $1
if [ $? -ne 0 ] ;then
	exit 2
fi
exit 0
