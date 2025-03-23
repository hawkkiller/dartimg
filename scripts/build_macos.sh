#!/bin/bash
cd native
cargo build --release
mkdir -p ../macos/nativelib
cp target/release/libimage_upscale.dylib ../macos/nativelib/
