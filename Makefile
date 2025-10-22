ECF_PORT=3141
TAG=alpine-ecflow114
CONT=${TAG}
HOST=localhost
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
	docker run --net=host -ti ${TAG} ecflow_client --version
svr:
	docker run --net=host -e LC=C -e ECF_LIST=/home/ecflow/ecflow_server/$(uname -n).ecf.lists-ti ${TAG} ecflow_server --port ${ECF_PORT}
start:
	docker run --net=host -e LC=C -e ECFLOW_BINDIR=/usr/local/bin -e ECF_LIST=/home/ecflow/ecflow_server/$(uname -n).ecf.lists-ti ${TAG} /usr/local/bin/ecflow_start_nohup.sh -N -p ${ECF_PORT}
ping:
	docker run --net=${NET} $(ADDHOST) -ti ${CONT} /usr/local/bin/ecflow_client --ping --port ${ECF_PORT} 
viewm:
	xhost +local:docker
	# docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${TAG} ecflow_ui
	docker run -e DISPLAY=host.docker.internal:0 --net=host -ti ${CONT} ecflow_ui
view:
	docker run --rm -e DISPLAY=:0.0 -v /tmp/.X11-unix:/tmp/.X11-unix -ti ${TAG} ecflow_ui
test:   clt start 
conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
ecbuild:
	docker build -f Dockerfile.ecbuild -t alpine-ecbuild .
run-ecbuild:
	docker run  --net=host -ti -t alpine-ecbuild ash
install-slim:
	brew install docker-slim
slim:
	slim build --target ${TAG}:latest --tag ${TAG}:light --http-probe=false --exec "ecflow_server --version; ecflow_client --help ; ecflow_ui --h"
deploy:
	docker login
	docker tag ${TAG} eowyn/${TAG}:latest
	docker push eowyn/${TAG}
