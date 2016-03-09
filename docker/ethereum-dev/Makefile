IMAGE=ethereum-dev

all: Dockerfile build-image

Dockerfile: bootstrap.sh
	sh bootstrap.sh

build-image: Dockerfile
	docker build -t $(IMAGE) .

clean:
	rm Dockerfile
