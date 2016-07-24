# Compiling rustc compiler on Debian GNU/Linux host for Debian GNU/kFreeBSD target

FROM thesam/debian-linux-kfreebsd-cross

RUN apt-get update && apt-get install -y \
  git \
  curl \
  python \
  cmake \
  libssl-dev

WORKDIR /build
RUN wget http://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz && tar xf llvm-3.8.1.src.tar.xz

WORKDIR /build/build-llvm
#TODO: LLVM does not seem to handle PATH_MAX correctly for kFreeBSD
RUN sed -i "s/_POSIX_PATH_MAX/4096/" /build/llvm-3.8.1.src/utils/unittest/googletest/src/gtest-filepath.cc
RUN sed -i "s/PATH_MAX/4096/" /build/llvm-3.8.1.src/tools/dsymutil/DwarfLinker.cpp
RUN mkdir -p /build/build-rust/x86_64-unknown-kfreebsd-gnu/llvm/lib/
RUN ../llvm-3.8.1.src/configure --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu --prefix=/build/build-rust/x86_64-unknown-kfreebsd-gnu/llvm/
#TODO: Parallel make does not seem to work well, gives errors about llvm-tblgen
RUN make -j2
RUN make install

WORKDIR /build
RUN echo "Rebuild from here..."
RUN git clone -b kfreebsd --depth 1 https://www.github.com/thesam/rust

WORKDIR /build/rust
RUN git submodule sync
RUN git submodule init
RUN git submodule update

WORKDIR /build/build-rust
RUN ../rust/configure --target=x86_64-unknown-kfreebsd-gnu --disable-jemalloc
RUN make -j8 rustc-stage1
RUN make -j8 rustc-stage2
RUN make -j8 # rustdoc needed to compile cargo
#TODO: Fails since jemalloc is disabled. /buildrust/rust/src/test/run-pass/allocator-default.rs:14:1: 14:29 error: can't find crate for `alloc_jemalloc` [E0463]
#RUN make check
ENV PATH /build/build-rust/x86_64-unknown-linux-gnu/stage2/bin:$PATH

# We need a newer cmake to build cargo
RUN apt-get purge -y cmake
RUN apt-get autoremove -y
WORKDIR /build
RUN wget https://cmake.org/files/v3.6/cmake-3.6.1-Linux-x86_64.tar.gz && tar xf cmake-3.6.1-Linux-x86_64.tar.gz
ENV PATH /build/cmake-3.6.1-Linux-x86_64/bin:$PATH

WORKDIR /build
RUN git clone --recursive --depth 1 https://github.com/rust-lang/cargo
WORKDIR /build/cargo
RUN ./configure
RUN make -j4
ENV PATH /build/cargo/target/x86_64-unknown-linux-gnu/release:$PATH

WORKDIR /build/rust/src/rustc
RUN echo "[target.x86_64-unknown-kfreebsd-gnu]" > ~/.cargo/config
RUN echo 'linker = "x86_64-kfreebsd-gnu-gcc"' >> ~/.cargo/config
# Needs LLVM libs for the target, but llvm-config from the host
#TODO: Is CFG_COMPILER_HOST_TRIPLE needed/correct?
RUN LLVM_CONFIG=/build/build-rust/x86_64-unknown-linux-gnu/llvm/bin/llvm-config CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-kfreebsd-gnu cargo build --target x86_64-unknown-kfreebsd-gnu
# TODO: Remember https://github.com/rust-lang/rust/issues/15684
# TODO: Package as a stage0 snapshot
