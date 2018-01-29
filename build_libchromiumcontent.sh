#!/usr/local/bin/bash

set -e

export BUILDROOT=`pwd`
set -x
ver=`uname -K`

svnlite co -r456719 svn://svn.freebsd.org/ports/head/www/chromium chromium
cd chromium
patch -p1  < ../chromium_make.diff
make configure DISABLE_LICENSES=1 DISABLE_VULNERABILITIES=yes
cd ..
git clone https://github.com/electron/libchromiumcontent.git
cd libchromiumcontent
git checkout 2bdad00587
if [ "$ver" -lt 1100508 ]
then
	patch -p1 --ignore-whitespace < ../libchromiumcontent_110.diff
else
	patch -p1  --ignore-whitespace < ../libchromiumcontent_111.diff
fi
script/bootstrap
#61.0.3163.100
mv ../chromium/work/chromium-61.0.3163.100 src

patch -p1  < ../libchromiumcontent_patches.diff
rm patches/v8/025-cherry_pick_cc55747.patch*
patch -p1 --ignore-whitespace  -d src/ < ../chromiumv1.diff
patch -p1 --ignore-whitespace  -d src/ < ../libchromiumcontent_bsd.diff

script/update -t x64 --skip_gclient
script/build --no_shared_library -t x64
script/create-dist -c static_library -t x64
