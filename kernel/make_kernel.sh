#!/bin/sh

set -e

# script exit codes:
#   1: missing utility
#   5: invalid file hash
#   7: use screen session
#   8: superuser disallowed

config_fixups() {
    local lpath=$1

    # enable rockchip sfc
    echo 'CONFIG_SPI_ROCKCHIP_SFC=m' >> "$lpath/arch/arm64/configs/defconfig"

    # enable realtek pci wireless
    echo 'CONFIG_RTW88=m' >> "$lpath/arch/arm64/configs/defconfig"
    echo 'CONFIG_RTW88_8822CE=m' >> "$lpath/arch/arm64/configs/defconfig"
    echo 'CONFIG_RTW88_8723DE=m' >> "$lpath/arch/arm64/configs/defconfig"
    echo 'CONFIG_RTW88_8821CE=m' >> "$lpath/arch/arm64/configs/defconfig"

    #echo 6 > "$lpath/.version"
}

main() {
    local linux='https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-6.6-rc4.tar.gz'
    local lxsha='f5bfa3cb0d889f136b92b88e31013e34a31fb66d7733d38ea119bdb6e8129f59'

    local lf="$(basename "$linux")"
    local lv="$(echo "$lf" | sed -nE 's/linux-(.*)\.tar\..z/\1/p')"

    if [ '_clean' = "_$1" ]; then
        echo "\n${h1}cleaning...${rst}"
        rm -fv *.deb
        rm -rfv kernel-$lv/*.deb
        rm -rfv kernel-$lv/*.buildinfo
        rm -rfv kernel-$lv/*.changes
        rm -rf "kernel-$lv/linux-$lv"
        echo '\nclean complete\n'
        exit 0
    fi

    check_installed 'screen' 'build-essential' 'python3' 'flex' 'bison' 'pahole' 'debhelper'  'bc' 'rsync' 'libncurses-dev' 'libelf-dev' 'libssl-dev' 'lz4' 'zstd'

    if [ -z $STY ]; then
        echo 'reminder: run from a screen session, this can take a while...'
        exit 7
    fi

    mkdir -p "kernel-$lv"
    [ -f "kernel-$lv/$lf" ] || wget "$linux" -P "kernel-$lv"

    if [ "_$lxsha" != "_$(sha256sum "kernel-$lv/$lf" | cut -c1-64)" ]; then
        echo "invalid hash for linux source file: $lf"
        exit 5
    fi

    if [ ! -d "kernel-$lv/linux-$lv" ]; then
        tar -C "kernel-$lv" -xavf "kernel-$lv/$lf"

        local patch
        for patch in patches/*.patch; do
            patch -p1 -d "kernel-$lv/linux-$lv" -i "../../$patch"
        done
    fi

    # build
    if [ '_inc' != "_$1" ]; then
        echo "\n${h1}configuring source tree...${rst}"
        make -C "kernel-$lv/linux-$lv" mrproper
        [ -z "$1" ] || echo "$1" > "kernel-$lv/linux-$lv/.version"
        config_fixups "kernel-$lv/linux-$lv"
        make -C "kernel-$lv/linux-$lv" ARCH=arm64 defconfig
    fi

    echo "\n${h1}beginning compile...${rst}"
    rm -f linux-image-*.deb
    local kv="$(make --no-print-directory -C "kernel-$lv/linux-$lv" kernelversion)"
    local bv="$(expr "$(cat "kernel-$lv/linux-$lv/.version" 2>/dev/null || echo 0)" + 1 2>/dev/null)"
    export SOURCE_DATE_EPOCH="$(stat -c %Y "kernel-$lv/linux-$lv/README")"
    export KDEB_CHANGELOG_DIST='testing'
    export KBUILD_BUILD_TIMESTAMP="Debian $kv-$bv $(date -d @$SOURCE_DATE_EPOCH +'(%Y-%m-%d)')"
    export KBUILD_BUILD_HOST='github.com/inindev'
    export KBUILD_BUILD_USER='linux-kernel'
    export KBUILD_BUILD_VERSION="$bv"

    nice make -C "kernel-$lv/linux-$lv" -j"$(nproc)" CC="$(readlink /usr/bin/gcc)" bindeb-pkg KBUILD_IMAGE='arch/arm64/boot/Image' LOCALVERSION="-$bv-arm64"
    echo "\n${cya}kernel package ready${mag}"
    ln -sfv "kernel-$lv/linux-image-$kv-$bv-arm64_$kv-${bv}_arm64.deb"
    echo "${rst}"
}

check_installed() {
    local todo
    for item in "$@"; do
        dpkg -l "$item" 2>/dev/null | grep -q "ii  $item" || todo="$todo $item"
    done

    if [ ! -z "$todo" ]; then
        echo "this script requires the following packages:${bld}${yel}$todo${rst}"
        echo "   run: ${bld}${grn}sudo apt update && sudo apt -y install$todo${rst}\n"
        exit 1
    fi
}

rst='\033[m'
bld='\033[1m'
red='\033[31m'
grn='\033[32m'
yel='\033[33m'
blu='\033[34m'
mag='\033[35m'
cya='\033[36m'
h1="${blu}==>${rst} ${bld}"

if [ 0 -eq $(id -u) ]; then
    echo 'do not compile as root'
    exit 8
fi

cd "$(dirname "$(realpath "$0")")"
main "$@"

