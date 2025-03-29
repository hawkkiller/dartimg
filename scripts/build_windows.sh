#!/bin/bash
cd native
# Cross-compile for Windows target
cargo build --release --target x86_64-pc-windows-gnu
mkdir -p ../windows/nativelib
cp target/x86_64-pc-windows-gnu/release/image_upscale.dll ../windows/nativelib/
