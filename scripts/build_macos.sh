#!/bin/bash

set -e  # Exit immediately if any command fails

cd native

# Targets
TARGET_X86=x86_64-apple-darwin
TARGET_ARM=aarch64-apple-darwin

# Ensure both targets are available
rustup target add $TARGET_X86
rustup target add $TARGET_ARM

# Build for both architectures
cargo build --release --target=$TARGET_X86
cargo build --release --target=$TARGET_ARM

# Output paths
X86_LIB=target/$TARGET_X86/release/libimage_upscale.dylib
ARM_LIB=target/$TARGET_ARM/release/libimage_upscale.dylib
UNIVERSAL_LIB=libimage_upscale_universal.dylib

# Combine with lipo into a universal binary
lipo -create -output $UNIVERSAL_LIB $X86_LIB $ARM_LIB
install_name_tool -id "@rpath/libimage_upscale.dylib" $UNIVERSAL_LIB

# Prepare destination
mkdir -p ../macos/nativelib


# Move universal binary
mv $UNIVERSAL_LIB ../macos/nativelib/libimage_upscale.dylib

echo "✅ Universal dylib built and moved to macos/nativelib"
