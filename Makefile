CONT=alpine-ecflow

all:
	docker build -t ${CONT} .
b:
	docker build -t alpine-ecflow .
pod:
	podman build --tag alpine-ecflow -f Dockerfile
pod-run:
	podman run alpine-ecflow ecflow_client --help
ash:
	docker run --net=host -ti ${CONT} ash

clt:
	docker run --net=host -ti ${CONT} ecflow_client --help

svr:
	docker run --net=host -ti ${CONT} ecflow_server --port 2500

view:
	xhost +
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} ecflowview
	docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ${CONT} ecflow_ui

conv:
	convert -delay ${DELAY:=250} -loop 0 ecflow_status-[0-6].png ecflow_status.gif
