include .env

USERNAME=app
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

DOCKLE_LATEST=`(curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')`

build:
	DOCKER_BUILDKIT=1 docker buildx build --push --platform linux/arm64/v8,linux/amd64 --build-arg VERSION=$(VERSION) -t sangheon/rust:$(VERSION) --no-cache .
	$(MAKE) pull

testbuild:
	docker build --build-arg VERSION=$(VERSION) -t sangheon/rust:$(VERSION)-build .

testrun:
	docker run -it --rm --name rust_$(VERSION) -e HOST_UID=$(USER_ID) -e HOST_GID=$(GROUP_ID) sangheon/rust:$(VERSION)-build /bin/zsh

init:
	docker buildx inspect --bootstrap
	docker buildx create --name multiarch-builder --use
	docker buildx use multiarch-builder

push:
	docker push sangheon/rust:$(VERSION)

pull:
	docker pull sangheon/rust:$(VERSION)

clean:
	-docker rm rust_$(VERSION)
	-docker rmi sangheon/rust:$(VERSION)

shell:
	docker exec -it -u $(USERNAME) rust_$(VERSION) /bin/zsh

start:
	docker run -itd --name rust_$(VERSION) -e HOST_UID=$(USER_ID) -e HOST_GID=$(GROUP_ID) sangheon/rust:$(VERSION)
	$(MAKE) log

stop:
	docker stop rust_$(VERSION)

log:
	docker logs -f rust_$(VERSION)

workspace::
	docker run -itd --name rust_$(VERSION) -e HOST_UID=$(USER_ID) -e HOST_GID=$(GROUP_ID) --volume "$(PWD)":/app/ sangheon/rust:$(VERSION)
	$(MAKE) log

sandbox:
	docker run -it --rm --name rust_$(VERSION) -e HOST_UID=$(USER_ID) -e HOST_GID=$(GROUP_ID) --volume $(PWD):/app/ sangheon/rust:$(VERSION) /bin/zsh

lint:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock goodwithtech/dockle:v${DOCKLE_LATEST} sangheon/rust:$(VERSION)