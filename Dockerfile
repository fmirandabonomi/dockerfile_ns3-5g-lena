FROM debian:stable-slim
# Inspirado en https://github.com/Herbrant/ns3-docker

# Requisitos para NS3 (de https://www.nsnam.org/wiki/Installation#Prerequisites) y LENA-5G (de https://gitlab.com/cttc-lena/nr readme.md)
# minimal requirements for release 3.36 and later (also installs libc6-dev)
RUN apt-get -y update && \
    apt-get -y install \
        build-essential \
        ninja-build \
        cmake \
        python3 \
        git \
        tar \
        bzip2
# minimal requirements for Python visualizer and bindings (ns-3.37 and newer)
RUN apt-get -y install\
        python3-cppy \
        gir1.2-goocanvas-2.0 \
        python3-gi \
        python3-gi-cairo \
        python3-pygraphviz \
        gir1.2-gtk-3.0 \
        ipython3
# minimal requirements for Python API users (release 3.30 to ns-3.36)
RUN apt-get -y install\
        python3-dev \
        pkg-config \
        sqlite3
# additional minimal requirements for Python (development)
RUN apt-get -y install\
        python3-setuptools
# Netanim animator
RUN apt-get -y install\
        qtbase5-dev \
        qtchooser \
        qt5-qmake \
        qtbase5-dev-tools
# Support for MPI-based distributed emulation
RUN apt-get -y install\
        openmpi-bin \
        openmpi-common \
        openmpi-doc \
        libopenmpi-dev
ENV PATH="$PATH:/usr/lib/x86_64-linux-gnu/openmpi/lib"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/openmpi/lib"

# Support for bake build tool
RUN apt-get -y install\
        mercurial \
        unzip
# Debugging
RUN apt-get -y install\
        gdb \
        valgrind

# Support for utils/check-style-clang-format.py code style check program (since ns-3.37)
RUN apt-get -y install\
        clang-format

# GNU Scientific Library (GSL) support for more accurate 802.11b WiFi error models (not needed for OFDM)
RUN apt-get -y install\
        gsl-bin \
        libgsl-dev \
        libgslcblas0

# To read pcap packet traces
RUN apt-get -y install\
        tcpdump

# Database support for statistics framework
RUN apt-get -y install\
        libsqlite3-dev

# Xml-based version of the config store (requires libxml2 >= version 2.7)
RUN apt-get -y install\
        libxml2 \
        libxml2-dev

# Eigen3
RUN apt-get -y install\
        libeigen3-dev

# # Soporte para Openflow
# Support for openflow module (requires libxml2-dev if not installed above) and Boost development libraries
RUN apt-get -y install\
        libboost-all-dev
WORKDIR /ns3
RUN hg clone http://code.nsnam.org/openflow &&\
    cd openflow &&\
    ./waf configure &&\
    ./waf build

# # Librería BRITE
WORKDIR /ns3
RUN hg clone http://code.nsnam.org/BRITE &&\
    cd BRITE &&\
    make

# # Librería Click
WORKDIR /ns3
RUN git clone https://github.com/kohler/click &&\
    cd click/ &&\
    ./configure --disable-linuxmodule --enable-nsclick --enable-wifi &&\
    make

# # Soporte para genenrar documentacion
# Doxygen and related inline documentation
# RUN apt-get -y install\
#         doxygen \
#         graphviz \
#         imagemagick \
#         texlive \
#         texlive-extra-utils \
#         texlive-latex-extra \
#         texlive-font-utils \
#         dvipng \
#         latexmk

# The ns-3 manual and tutorial are written in reStructuredText for Sphinx (doc/tutorial, doc/manual, doc/models), and figures typically in dia (also needs the texlive packages above)
# RUN apt-get -y install\
#         python3-sphinx \
#         dia

# Requisitos extra para compilar documentación de LENA-5G (de .gitlab-ci.yml)
# RUN sed -i "s/EPS,PDF,//g" /etc/ImageMagick-6/policy.xml && \
#     sed -i "s/none/read\ |\ write/g" /etc/ImageMagick-6/policy.xml
# RUN apt-get -y install \
#         texlive-xetex \
#         texlive-binaries
# RUN apt-get -y install \
#         latexmk \
#         texlive-science \
#         texlive-formats-extra \
#         texlive-base \
#         python3-jinja2 \
#         python3-pygments \
#         texlive-fonts-extra


# Clona NS3
WORKDIR /ns3
RUN git clone https://gitlab.com/nsnam/ns-3-dev.git

# Clona LENA-5G
WORKDIR /ns3/ns-3-dev/contrib
RUN git clone https://gitlab.com/cttc-lena/nr.git

# Release v2.4.y de lena-5g y correspondiente release recomendado (3.38) de ns3
WORKDIR /ns3/ns-3-dev/contrib/nr
RUN git checkout 5g-lena-v2.4.y
WORKDIR /ns3/ns-3-dev
RUN git checkout ns-3.38

# Configure and build
RUN ./ns3 configure  \
        --with-openflow=/ns3/openflow \
        --with-brite=/ns3/BRITE \
        --with-click=/ns3/click \
        --enable-mpi \
        --enable-python-bindings \
        --enable-des-metrics \
        --enable-examples \
        --enable-tests &&\
    ./ns3

# # Documentacion pdf para NS3
# WORKDIR /ns3/ns-3-dev
# RUN ./ns3 docs sphinx
# #Documentación doxygen para NS3 (-no-build para evitar 3 test de NR que fallan)
# RUN ./ns3 docs doxygen-no-build

# # Documentación pdf para NR
# WORKDIR /ns3/ns-3-dev/contrib/nr/doc
# RUN make latexpdf

# # Documentación Doxygen para NR
# WORKDIR /ns3/ns-3-dev/contrib/nr
# RUN git submodule sync --recursive &&\
#     git submodule update --init --recursive &&\
#     python3 doc/m.css/documentation/doxygen.py doc/doxygen-mcss.conf --debug

WORKDIR /ns3/ns-3-dev


