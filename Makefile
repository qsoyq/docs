.PHONY: default pre-commit image push format


IMAGE_NAME := qsoyq/docs
PROJECT_NAME := docs

default: pre-commit build push


pre-commit:
	@pre-commit run --all-file

mypy:
	@mypy .

build:
	docker build --platform linux/amd64 -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)	
