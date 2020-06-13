FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# pass on gpu drivers, including graphics capabilities for optix
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

RUN apt-get update --fix-missing && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get install -y -q wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion && \
    apt-get clean

# install build requirements https://mitsuba2.readthedocs.io/en/latest/src/getting_started/compiling.html#linux
RUN apt -y update && apt-get install -y -q --no-install-recommends \
    build-essential dkms libglfw3-dev pkg-config libglvnd-dev \
    freeglut3-dev cmake-curses-gui libtbb-dev gitk emacs25 \
    vim clang-9 libc++-9-dev libc++abi-9-dev cmake ninja-build \
    libz-dev libpng-dev libjpeg-dev libxrandr-dev libxinerama-dev libxcursor-dev \
    python3-dev python3-distutils python3-setuptools \
    python3-pytest python3-pytest-xdist python3-numpy zip unzip

# install conda and create an env, install jupyter lab
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy && \
    /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda create -y -n mitsuba2 python=3.7 && \
    echo "source /opt/conda/bin/activate mitsuba2" >> ~/.bashrc
ENV PATH /opt/conda/envs/mitsuba2/bin:$PATH
RUN /bin/bash -c "source /opt/conda/bin/activate mitsuba2 && \
    /opt/conda/bin/conda install -y ipywidgets numpy pytorch && \
    /opt/conda/bin/conda install -y -c conda-forge jupyterlab"

# install optix
# optix requires NVIDIA R435.80 driver or newer and we will need cuda 10.2+
COPY optix7_installer optix7_installer
RUN ./optix7_installer --skip-license --prefix=/root --include-subdir

# install mitsuba 
# use pathreparam-optix7 branch see https://github.com/mitsuba-renderer/mitsuba2/issues/26
ENV CC clang-9
ENV CXX clang++-9
RUN cd root && git clone https://github.com/mitsuba-renderer/mitsuba2.git && \
    cd mitsuba2 && \
    git checkout pathreparam-optix7 && \
    git submodule update --init --recursive
RUN cp /root/mitsuba2/resources/mitsuba.conf.template /root/mitsuba2/mitsuba.conf && \
    sed -i 's/"default": "scalar_spectral",.*/"default": "gpu_autodiff_rgb",/' /root/mitsuba2/mitsuba.conf
RUN /bin/bash -c "source /opt/conda/bin/activate mitsuba2 && \
    mkdir /root/mitsuba2/build && \
    cd /root/mitsuba2/build && \
    cmake -GNinja .. && \
    ninja"
RUN echo 'source /root/mitsuba2/setpath.sh' >> ~/.bashrc

# welcome message
RUN echo 'nvidia-smi && echo "Hi! Nvidia driver should be >440 and cuda >10.2 otherwise you should find another machine. \n Launch jupyter lab with: \n jupyter lab --ip 0.0.0.0  --allow-root --port 8080"' >> ~/.bashrc