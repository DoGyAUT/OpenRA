#!/bin/bash
# OpenRA master packaging script

if [ $# -ne "2" ]; then
    echo "Usage: `basename $0` version outputdir"
    exit 1
fi

# Resolve the absolute source path from the location of this script
SRCDIR=$(readlink -f $(dirname $0)/../)
BUILTDIR="${SRCDIR}/packaging/built"
TAG=$1
OUTPUTDIR=$(readlink -f $2)

# Build the code and push the files into a clean dir
cd "$SRCDIR"
mkdir packaging/built
mkdir packaging/built/mods
make package

# Remove the mdb files that are created during `make`
find . -path "*.mdb" -delete

test -e Changelog.md && rm Changelog.md
curl -s -L -O https://raw.githubusercontent.com/wiki/OpenRA/OpenRA/Changelog.md

markdown Changelog.md > packaging/built/CHANGELOG.html
rm Changelog.md
markdown README.md > packaging/built/README.html
markdown CONTRIBUTING.md > packaging/built/CONTRIBUTING.html
markdown DOCUMENTATION.md > packaging/built/DOCUMENTATION.html
markdown Lua-API.md > packaging/built/Lua-API.html

# List of files that are packaged on all platforms
FILES=('OpenRA.Game.exe' 'OpenRA.Game.exe.config' 'OpenRA.Utility.exe' 'OpenRA.Server.exe'
'OpenRA.Platforms.Default.dll' \
'lua' 'glsl' 'mods/common' 'mods/ra' 'mods/cnc' 'mods/d2k' 'mods/modcontent' 'mods/all' 'mods/ts' 'mods/as' \
'AUTHORS' 'COPYING' \
'global mix database.dat' 'GeoLite2-Country.mmdb.gz')

echo "Copying files..."
for i in "${FILES[@]}"; do
    cp -R "${i}" "packaging/built/${i}" || exit 3
done

# SharpZipLib for zip file support
cp thirdparty/download/ICSharpCode.SharpZipLib.dll packaging/built

# FuzzyLogicLibrary for improved AI
cp thirdparty/download/FuzzyLogicLibrary.dll packaging/built

# SharpFont for FreeType support
cp thirdparty/download/SharpFont* packaging/built

# SDL2-CS
cp thirdparty/download/SDL2-CS* packaging/built

# OpenAL-CS
cp thirdparty/download/OpenAL-CS* packaging/built

# Open.NAT for UPnP support
cp thirdparty/download/Open.Nat.dll packaging/built

# Eluant (Lua integration)
cp thirdparty/download/Eluant* packaging/built

# GeoIP database access
cp thirdparty/download/MaxMind.Db.dll packaging/built

# global chat
cp thirdparty/download/SmarIrc4net.dll packaging/built

# local server discovery
cp thirdparty/download/rix0rrr.BeaconLib.dll packaging/built

# Windows only .dlls
cp thirdparty/download/windows/freetype6.dll packaging/built
cp thirdparty/download/windows/lua51.dll packaging/built
cp thirdparty/download/windows/SDL2.dll packaging/built
cp thirdparty/download/windows/soft_oal.dll packaging/built

# Mono only files
cp packaging/Eluant.dll.config packaging/built

cd packaging
echo "Creating package..."
pushd $BUILTDIR > /dev/null
zip -qr $OUTPUTDIR/OpenRA-$TAG.zip *
popd > /dev/null

echo "Package build done."

rm -rf $BUILTDIR
