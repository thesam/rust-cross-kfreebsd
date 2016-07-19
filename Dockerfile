# Cross-compiler, Debian GNU/Linux to Debian GNU/kFreeBSD
# Based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get install -y git
WORKDIR /build
RUN git clone -b kfreebsd --depth 1 https://www.github.com/thesam/rust
WORKDIR /build/rust
RUN git submodule sync
RUN git submodule init
RUN apt-get install -y curl python cmake
WORKDIR /build/build-rust
RUN ../rust/configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j4 rustc-stage1
RUN make -j4 rustc-stage2
RUN make -j4
#TODO: Fails since jemalloc is disabled. /buildrust/rust/src/test/run-pass/allocator-default.rs:14:1: 14:29 error: can't find crate for `alloc_jemalloc` [E0463]
#RUN make check
ENV PATH /build/build-rust/x86_64-unknown-linux-gnu/stage2/bin:$PATH
WORKDIR /build
RUN git clone --recursive --depth 1 https://github.com/rust-lang/cargo
WORKDIR /build/cargo
RUN apt-get install -y libssl-dev cmake python curl
RUN ./configure
RUN make
ENV PATH /build/cargo/target/x86_64-unknown-linux-gnu/release:$PATH

WORKDIR /build/build-kfreebsd-llvm
RUN ../rust/configure --host=x86_64-unknown-kfreebsd-gnu --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
#TODO: Build LLVM only? Or will this work?
RUN make -j4 rustc-stage1
RUN make -j4 rustc-stage2

#WORKDIR /buildrust/rust/src/rustc
# TODO: https://github.com/rust-lang/rust/issues/15684
# TODO: Needs LLVM libs for the target, but llvm-config from the host (use LLVM_CONFIG env)
#RUN LLVM_CONFIG=/build/build-kfreebsd-llvm/x86_64-unknown-kfreebsd-gnu/llvm/bin/llvm-config CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-kfreebsd-gnu cargo build --target=x86_64-unknown-kfreebsd-gnu
