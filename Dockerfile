# docker build -t alpine-ecflow .
# FROM alpine:edge
FROM alpine:3.19.3
RUN apk update \
 && apk add --no-cache build-base cmake g++ linux-headers openssl python3-dev ca-certificates wget vim git perl \
 && update-ca-certificates

RUN apk add --no-cache openssl-dev
RUN apk add --no-cache cmake
RUN apk add python3-dev
RUN apk add qt5-qtnetworkauth qt5-qtnetworkauth-dev qt5-qtsvg-dev qt5-qtcharts-dev

# OPER
# ENV CM=https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
# ENV CM=https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2.tar.gz
# ENV CM=https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz

ENV DBUILD=/tmp/ecflow_build
RUN mkdir ${DBUILD}
RUN mkdir -p /tmp/build

# RUN cd ${DBUILD} && wget -O cmake-3.tgz ${CM}
# DEV
# COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/cmake-3.tgz
#RUN cd ${DBUILD} \
#    && tar -xzf cmake-3.tgz \
#    && cd cmake-3.* \
#    && ./configure \
#    && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

ENV BOOST_VERSION=1.71.0
ENV WK=/tmp/ecflow_build/ecFlow-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_71_0 \
    TB=boost_1_71_0.tar.gz \
    COMPILE=1 \
    HTTPB=https://archives.boost.io/release/1.71.0/source/${TB}
# TE=ecFlow-5.12.0-Source.tar.gz
# HTTP=https://github.com/ecmwf/ecflow/archive/refs/heads/develop.zip
# HTTP=https://confluence.ecmwf.int/download/attachments/8650755

RUN export BOOST_TGZ=boost_$(echo ${BOOST_VERSION} | tr '.' '_').tar.gz \
	   HTTPB=https://archives.boost.io/release/1.71.0/source/boost_1_71_0.tar.gz \
    && cd ${DBUILD} \
    && wget -O ${BOOST_TGZ} ${HTTPB} \
    && tar -xzf ${BOOST_TGZ}

RUN export ETGZ=ecFlow.zip HTTPE=https://confluence.ecmwf.int/download/attachments/8650755/ecFlow-5.12.0-Source.tar.gz?api=v2 \
    && cd ${DBUILD} \
    && wget -O ${ETGZ} https://github.com/ecmwf/ecflow/archive/refs/heads/develop.zip && unzip ${ETGZ}

# RUN export ETGZ=ecFlow.tgz HTTPE=https://confluence.ecmwf.int/download/attachments/8650755 \
#    && cd ${DBUILD}
#    && wget -O ${ETGZ} ${HTTPE}/ecFlow-${ECFLOW_VERSION}-Source.tar.gz?api=v2 && tar -xzf ${ETGZ}
# RUN apk add python2-dev

RUN cd ${DBUILD} && wget -O ecbuild.zip \
  https://github.com/ecmwf/ecbuild/archive/refs/heads/develop.zip && \
  unzip ecbuild.zip && \
  cd ecbuild-* && mkdir build && cd build && cmake ../ && make && make install
ENV ECFLOW_VERSION=5.13.4
RUN ln -sf ${DBUILD}/ecflow-develop ${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source
RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd ${BOOST_ROOT} \
    && python_root=$(python3 -c "import sys; print(sys.prefix)") \
    && ./bootstrap.sh  --with-python-root=$python_root \
                       --with-python=/usr/bin/python3 \
    && sed -i "s|using python : 3.10 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
    && ln -sf /usr/include/python3.10 /usr/include/python \
    && ln -sf /usr/include/python3.10 /usr/include/python3.9
    # && ash $WK/build_scripts/boost_build.sh

# RUN apk add bison flex liblz4-dev libblas-dev liblapack-dev curl doxygen
RUN apk add boost boost-dev
ENV BOOST_ROOT=/usr
ENV WK=${DBUILD}
RUN mkdir -p ${WK} && cd ${WK} && git clone https://github.com/ecmwf/ecflow.git
RUN mkdir -p ${WK}/ecflow-develop/build
ENV WK=${DBUILD}/ecflow-develop
RUN sed -i "s| Boost ${ECFLOW_BOOST_VERSION} REQUIRED| Boost REQUIRED |g" ${WK}/CMakeLists.txt
RUN sed -i "70i set ( ENABLE_STATIC_BOOST_LIBS OFF) " ${WK}/CMakeLists.txt
RUN sed -i "14i find_package( Boost ) " ${WK}/CMakeLists.txt
RUN sed -i '/^[^#]/ s/\(^.*set(ECFLOW_BOOST_VERSION.*$\)/#\ \1/' ${WK}/CMakeLists.txt
RUN sed -i "70i set ( HAVE_TESTS OFF) " ${WK}/CMakeLists.txt
RUN cd ${WK}/build && cmake -B . -S ..
RUN cd ${WK}/build && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

    # && cmake -DCMAKE_CXX_FLAGS=-w -DENABLE_UI=OFF -DENABLE_PYTHON=OFF .. \
    # && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

# RUN apk del cmake g++ linux-headers build-base && rm -rf ${DBUILD}

ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=C \
    PYTHONPATH=/usr/local/lib/python3/site-packages

# https://pkgs.alpinelinux.org/packages?name=build-base&branch=&repo=&arch=&maintainer=
