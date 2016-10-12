git clone http://nestedvm.ibex.org/nestedvm.git/
cd nestedvm
pwd
patch -p0 < ../patches/ibex.patch
patch -p0 < ../patches/nestedvm.patch
cp -av ../patches/*.patch upstream/patches/
cp -av ../patches/crt0-override.spec upstream/misc/
patch -p0 < ../patches/nestedvm-upstream-Makefile.patch

ls upstream/build
mkdir -p upstream/build/regex upstream/build/regex/fake
ls upstream/build
cp -av ../regex upstream/build/regex
ls upstream/build/regex

