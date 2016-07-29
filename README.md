# rust-cross-kfreebsd
A Docker container which cross-compiles Rust for Debian GNU/kFreeBSD.

## Goals
* Add kFreeBSD as a cross-compile target in rustc - IN PROGRESS - https://github.com/thesam/rust/tree/kfreebsd
* Cross-compile "Hello, world!" for kFreeBSD - DONE
* Cross-compile rustc for kFreeBSD - DONE
* Compile libcore on kFreeBSD - IN PROGRESS, issue #2
* Run a complete rustc build on kFreeBSD
* Submit pull requests to upstream projects
* Compile cargo on kFreeBSD

## How to use
### Step 1 : On any host with Docker support
This step will cross-compile rustc for the kFreeBSD platform. The resulting rustc does not have to be perfect, but it must be able to re-compile itself after being transferred to a kFreeBSD host.
```
git clone https://www.github.com/thesam/debian-linux-kfreebsd-cross.git
git clone https://www.github.com/thesam/rust-cross-kfreebsd.git
docker build -t thesam/debian-linux-kfreebsd-cross debian-linux-kfreebsd-cross
docker build -t thesam/rust-cross-kfreebsd rust-cross-kfreebsd
docker run -it thesam/rust-cross-kfreebsd
```
### Step 2: Inside the Docker container
The rustc binary must be copied from the container to the kFreeBSD host.
```
ssh YOURUSER@YOURHOST 'mkdir -p ~/myrust/bin'
scp target/x86_64-unknown-kfreebsd-gnu/release/rustc YOURUSER@YOURHOST:myrust/bin/rustc
```
### Step 3: On GNU/kFreeBSD host
A full Rust build will be run with the new rustc. This ensures that the bootstrap process will work on the host, and will result in a resdistributable .tar.gz.
```
export PATH=~/myrust/bin:$PATH
./configure --disable-jemalloc --disable-rpath --enable-local-rust
TODO
```

## Inspirations
* https://github.com/mneumann/rust-cross-dragonfly
* https://github.com/japaric/ruststrap
