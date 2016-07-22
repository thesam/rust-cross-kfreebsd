# rust-cross-kfreebsd
A Docker container which cross-compiles Rust for Debian GNU/kFreeBSD.

## Goals
* Add kFreeBSD as a cross-compile target in rustc - IN PROGRESS
* Cross-compile "Hello, world!" for kFreeBSD - DONE
* Cross-compile stage0 rustc for kFreeBSD - IN PROGRESS
* Run a complete rustc build on kFreeBSD
* Compile cargo on kFreeBSD

NOTE: Depends on https://www.github.com/thesam/debian-linux-kfreebsd-cross
