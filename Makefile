CONTAINER_PATH ?= ferest/etcd-initer
CONTAINER_VERSION ?= $(shell git describe --tags --always)

build:
	docker build --no-cache -t "$(CONTAINER_PATH):$(CONTAINER_VERSION)" .
	docker tag "$(CONTAINER_PATH):$(CONTAINER_VERSION)" "$(CONTAINER_PATH):latest"

push:
	docker push "$(CONTAINER_PATH):$(CONTAINER_VERSION)"
	docker push "$(CONTAINER_PATH):latest"

.PHONY: build push
