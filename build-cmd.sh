#!/bin/bash

cd "$(dirname "$0")" 

# turn on verbose debugging output for parabuild logs.
set -x

# make errors fatal
set -e

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autobuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

top="$(pwd)"
stage="$(pwd)/stage"

# source directories for various platfor/bit-widths
# replace contents of these folders in the VENDOR branch entirely
# when updating to a more recent version of VLC as per the 
# Linden Lab Mercurial Vendor Strategy.
# https://wiki.lindenlab.com/wiki/Mercurial_Vendor_Branches
VLC_SOURCE_DIR_WIN32="vlc-win32"
VLC_SOURCE_DIR_WIN64="vlc-win64"
VLC_SOURCE_DIR_OSX64="vlc-osx64"

# used in VERSION.txt but common to all bit-widths and platforms
build=${AUTOBUILD_BUILD_ID:=0}

case "$AUTOBUILD_PLATFORM" in
    windows*)
        # choose VLC source dir - different for 32/64 bit versions
        if [ "$AUTOBUILD_ADDRSIZE" = 32 ]
            then VLC_SOURCE_DIR="${VLC_SOURCE_DIR_WIN32}"
            else VLC_SOURCE_DIR="${VLC_SOURCE_DIR_WIN64}"
        fi

        VERSION_HEADER_FILE="${VLC_SOURCE_DIR}/sdk/include/vlc/libvlc_version.h"

        # populate version_file
        cl /DVERSION_HEADER_FILE="\"$VERSION_HEADER_FILE\"" \
           /DVERSION_MAJOR_MACRO="LIBVLC_VERSION_MAJOR" \
           /DVERSION_MINOR_MACRO="LIBVLC_VERSION_MINOR" \
           /DVERSION_REVISION_MACRO="LIBVLC_VERSION_REVISION" \
           /DVERSION_BUILD_MACRO="\"${build}\"" \
           /Fo"$(cygpath -w "$stage/version.obj")" \
           /Fe"$(cygpath -w "$stage/version.exe")" \
           "$(cygpath -w "$top/version.c")"

        "$stage/version.exe" > "$stage/VERSION.txt"
        rm "$stage"/version.{obj,exe}

        # create folders
        mkdir -p "$stage/bin/release"
        mkdir -p "$stage/include/vlc"
        mkdir -p "$stage/lib/release"
        mkdir -p "$stage/LICENSES"

        # binary files
        cp "${VLC_SOURCE_DIR}/libvlc.dll" "$stage/bin/release/"
        cp "${VLC_SOURCE_DIR}/libvlc.dll.manifest" "$stage/bin/release/"
        cp "${VLC_SOURCE_DIR}/libvlccore.dll" "$stage/bin/release/"

        # binary files
        cp -r "${VLC_SOURCE_DIR}/plugins/." "$stage/bin/release/plugins/"

        # include files
        cp -r "${VLC_SOURCE_DIR}/sdk/include/vlc/" "$stage/include/"

        # library files
        cp "${VLC_SOURCE_DIR}/sdk/lib/libvlc.lib" "$stage/lib/release/"
        cp "${VLC_SOURCE_DIR}/sdk/lib/libvlccore.lib" "$stage/lib/release/"

        # license file
        cp "${VLC_SOURCE_DIR}/COPYING.txt" "$stage/LICENSES/vlc.txt"
    ;;

    "darwin")
    ;;

    "linux")
    ;;

    "linux64")
    ;;
esac
pass
