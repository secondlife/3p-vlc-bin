#!/usr/bin/env bash

cd "$(dirname "$0")" 

# turn on verbose debugging output for parabuild logs.
exec 4>&1; export BASH_XTRACEFD=4; set -x

# make errors fatal
set -e
# bleat on references to undefined shell variables
set -u

if [ -z "$AUTOBUILD" ] ; then 
    exit 1
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

top="$(pwd)"
stage="$(pwd)/stage"

# load autobuild provided shell functions and variables
source_environment_tempfile="$stage/source_environment.sh"
"$AUTOBUILD" source_environment > "$source_environment_tempfile"
. "$source_environment_tempfile"

# source directories for various platfor/bit-widths
# replace contents of these folders in the VENDOR branch entirely
# when updating to a more recent version of VLC as per the 
# Linden Lab Mercurial Vendor Strategy.
# https://wiki.lindenlab.com/wiki/Mercurial_Vendor_Branches
VLC_SOURCE_DIR_WIN32="vlc-win32"
VLC_SOURCE_DIR_WIN64="vlc-win64"
VLC_SOURCE_DIR_DARWIN64="vlc-darwin64"

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

    darwin64)
        # populate version_file
        VERSION_HEADER_FILE="${VLC_SOURCE_DIR_DARWIN64}/include/vlc/libvlc_version.h"
        cc -DVERSION_HEADER_FILE="\"$VERSION_HEADER_FILE\"" \
           -DVERSION_MAJOR_MACRO="LIBVLC_VERSION_MAJOR" \
           -DVERSION_MINOR_MACRO="LIBVLC_VERSION_MINOR" \
           -DVERSION_REVISION_MACRO="LIBVLC_VERSION_REVISION" \
           -DVERSION_BUILD_MACRO="\"${build}\"" \
           -o "$stage/version" "$top/version.c"
        "$stage/version" > "$stage/version.txt"
        rm "$stage/version"

        # create folders
        mkdir -p "$stage/include/vlc"
        mkdir -p "$stage/lib/release"
        mkdir -p "$stage/lib/release/plugins"
        mkdir -p "$stage/LICENSES"

        # include files
        cp -r "${VLC_SOURCE_DIR_DARWIN64}/include/vlc/" "$stage/include/vlc"

        # library files
        cp "${VLC_SOURCE_DIR_DARWIN64}/lib"/libvlc*.dylib "$stage/lib/release/"

        # plugins
        cp "${VLC_SOURCE_DIR_DARWIN64}/plugins/"lib*_plugin".dylib" "$stage/lib/release/plugins/"
        cp "${VLC_SOURCE_DIR_DARWIN64}/plugins/plugins.dat" "$stage/lib/release/plugins/"

        # license file
        cp "${VLC_SOURCE_DIR_DARWIN64}/COPYING.txt" "$stage/LICENSES/vlc.txt"
    ;;

    "linux")
    ;;

    "linux64")
    ;;
esac
