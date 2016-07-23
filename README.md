# rust-cross-kfreebsd
A Docker container which cross-compiles Rust for Debian GNU/kFreeBSD.

## Goals
* Add kFreeBSD as a cross-compile target in rustc - IN PROGRESS
* Cross-compile "Hello, world!" for kFreeBSD - DONE
* Cross-compile rustc for kFreeBSD - IN PROGRESS
* Run a complete rustc build on kFreeBSD
* Compile cargo on kFreeBSD

## How to use
### Step 1 : On any host with Docker support
This step will cross-compile rustc for the kFreeBSD platform. The resulting rustc does not have to be perfect, but it must be able to re-compile itself after being transferred to a kFreeBSD host.
```
git clone https://www.github.com/thesam/debian-linux-kfreebsd-cross.git
git clone https://www.github.com/thesam/rust-cross-kfreebsd.git
TODO
```
### Step 2: On GNU/kFreeBSD host
A full Rust build will be run with the new rustc. This ensures that the bootstrap process will work on the host, and will result in a resdistributable .tar.gz.
```
TODO
```

## Inspirations
* https://github.com/mneumann/rust-cross-dragonfly
* https://github.com/japaric/ruststrap
