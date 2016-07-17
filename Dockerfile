# Cross-compiler, Debian GNU/Linux to Debian GNU/kFreeBSD
# Based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get install -y git
WORKDIR /buildrust
RUN git clone https://www.github.com/thesam/rust
WORKDIR /buildrust/rust
RUN git checkout kfreebsd
RUN git submodule sync
RUN git submodule init
RUN apt-get install -y curl python cmake
RUN ./configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j4
