FROM ruby:3.3.5-bookworm

ENV DEBIAN_FRONTED=noninteractive

# Merge with caffe: https://github.com/BVLC/caffe/blob/master/docker/cpu/Dockerfile

RUN apt-get update && \
  apt-get install -y \
    build-essential \
    cmake \
    git \
    libatlas-base-dev \
    libboost-all-dev \
    libgflags-dev \
    libgl1 \
    libgoogle-glog-dev \
    libhdf5-serial-dev \
    libleveldb-dev \
    liblmdb-dev \
    libopencv-dev \
    libprotobuf-dev \
    libpython3.11 \
    libsnappy-dev \
    protobuf-compiler \
    python3.11 \
    python-is-python3 \
    python3.11-venv \
    vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --disabled-password --gecos '' devel \
  && usermod -a -G sudo devel \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'devel:devel' | chpasswd

ENV HOME=/home/devel
ENV APP=/var/www/app
ENV BUNDLE_PATH=${APP}/.bundle
ENV GEM_HOME=${BUNDLE_PATH}
ENV PATH=${PATH}:${BUNDLE_PATH}/bin
ENV CAFFE_ROOT=/opt/caffe
ENV CAFFE_VERSION=1.0

RUN mkdir -p ${HOME} && \
  chown -R devel:devel ${HOME} && \
  mkdir -p ${CAFFE_ROOT} && \
  chown -R devel:devel ${CAFFE_ROOT} && \
  mkdir -p ${APP} && \
  chown -R devel:devel ${APP} && \
  mkdir -p ${BUNDLE_PATH} && \
  chown -R devel:devel ${BUNDLE_PATH}

USER devel:devel

# ENV CONDA_VERSION=24.9.2-0
# ENV CONDA_DIR=${HOME}/miniconda3
# RUN mkdir -p ${CONDA_DIR} \
#   && wget https://repo.anaconda.com/miniconda/Miniconda3-py312_${CONDA_VERSION}-Linux-x86_64.sh -O ${CONDA_DIR}/miniconda.sh \
#   && bash ${CONDA_DIR}/miniconda.sh -b -u -p ${CONDA_DIR} \
#   && rm ${CONDA_DIR}/miniconda.sh
# ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CONDA_DIR}/lib
# ENV PATH=${PATH}:${CONDA_DIR}/bin

# Using python venv
ENV PYTHON_VENV=${HOME}/.python-venv
RUN python -m venv ${PYTHON_VENV}
ENV PATH=${PYTHON_VENV}/bin:${PATH}
RUN pip install opencv-python==4.10.0.84

WORKDIR $CAFFE_ROOT

COPY caffe.patch ../caffe.patch

RUN git clone -b ${CAFFE_VERSION} --depth 1 https://github.com/BVLC/caffe.git . && \
    git apply ../caffe.patch && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
ENV LD_LIBRARY_PATH=${CAFFE_ROOT}/build/lib:${LD_LIBRARY_PATH}

WORKDIR $APP
