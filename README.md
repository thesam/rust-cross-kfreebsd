# rust-cross-kfreebsd
A Docker container which cross-compiles Rust for Debian GNU/kFreeBSD.

NOTE: Depends on https://www.github.com/thesam/debian-linux-kfreebsd-cross

## Goals
* Add kFreeBSD as a cross-compile target in rustc - IN PROGRESS
* Cross-compile "Hello, world!" for kFreeBSD - DONE
* Cross-compile rustc for kFreeBSD - IN PROGRESS
* Run a complete rustc build on kFreeBSD
* Compile cargo on kFreeBSD

## Inspirations
* https://github.com/mneumann/rust-cross-dragonfly
* https://github.com/japaric/ruststrap
