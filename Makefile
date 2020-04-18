.PHONEY: build-ami, fail-if-exists

default: build-ami

COMMIT_SHA := $(shell git rev-parse HEAD)

build-ami: fail-if-exists
	packer build -var "git-ref=$(COMMIT_SHA)" concourse.json

fail-if-exists:
	./fail-if-exists.sh $(COMMIT_SHA)
