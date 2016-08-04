# Compiling rustc compiler on Debian GNU/Linux host for Debian GNU/kFreeBSD target

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get update && apt-get install -y \
  git \
  curl \
  python \
  libssl-dev

# To build cargo, we need a newer cmake than the one included with Debian
WORKDIR /build
RUN wget https://cmake.org/files/v3.6/cmake-3.6.1-Linux-x86_64.tar.gz && tar xf cmake-3.6.1-Linux-x86_64.tar.gz
ENV PATH /build/cmake-3.6.1-Linux-x86_64/bin:$PATH

# The Rust build system won't build LLVM for the target correctly (even if we specify it as a host), so we have to build it separately.
WORKDIR /build
RUN wget http://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz && tar xf llvm-3.8.1.src.tar.xz

WORKDIR /build/build-llvm
#  TODO: LLVM does not seem to handle PATH_MAX correctly for kFreeBSD
RUN sed -i "s/_POSIX_PATH_MAX/4096/" /build/llvm-3.8.1.src/utils/unittest/googletest/src/gtest-filepath.cc
RUN sed -i "s/PATH_MAX/4096/" /build/llvm-3.8.1.src/tools/dsymutil/DwarfLinker.cpp
RUN mkdir -p /build/build-rust/x86_64-unknown-kfreebsd-gnu/llvm/lib/
RUN ../llvm-3.8.1.src/configure --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu --prefix=/build/build-rust/x86_64-unknown-kfreebsd-gnu/llvm/
# TODO: Parallel make > 2 does not seem to work well, gives errors about llvm-tblgen
RUN make -j2
RUN make install

WORKDIR /build
# This is a tag, not a branch. But the same command line option is used in git.
RUN git clone -b kfreebsd-1 --depth 1 https://www.github.com/thesam/rust
WORKDIR /build/rust
RUN git submodule sync
RUN git submodule init
RUN git submodule update

WORKDIR /build/build-rust
RUN ../rust/configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j8 rustc-stage1
RUN make -j8 rustc-stage2
RUN make -j8 # rustdoc needed to compile cargo
# TODO: Fails since jemalloc is disabled. /buildrust/rust/src/test/run-pass/allocator-default.rs:14:1: 14:29 error: can't find crate for `alloc_jemalloc` [E0463]
#RUN make check
ENV PATH /build/build-rust/x86_64-unknown-linux-gnu/stage2/bin:$PATH

WORKDIR /build
RUN git clone https://github.com/rust-lang/cargo
WORKDIR /build/cargo
# TODO: I would prefer to use a tag, but the upstream tags are too old. Fork?
RUN git checkout 5157040338890982e59a49837a035f2612d13c0b
RUN git submodule sync
RUN git submodule init
RUN git submodule update
RUN ./configure
RUN make -j4
ENV PATH /build/cargo/target/x86_64-unknown-linux-gnu/release:$PATH

WORKDIR /build/rust/src/rustc
# When the dependencies are rlibs like this, rustc will have them statically linked. This will make rustc easier to use on the target. (No libs need to be copied for stage0)
RUN sed -i 's/crate-type.*/crate_type = ["rlib"]/' ../*/Cargo.toml

RUN echo "[target.x86_64-unknown-kfreebsd-gnu]" > ~/.cargo/config
RUN echo 'linker = "x86_64-kfreebsd-gnu-gcc"' >> ~/.cargo/config

# Needs LLVM libs for the target, but llvm-config from the host
# TODO: Why is RUNPATH not set?
RUN LLVM_CONFIG=/build/build-rust/x86_64-unknown-kfreebsd-gnu/llvm/bin/x86_64-kfreebsd-gnu-llvm-config-host \
    CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-kfreebsd-gnu \
    cargo build \
    --release \
    --target x86_64-unknown-kfreebsd-gnu

# TODO: Build cargo for kFreeBSD?
#WORKDIR /build/cargo
#RUN cargo build \
#    --release \
#    --target x86_64-unknown-kfreebsd-gnu

# TODO: Put rustc and cargo in an output dir
WORKDIR /build/rust/src/rustc
