# Cross-compiler, Debian GNU/Linux to Debian GNU/kFreeBSD
# Based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get install -y git
WORKDIR /build
RUN git clone https://www.github.com/thesam/rust
WORKDIR /build/rust
RUN git checkout kfreebsd
RUN git submodule sync
RUN git submodule init
RUN apt-get install -y curl python cmake
WORKDIR /build/build-rust
RUN ../rust/configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j4 rustc-stage1
RUN make -j4
#TODO: Fails since jemalloc is disabled. /buildrust/rust/src/test/run-pass/allocator-default.rs:14:1: 14:29 error: can't find crate for `alloc_jemalloc` [E0463]
#RUN make check
ENV PATH /build/build-rust/x86_64-unknown-linux-gnu/stage2/bin:$PATH
WORKDIR /build
RUN git clone --recursive https://github.com/rust-lang/cargo
WORKDIR /build/cargo
RUN apt-get install -y libssl-dev cmake python curl
RUN ./configure
RUN make
ENV PATH /build/cargo/target/x86_64-unknown-linux-gnu/release:$PATH

WORKDIR /build/build-rust-host
RUN ../rust/configure --host=x86_64-unknown-kfreebsd-gnu --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc

#WORKDIR /buildrust/build-llvm
#TODO: PATH_MAX is not correctly detected for kFreeBSD?
#RUN sed 's/_POSIX_PATH_MAX/4096/' -i /buildrust/rust/src/llvm/utils/unittest/googletest/src/gtest-filepath.cc
#RUN ../rust/src/llvm/configure --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu CXXFLAGS='-std=c++11'
#TODO: compile to linux first, does that work?
#RUN make -j4

#WORKDIR /buildrust/rust/src/rustc
#ENV PATH /buildrust/rust/x86_64-unknown-linux-gnu/llvm/bin:$PATH
# TODO: https://github.com/rust-lang/rust/issues/15684
# TODO: Needs LLVM libs for the target, but llvm-config from the host (use LLVM_CONFIG env)
#RUN CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-kfreebsd-gnu cargo build --target=x86_64-unknown-kfreebsd-gnu
