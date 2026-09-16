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
printf '15.3\t20260404\t0\t14ec60f248547d4d062a1160f0fc26d742319888\t1\t1\t2026\n' > "$app_dir/src/.ottdrev"

sed -i "s/^AppVersionCode=.*/AppVersionCode=1530002/" "$app_dir/AndroidAppSettings.cfg"
sed -i 's/^AppVersionName=.*/AppVersionName="15.3-tablet.2"/' "$app_dir/AndroidAppSettings.cfg"
sed -i "s/^LibSdlVersion=.*/LibSdlVersion=2/" "$app_dir/AndroidAppSettings.cfg"
sed -i "s/^MultiABI=.*/MultiABI='arm64-v8a'/" "$app_dir/AndroidAppSettings.cfg"
sed -i "s/^GooglePlayGameServicesId=.*/GooglePlayGameServicesId=n/" "$app_dir/AndroidAppSettings.cfg"
sed -i 's/openttd-data-14\.1-0\.zip\.xz/openttd-data-15.3-0.zip.xz/' "$app_dir/AndroidAppSettings.cfg"
sed -i 's/^VER=14\.1-0$/VER=15.3-0/' "$app_dir/pack-data.sh"

# With SDL2, changeAppSettings.sh uses SDL2's own minimal manifest template
# instead of project/AndroidManifestTemplate.xml. That template does not
# request network access, so Android blocks OpenTTD's content server and
# multiplayer sockets even though AccessInternet=y in AndroidAppSettings.cfg.
sdl2_manifest="$builder_dir/project/jni/sdl2/android-project/app/src/main/AndroidManifest.xml"
if ! grep -q 'android.permission.INTERNET' "$sdl2_manifest"; then
  sed -i '/<application/i\    <uses-permission android:name="android.permission.INTERNET" />' "$sdl2_manifest"
fi

rm -f "$builder_dir/project/jni/application/src"
ln -s openttd "$builder_dir/project/jni/application/src"

# The upstream OpenSSL helper patches 32-bit generated headers into one
# multi-architecture header. Our APK is arm64-only, so its already-correct
# generated 64-bit header must be kept as-is.
sed -i '/patch -p1 < opensslconf.h.patch/c\[ "$ARCH_LIST" = "arm64-v8a" ] || patch -p1 < opensslconf.h.patch || exit 1' \
  "$builder_dir/project/jni/openssl/compile.sh"
