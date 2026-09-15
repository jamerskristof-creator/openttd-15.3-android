#!/usr/bin/env bash
set -euo pipefail

builder_dir="${1:?builder directory required}"
project_root="$(cd "$(dirname "$0")/.." && pwd)"
app_dir="$builder_dir/project/jni/application/openttd"

git -C "$builder_dir" submodule update --init --recursive --depth=1 \
  project/jni/application/openttd \
  project/jni/iconv/src \
  project/jni/sdl2 \
  project/jni/sdl2_image \
  project/jni/sdl2_mixer \
  project/jni/sdl2_ttf

rm -rf "$app_dir/src"
git clone --depth 1 --branch 15.3 https://github.com/OpenTTD/OpenTTD.git "$app_dir/src"
git -C "$app_dir/src" apply "$project_root/patches/openttd-15.3-android.patch"

sed -i "s/^AppVersionCode=.*/AppVersionCode=1530001/" "$app_dir/AndroidAppSettings.cfg"
sed -i 's/^AppVersionName=.*/AppVersionName="15.3-tablet.1"/' "$app_dir/AndroidAppSettings.cfg"
sed -i "s/^LibSdlVersion=.*/LibSdlVersion=2/" "$app_dir/AndroidAppSettings.cfg"
sed -i "s/^MultiABI=.*/MultiABI='arm64-v8a'/" "$app_dir/AndroidAppSettings.cfg"
sed -i 's/openttd-data-14\.1-0\.zip\.xz/openttd-data-15.3-0.zip.xz/' "$app_dir/AndroidAppSettings.cfg"

rm -f "$builder_dir/project/jni/application/src"
ln -s openttd "$builder_dir/project/jni/application/src"

