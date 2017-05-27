#!/bin/bash

ARCH=$1
BITS=$2

# Die on any error for Travis CI to automatically retry:
set -e

download_dir="${0%/*}/download/windows"

mkdir -p "${download_dir}"
cd "${download_dir}"

if [ ! -d $ARCH ]; then
	mkdir $ARCH
fi

function get()
{
	if which nuget >/dev/null; then
		nuget install $1 -Version $2 -ExcludeVersion
	else
		../../noget.sh $1 $2
	fi
}

if [ ! -f $ARCH/SDL2.dll ]; then
	echo "Fetching SDL2 from libsdl.org"
	wget https://www.libsdl.org/release/SDL2-2.0.5-win32-$ARCH.zip
	unzip SDL2-2.0.5-win32-$ARCH.zip SDL2.dll
	mv SDL2.dll ./$ARCH/SDL2.dll
	rm SDL2-2.0.5-win32-$ARCH.zip
fi

if [ ! -f $ARCH/freetype6.dll ]; then
	echo "Fetching FreeType2 from NuGet"
	get SharpFont.Dependencies 2.6.0
	cp ./SharpFont.Dependencies/bin/msvc9/$ARCH/freetype6.dll ./$ARCH/freetype6.dll
	rm -rf SharpFont.Dependencies
fi

if [ ! -f $ARCH/lua51.dll ]; then
	echo "Fetching Lua 5.1 from NuGet"
	get lua.binaries 5.1.5
	cp ./lua.binaries/bin/win$BITS/dll8/lua5.1.dll ./$ARCH/lua51.dll
	rm -rf lua.binaries
fi

if [ ! -f $ARCH/soft_oal.dll ]; then
	echo "Fetching OpenAL Soft from NuGet"
	get OpenAL-Soft 1.16.0
	cp ./OpenAL-Soft/bin/Win$BITS/soft_oal.dll ./$ARCH/soft_oal.dll
	rm -rf OpenAL-Soft
fi
