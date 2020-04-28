#!/bin/bash

COMMIT_SHA=$(git rev-parse HEAD)

IMAGES_WITH_COMMIT_SHA=$(aws ec2 describe-images --filters "Name=tag:commit,Values=${COMMIT_SHA}" --region eu-west-2 | jq '.Images | length')

if test ${IMAGES_WITH_COMMIT_SHA} != 0; then
	echo "Image already exists for this commit"
	exit 0
fi

packer build -var "git-ref=$(COMMIT_SHA)" concourse.json
