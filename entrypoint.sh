#!/bin/bash

REPO_FILES=('zencjktty.db.tar.xz'
            'zencjktty.files.tar.xz')
PACKAGE="linux-zen"
GPG_KEYS=('ABAF11C65A2970B130ABE3C479BE3E4300411886'
          '647F28654894E3BD457199BE38DBBDC86092693E'
          '83BC8889351B5DEBBB68416EB8AC08600F108CDF')
        
function builder_do() {
    sudo -u builduser bash -c "$@"
}

pacman-key --init
pacman-key --populate
pacman -Syu --noconfirm
pacman -S --noconfirm --needed wget git llvm clang
rm -rf /var/cache/pacman/pkg/*

useradd -m -s /bin/bash builduser
chown builduser:builduser -R /build
passwd -d builduser
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers
git config --global --add safe.directory /build

cd /build || exit 1

git clone https://gitlab.archlinux.org/archlinux/packaging/packages/${PACKAGE}.git

chown builduser:builduser -R $PACKAGE 

cd $PACKAGE || exit 1

builder_do "git reset --hard 4ed3fe6"

for GPG_KEY in "${GPG_KEYS[@]}"
do
    builder_do "gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${GPG_KEY}"
done

echo "替换PKGBUILD"
builder_do "mv /build/PKGBUILD ./"

builder_do "env HOME=/home/builduser makepkg -sc --noconfirm"

find ./ -name "*.pkg.tar.*" -exec mv {} /build/ \;

cd /build || exit 1

for REPO_FILE in "${REPO_FILES[@]}"
do
    wget --quiet "https://github.com/Bryan2333/arch-zen-cjktty/releases/download/packages/${REPO_FILE}"
done

repo-add -n zencjktty.db.tar.xz ./*.pkg.tar.*
