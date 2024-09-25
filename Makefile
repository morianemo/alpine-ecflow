TAG=alpine-ecflow114
all:
	docker build -t ${TAG} .
b:
	docker build -t alpine-ecflow .
pod:
	podman build --tag alpine-ecflow -f Dockerfile
pod-run:
	podman run alpine-ecflow ecflow_client --help
ash:
	docker run --net=host -ti ${TAG} ash
clt:
	docker run --net=host -ti ${TAG} ecflow_client --help
svr:
	docker run --net=host -ti ${TAG} ecflow_server --port 2500
view:
	xhost +
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${TAG} ecflow_ui
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
ecbuild:
	docker build -f Dockerfile.ecbuild -t alpine-ecbuild .
run-ecbuild:
	docker run  --net=host -ti -t alpine-ecbuild ash

deploy:
	docker login
	docker tag alpine-ecflow114 eowyn/alpine-ecflow:latest
	docker push eowyn/alpine-ecflow
install-slim:
	brew install docker-slim
slim:
	slim build --target ${TAG}:latest --tag ${TAG}:light --http-probe=false --exec "ecflow_server --version; ecflow_client --help ; ecflow_ui --h"
