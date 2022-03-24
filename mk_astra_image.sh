#!/bin/bash -e
#
# Create Astra Linux Docker image
#

# Orel
NAME="orel"
SCRIPT="orel"
REPO="https://mirror.yandex.ru/astra/stable/orel/repository"

# Smolensk
#NAME="smolensk"
#SCRIPT="1.7_x86-64"
#REPO="https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base"

result=$PWD/"$NAME".tar
target=$(mktemp -d --tmpdir "$(basename $0)".XXXXXXXX)

mkdir -m 755 "$target"/dev
mknod -m 600 "$target"/dev/console c 5 1
mknod -m 600 "$target"/dev/initctl p
mknod -m 666 "$target"/dev/full c 1 7
mknod -m 666 "$target"/dev/null c 1 3
mknod -m 666 "$target"/dev/ptmx c 5 2
mknod -m 666 "$target"/dev/random c 1 8
mknod -m 666 "$target"/dev/tty c 5 0
mknod -m 666 "$target"/dev/tty0 c 4 0
mknod -m 666 "$target"/dev/urandom c 1 9
mknod -m 666 "$target"/dev/zero c 1 5

ln -sf sid /usr/share/debootstrap/scripts/"$SCRIPT"

debootstrap --no-check-gpg --variant=minbase \
  --include=apt-transport-https,ca-certificates \
  --components=main,contrib,non-free \
  "$SCRIPT" "$target" "$REPO"

rm -rf "$target"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
rm -rf "$target"/usr/share/{man,doc,info,gnome/help}
rm -rf "$target"/usr/share/cracklib
rm -rf "$target"/usr/share/i18n
rm -rf "$target"/sbin/sln
rm -rf "$target"/etc/ld.so.cache
rm -rf "$target"/var/cache/ldconfig/*

cd "$target"
tar --numeric-owner -cf "$result" .
rm -rf "$target"

docker import "$result" astra-linux/"$NAME":latest
