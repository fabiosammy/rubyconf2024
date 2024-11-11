FROM ruby:3.3.5-bookworm

ENV DEBIAN_FRONTED=noninteractive

RUN apt-get update && \
  apt-get install -y \
    libgl1 \
    libpython3.11 \
    python3.11 \
    python-is-python3 \
    python3.11-venv \
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

RUN mkdir -p ${HOME} && \
  chown -R devel:devel ${HOME} && \
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

WORKDIR $APP
