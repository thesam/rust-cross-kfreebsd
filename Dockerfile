# Compiling rustc compiler on Debian GNU/Linux host for Debian GNU/kFreeBSD target

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get install -y git && exit 0
WORKDIR /build
RUN git clone -b kfreebsd --depth 1 https://www.github.com/thesam/rust

WORKDIR /build/rust
RUN git submodule sync
RUN git submodule init
RUN git submodule update
RUN apt-get install -y curl python cmake

WORKDIR /build/build-rust
RUN ../rust/configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j8 rustc-stage1
RUN make -j8 rustc-stage2
RUN make -j8 # rustdoc needed to compile cargo
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

WORKDIR /build/rust/src/rustc
# TODO: Needs LLVM libs for the target, but llvm-config from the host (use LLVM_CONFIG env)
RUN echo "[target.x86_64-unknown-kfreebsd-gnu]" > ~/.cargo/config
RUN echo 'linker = "x86_64-kfreebsd-gnu-gcc"' >> ~/.cargo/config
#TODO: Build LLVM for kfreebsd? Or will this work?
RUN LLVM_CONFIG=/build/build-rust/x86_64-unknown-linux-gnu/llvm/bin/llvm-config CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-linux-gnu cargo build --target x86_64-unknown-kfreebsd-gnu
# TODO: https://github.com/rust-lang/rust/issues/15684
