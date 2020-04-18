.PHONEY: build-ami

default: build-ami

COMMIT_SHA := $(shell git rev-parse HEAD)

build-ami: 
	packer build -var "git-ref=$(COMMIT_SHA)" concourse.json
