#!/bin/bash

function builder_do() {
    sudo -u builduser bash -c "$@"
}

pacman-key --init
pacman-key --populate
pacman -Syu --noconfirm
pacman -S --noconfirm --needed base-devel wget git llvm clang
rm -rf /var/cache/pacman/pkg/*

useradd -m -s /bin/bash builduser
chown builduser:builduser -R /build
passwd -d builduser
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
git config --global --add safe.directory /build

cd /build || exit 1

git clone https://gitlab.archlinux.org/archlinux/packaging/packages/linux-zen.git

chown builduser:builduser -R linux-zen

cd linux-zen || exit 1

builder_do "git reset --hard 0f6bda4"

for KEYFILE in keys/pgp/*.asc
do 
    builder_do "gpg --import $KEYFILE"
done

echo "替换PKGBUILD"
builder_do "mv /build/PKGBUILD ./"

builder_do "env HOME=/home/builduser makepkg -sc --noconfirm"

find ./ -name "*.pkg.tar.*" -exec mv {} /build/ \;
