include .env

DOCKLE_LATEST=`(curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')`

build:
	DOCKER_BUILDKIT=1 docker buildx build --push --platform linux/arm64/v8,linux/amd64 --build-arg VERSION=$(VERSION) -t sangheon/rust:$(VERSION) --no-cache .
	$(MAKE) pull

testbuild:
	docker build --build-arg VERSION=$(VERSION) -t sangheon/rust:$(VERSION)-build .

testrun:
	docker run -it --rm --name rust_$(VERSION) sangheon/rust:$(VERSION)-build /bin/zsh

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
	docker exec -it rust_$(VERSION) /bin/zsh

start:
	docker run -itd --name rust_$(VERSION) sangheon/rust:$(VERSION)

stop:
	docker stop rust_$(VERSION)

log:
	docker logs -f rust_$(VERSION)

workspace::
	docker run -itd --name rust_$(VERSION) --volume "$(PWD)":/app/ sangheon/rust:$(VERSION)

sandbox:
	docker run -it --rm --name rust_$(VERSION) --volume $(PWD):/app/ sangheon/rust:$(VERSION) /bin/zsh

lint:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock goodwithtech/dockle:v${DOCKLE_LATEST} sangheon/rust:$(VERSION)
