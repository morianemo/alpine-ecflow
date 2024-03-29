# docker build -t alpine-ecflow .
# FROM frolvlad/alpine-glibc
FROM alpine:3.17
RUN apk update \
 && apk add --no-cache build-base cmake g++ linux-headers openssl python3-dev ca-certificates wget vim \
 && update-ca-certificates

RUN apk add --no-cache openssl-dev perl git 

# OPER
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2.tar.gz
ENV CM=https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz

ENV DBUILD=/tmp/ecflow_build
RUN mkdir ${DBUILD}
RUN mkdir -p /tmp/build 

RUN cd ${DBUILD} && wget -O cmake-3.tgz ${CM}

# DEV
# COPY cmake-3.13.2.tar.gz /tmp/ecflow_build/cmake-3.tgz
RUN cd ${DBUILD} \
    && tar -xzf cmake-3.tgz \
    && cd cmake-3.* \
    && ./configure \
    && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

ENV ECFLOW_VERSION=5.10.0
ENV BOOST_VERSION=1.71.0
ENV WK=/tmp/ecflow_build/ecFlow-5.10.0-Source \
    BOOST_ROOT=/tmp/ecflow_build/boost_1_71_0 \
    TB=boost_1_71_0.tar.gz \
    COMPILE=1 \
    HTTPB=https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/${TB}
#    TE=ecFlow-5.10.0-Source.tar.gz 
# HTTP=https://github.com/ecmwf/ecflow/archive/refs/heads/develop.zip
# HTTP=https://confluence.ecmwf.int/download/attachments/8650755

RUN export BOOST_TGZ=boost_$(echo ${BOOST_VERSION} | tr '.' '_').tar.gz \
	   HTTPB=https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.gz \
    && cd ${DBUILD} \
    && wget -O ${BOOST_TGZ} ${HTTPB} \
    && tar -xzf ${BOOST_TGZ}

RUN export ETGZ=ecFlow.zip HTTPE=https://confluence.ecmwf.int/download/attachments/8650755 \
    && cd ${DBUILD} \
    && wget -O ${ETGZ} https://github.com/ecmwf/ecflow/archive/refs/heads/develop.zip     && unzip ${ETGZ}    

# RUN export ETGZ=ecFlow.tgz HTTPE=https://confluence.ecmwf.int/download/attachments/8650755 \
#    && cd ${DBUILD} 
#    && wget -O ${ETGZ} ${HTTPE}/ecFlow-${ECFLOW_VERSION}-Source.tar.gz?api=v2     && tar -xzf ${ETGZ}

RUN apk add libcrypto1.1 && ln -sf /usr/lib /usr/lib64 && \
  ln -sf /usr/lib64/libcrypto.so /usr/lib64/libcrypt.so

# RUN apk add python2-dev
RUN apk add python3-dev

RUN ln -sf ${DBUILD}/ecflow-develop ${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source

RUN cd ${DBUILD} && wget -O ecbuild.zip \
  https://github.com/ecmwf/ecbuild/archive/refs/heads/develop.zip && \
  unzip ecbuild.zip && \
  cd ecbuild-* && mkdir build && cd build && cmake ../ && make && make install
  
RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd ${BOOST_ROOT} \
    && python_root=$(python3 -c "import sys; print(sys.prefix)") \
    && ./bootstrap.sh  --with-python-root=$python_root \
                       --with-python=/usr/bin/python3 \
    && sed -i "s|using python : 3.10 :  ;|using python : 3 : python3 : /usr/include/python ;|g" project-config.jam \
    && ln -sf /usr/include/python3.10 /usr/include/python \
    && ln -sf /usr/include/python3.10 /usr/include/python3.9 \    
    && ash $WK/build_scripts/boost_build.sh

RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd ${BOOST_ROOT} \
    && sed -i '176d' $WK/build_scripts/boost_build.sh \
    && sed -i '173d' $WK/build_scripts/boost_build.sh \
    && ash $WK/build_scripts/boost_build.sh && mkdir -p $WK/build 

RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd $WK/build \
    && cmake -DCMAKE_CXX_FLAGS=-w -DENABLE_UI=OFF -DENABLE_PYTHON=OFF .. \
    && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

# RUN apk del cmake g++ linux-headers build-base && rm -rf ${DBUILD}
RUN apk add qt5-qtnetworkauth qt5-qtnetworkauth-dev qt5-qtsvg-dev qt5-qtcharts-dev
RUN export WK=${DBUILD}/ecFlow-${ECFLOW_VERSION}-Source \
           BOOST_ROOT=${DBUILD}/boost_$(echo ${BOOST_VERSION} | tr '.' '_') \
    && cd ${BOOST_ROOT} \
    && cmake -DCMAKE_CXX_FLAGS=-w -DENABLE_PYTHON=OFF .. \
    && make -j$(grep processor /proc/cpuinfo | wc -l) && make install

RUN adduser -SD ecflow
WORKDIR /home/ecflow
# USER ecflow
EXPOSE 2500
# ENTRYPOINT ["/usr/local/bin/ecflow_start.sh", "-p 2500"]
ENV ECFLOW_USER=ecflow \
    ECF_PORT=2500 \
    ECF_HOME=/home/ecflow \
    HOME=/home/ecflow \
    HOST=ecflow \
    LANG=C \
    PYTHONPATH=/usr/local/lib/python3/site-packages

# https://pkgs.alpinelinux.org/packages?name=build-base&branch=&repo=&arch=&maintainer=
