#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build_root="$project_root/.build/rodd-macos"
swift_scratch="$build_root/swift"
app="$build_root/Rodd.app"
export CLANG_MODULE_CACHE_PATH="$build_root/clang-module-cache"
export SWIFT_MODULECACHE_PATH="$build_root/swift-module-cache"

cd "$project_root"
swift build \
    --build-system native \
    --disable-sandbox \
    --scratch-path "$swift_scratch" \
    --product Rodd

bin_dir=$(swift build \
    --build-system native \
    --disable-sandbox \
    --scratch-path "$swift_scratch" \
    --show-bin-path)

rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin_dir/Rodd" "$app/Contents/MacOS/Rodd"
cp "$project_root/app/Resources/Info.plist" "$app/Contents/Info.plist"
cp -R "$bin_dir/Rodd_RoddKit.bundle" "$app/Contents/Resources/Rodd_RoddKit.bundle"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"

swift run \
    --build-system native \
    --disable-sandbox \
    --scratch-path "$swift_scratch" \
    RoddChecks

printf '%s\n' "$app"
