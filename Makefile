IMAGE_NAME=ysyx-docker
TAG=latest

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

run:
	docker run -it $(IMAGE_NAME):$(TAG)