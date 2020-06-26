FROM exawind/exawind-dev:latest AS base

RUN (\
    apt-get update \
    && apt-get install -y --no-install-recommends \
       python3-dev \
       python3-pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && rm -rf /var/lib/apt/lists/* \
    )

WORKDIR /pystk
COPY . /pystk

RUN (\
    pip3 install -r requirements.txt \
    && python setup.py build_ext --inplace -- -DCMAKE_PREFIX_PATH=/opt/exawind/ \
    && pip3 install -e . \
    )

WORKDIR /workspace
