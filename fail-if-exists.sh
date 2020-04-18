#!/bin/sh

COMMIT_ID=${1}

IMAGES_WITH_COMMIT_ID=$(aws ec2 describe-images --filters "Name=tag:commit,Values=${COMMIT_ID}" --region eu-west-2 | jq '.Images | length')

if test ${IMAGES_WITH_COMMIT_ID} != 0; then
	exit 1
fi
