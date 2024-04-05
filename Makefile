IMAGE_NAME=ysyx-docker
TAG=latest

build:
	docker build -t $(IMAGE_NAME):$(TAG) --network host .

run:
	docker run -it $(IMAGE_NAME):$(TAG)