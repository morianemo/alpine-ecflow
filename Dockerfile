# docker build -t alpine-ecflow .
# FROM alpine:3.8
FROM frolvlad/alpine-glibc
RUN apk update \
 && apk add --no-cache build-base cmake g++ linux-headers openssl python3-dev ca-certificates wget vim \
 && update-ca-certificates

ENV ECFLOW_VERSION=5.1.0
ENV BOOST_VERSION=1.71.0
ENV DBUILD=/tmp/ecflow_build
RUN mkdir ${DBUILD}

RUN cd ${DBUILD} \
    && export BOOST_TGZ=boost_$(echo ${BOOST_VERSION} | tr '.' '_').tar.gz \
	    ETGZ=ecFlow.tgz \
	    HTTPB=https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz \
	    HTTPE=https://software.ecmwf.int/wiki/download/attachments/8650755 \
    && wget -O ${ETGZ} ${HTTPE}/ecFlow-$ECFLOW_VERSION-Source.tar.gz?api=v2 \
    && wget -O ${BOOST_TGZ} ${HTTPB} \
    && tar -xzf ${ETGZ} \
    && tar -xzf ${BOOST_TGZ}

RUN cd ${DBUILD} \
    && export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \ 
              BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd ${BOOST_ROOT} \
    && python_root=$(python3 -c "import sys; print(sys.prefix)") \
    && ./bootstrap.sh  --with-python-root=$python_root \
                       --with-python=/usr/bin/python3 \
    && sed -i "s|using python : 3.7 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
    && ln -sf /usr/include/python3.7m /usr/include/python \
    && ln -sf /usr/include/python3.7m /usr/include/python3.7 \
    && mkdir -p ${WK}/build 

RUN apk add --no-cache openssl-dev perl git 

# OPER
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz 
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz
RUN cd /tmp/ecflow_build/ && wget -O cmake-3.tgz ${CM}

# DEV
# COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/cmake-3.tgz
RUN cd /tmp/ecflow_build/ \
    && tar -xzf cmake-3.tgz \
    && cd cmake-3.* \
    && ./configure \
    && make && make install
    
RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \ 
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
  && cd $WK/build \
  &&sed -i '1s/^/cmake_policy(SET CMP0004 OLD)/' ../cmake/ecbuild_add_library.cmake \
  && cd ${BOOST_ROOT} \
  && sed -i -e 's/1690/1710/' ${WK}/build_scripts/boost_build.sh \      
  && ash ${WK}/build_scripts/boost_build.sh

RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \ 
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
  && cd ${WK}/build \
  && cmake -DCMAKE_CXX_FLAGS=-w -DENABLE_GUI=OFF -DENABLE_UI=OFF .. \
  && make -j$(grep processor /proc/cpuinfo | wc -l) \
  && make install

# RUN apk del cmake g++ linux-headers build-base 
# RUN rm -rf ${DBUILD}

RUN adduser -SD ecflow
WORKDIR /home/ecflow
# USER ecflow
EXPOSE 2500
# ENTRYPOINT ["/usr/local/bin/ecflow_server", "-d", "-p 2500"]
ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=C \
    PYTHONPATH=/usr/local/lib/python3/site-packages

# https://pkgs.alpinelinux.org/packages?name=build-base&branch=&repo=&arch=&maintainer=
