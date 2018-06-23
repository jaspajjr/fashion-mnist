CURRENT_PATH  := $(notdir $(patsubst %/,%,$(CURDIR)))
REPO_URI      := jaspajjr
NAME          := ${CURRENT_PATH}
TAG           := $(shell git rev-parse --short HEAD)
IMG_BUILD     := ${NAME}:tmp
IMG           := ${REPO_URI}/${NAME}:${TAG}
LATEST        := ${REPO_URI}/${NAME}:latest

TEST_CMD      := -t

all: pull build test tag push


clean:
	-@docker rm ${NAME}_${TAG}
	-@docker rmi ${IMG_BUILD}
.PHONY: clean


cleanall: clean
	-@docker images -q "*/${NAME}" | xargs docker image rm
.PHONY: allclean

pull:
	-@docker pull ${LATEST}
	@docker pull ${IMG} || exit 0 && echo Tag already exists upstream at ${IMG}, exiting ; exit 1 

build: pull
	@docker build -t ${IMG_BUILD} .

test: build
	@docker run --name ${NAME}_${TAG} ${IMG_BUILD} ${TEST_CMD}
	@docker rm ${NAME}_${TAG}

tag: test
	@docker tag ${IMG_BUILD} ${IMG}
	@docker tag ${IMG_BUILD} ${LATEST}

push: tag
	@docker push ${IMG}
	@docker push ${LATEST}
	@echo ${NAME} built and pushed to ${IMG}
