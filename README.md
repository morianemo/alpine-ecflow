# alpine-ecflow
ecFlow python3

https://software.ecmwf.int/wiki/display/ECFLOW/Documentation

```bash
docker build -t alpine-ecflow .
docker run --net=host -ti alpine-ecflow bash
docker run --net=host -ti alpine-ecflow ecflow_client --help
docker run --net=host -ti alpine-ecflow ecflow_server --port 2500

xhost +
docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ecflow-debian ecflowview
docker run -e DISPLAY -v /tmp/.Xauthority:/tmp/.Xauthority --net=host -ti ecflow-debian ecflow_ui
```

[FAQ](https://confluence.ecmwf.int/display/ECFLOW/Frequently+Asked+Questions)

> Exception in ServerMain:: locale::facet::_S_create_c_locale name not valid
> Server environment:
> terminate called after throwing an instance of 'std::runtime_error'
>   what():  locale::facet::_S_create_c_locale name not valid

```bash
export LANG=C

pandoc README.md | lynx -stdin

```

