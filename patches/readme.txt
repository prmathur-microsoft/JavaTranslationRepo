     These instructions are for building nestedvm as it comes from the
nestedvm site http://git.megacz.com/ .  This builds gcc-4.8.3 (and
binutils-2.24 instead of binutils-2.14) and newlib-1.20.0.

     I have patchsets for gcc-3.3.6 with newlib-1.11.0 (stock); gcc-3.3.6
with newlib-1.20.0; gcc-4.8.3 with newlib-1.11.0 (I was using gcc-4.8.2, the
only change is changing the "4.8.2" to "4.8.3" in the Makefile); gcc-4.8.3
with newlib-1.20.0.

     Why?  Newer code will no longer build on gcc-3.3.6 and the
newlib-1.11.0 as well has some headers that have changed on more modern
systems.  But, I found gcc-3.3.6-built djpegspeedtest was a little faster
than gcc-4.8.3-built djpegspeedtest.  Similarly, newlib-1.20.0 has newer
headers and additional functionality, but I've only built djpegspeedtest on
it.

**********

Steps to prepare nestedvm:

Make yourself an empty directory, put nestedvm.zip in there along with the
patchset files and any .gz and .zip files to go along with it.

Files needed:
nestedvm.zip

unzip nestedvm.zip
cd nestedvm
patch -p0 < ../ibex.patch
patch -p0 < ../nestedvm.patch
cp -av ../*.patch upstream/patches/
cp -av ../crt0-override.spec upstream/misc/
patch -p0 < ../nestedvm-upstream-Makefile.patch
cp -av ../newlib-1.20-patches/*.patch upstream/patches/

To build, run 'make'.
see build.sh, this can be used to setup your build environment. To use:

source build.sh
(make or whatever build command... see notes below for further information.)

********************************

Optional steps, if you have the .tar.gz and .zip files pre-downloaded:
binutils-2.24.tar.gz
gcc-4.8.3.tar.gz
newlib-1.20.0.tar.gz
openbsdglob.tar.gz
regex3.8a.tar.gz

mkdir upstream/download
cp -av ../*.gz upstream/download/
cd upstream/tasks/
touch "download_binutils" "download_gcc" "download_newlib"\
     "download_bsdglob" "download_regex"
cd ../../

**********************************
Further optional steps:
Files needed:
classgen.zip
     If I recall correctly, I actually let the script pull this via git, and
zip'ed up the result (in upstream/build/classgen/).

classgen is small but I just have doubts on it's hosting
being as stable as gcc and binutil's so:

cd upstream/build
unzip ../../../classgen.zip
cd ../tasks/
touch "extract_git_classgen"
cd ../../


-----
To build, run 'make'.  
'make nestedvm.jar' builds a nice .jar file.  

     'make djpegspeedtest' builds djpeg and tries to run a speed test.  It
tries to download a JPEG (which doesn't exist on the web server, so it
stores a 404 error message).  If you see a message about the image not being
a jpeg, djpeg is built and working though!  Congratulations!
     
     To actually speed test it, put a jpeg in
"nestedvm/tmp/thebride_1280.jpg" and rerun 'make djpegspeedtest'.

     make speedtest also fails due to missing files, it wants "Arial.TTF"
(capitalized just like that) in "nestedvm/tmp/mspack" .

***********************************

Here is a shell script you can use, I save it as build.sh and can run
'source ./build.sh' before I go in to build some MIPS binaries.  This
is from the Makefiles.  Edit the "export usr=" line to point to your
"nestedvm/upstream/install/".

For a typical Makefile, you can then run something like:

source ./build.sh
(cd to build directory)
LD=$MIPS_LD LDFLAGS=$MIPS_LDFLAGS CFLAGS=$MIPS_CFLAGS CC=$MIPS_CC make

or if it uses GNU autoconf:

source ./build.sh
(cd to build directory)
LD=$MIPS_LD LDFLAGS=$MIPS_LDFLAGS CFLAGS=$MIPS_CFLAGS CC=$MIPS_CC ./configure
make


-----------------------------------------------------

#!/bin/sh
#
# MIPS Settings (don't change these)
#
export flags=-march=mips1
export MIPS_CC=mips-unknown-elf-gcc
export MIPS_CXX=mips-unknown-elf-g++
export MIPS_G77=mips-unknown-elf-g77
export MIPS_PC=mips-unknown-elf-gpc

# Be VERY careful about changing any of these as they can break binary 
# compatibility and create hard to find bugs
export mips_optflags="-O3 \
	-mmemcpy \
	-ffunction-sections -fdata-sections \
	-falign-functions=512 \
	-fno-rename-registers \
	-fno-schedule-insns \
	-fno-delayed-branch"

export MIPS_CXXFLAGS="$MIPS_CFLAGS"
export MIPS_PCFLAGS="$MIPS_CFLAGS --big-endian"
export MIPS_LD="mips-unknown-elf-gcc"
export MIPS_LDFLAGS="$flags --static -Wl,--gc-sections"
export MIPS_STRIP="mips-unknown-elf-strip"
export usr="/home/hwertz/nestedvm-buildable/nestedvm/upstream/install"
export MIPS_CFLAGS="$mips_optflags $flags -I. -I$usr/include/ -I$usr/mips-unknown-elf/incldue/ -Wall -Wno-unused -Werror"
export PATH=$PATH:$usr/bin/

------------------------------------------

     To convert a MIPS binary to use this:

     java -cp $(classpath) org.ibex.nestedvm.Compiler -outformat class -d \
build -o unixruntime (class name) (mips binary name)
     $(classpath) can be nestedvm.jar
     (class name) is something like test.DJPeg for build/tests/DJPeg.class
     (mips binary name) is something like build/tests/DJPeg.mips


------------------------------------------

     What is patched?

     In nestedvm/Makefile, this removes the line "-freduce-all-givs".  This
option was removed in gcc-4.0.  This removes -Werror from MIPS_CFLAGS,
because the nestedvm code has several warnings in gcc-4 that I guess
gcc-3.3.6 didn't detect, but no reason to error out that I could see.  Also
I found gcc-4.6+ ditched crt0.o use, and gcc .specs file is built in, but a
-specs flag allows to specify a .specs file and force gcc to include crt0.o. 



     This re-implements the (very minimal) patches to add "mips-unknown-elf"
format to binutils and gcc, and fixes errors (from gcc-4 being more strict)
with ctype and a few functions for newlib.  I don't know what newlib patches
(if any) mesh with the nestedvm java syscall stuff so I decided I better
stick with newlib-1.1.3 it comes with and fix the compile errors!  The other
patches for gcc appear to be bug-fixes for older gcc, not sure about
gcc-fixes.patch and gcc-fdata-sections-bss.patch (the gcc/config/mips/mips.c
is so disimilar in gcc-4.8.2 I don't know what to patch if bss is still
missing though.)

To build: 
make
make nestedvm.jar

To use:  The compiler is actually just a MIPS cross-compiler, building R2000
code (-march=mips1 -O3 -mmemcpy -ffunction-sections -fdata-sections
-falign-functions=512 -fno-rename-registers -fno-schedule-insns
-fno-delayed-branch -freduce-allgivs)
     arch=mips1 specifies the simplest MIPS instruction set.
     -mmemcpy, says to use "library"-provided memcpy which actually uses
               java memcpy-like call directly with nestedvm.
     The remaining stuff ensures memory alignment to some extent (spanning a
64KB segment is particularly expensive in this Java implementation), and the
-fno-* disable optimizations that help on the pipelined R2000 MIPS but don't
help one bit on a virtual MIPS.

     To convert a MIPS binary to use this:
     java -cp $(classpath) org.ibex.nestedvm.Compiler -outformat class -d
build -o unixruntime (class name) (mips binary name)
     $(classpath) can be nestedvm.jar
     (class name) is something like test.DJPeg for build/tests/DJPeg.class
     (mips binary name) is something like build/tests/DJPeg.mips

==========================================================================
>> I try to install gcc-3.4.6 in ubuntu 10.10 but I've got below error
>>
>> In function ‘open’,
>> ??? inlined from ‘collect_execute’ at ./collect2.c:1537:20:
>> /usr/include/bits/fcntl2.h:51:24: error: call to ‘__open_missing_mode’
>> declared with attribute error: open with O_CREAT in second argument
>> needs 3 arguments
>> make[1]: *** [collect2.o] Error 1
>> make[1]: Leaving directory
>> `/home/esmaeil/Documents/software/gcc-3.4.6/gcc'
>> make: *** [all-gcc] Error 2
>>
>> I did
>> ./configure
>> make
>>
>> and the error is appear after several minutes.
>
> It's a bug in gcc 3.4.6 (you do know that that is a very old release,
> right?).
>
> You can fix it by changing line 1537 of gcc/collect2.c to this:
> ? ? ?redir_handle = open (redir, O_WRONLY | O_TRUNC | O_CREAT, 0666);
========================================================================
Releases:

revision 1.0
Sep 28 2014 -- Initial release.

revision 1.1
Nov. 1 2014 -- Reformatted instructions to remove line numbers. Reordered
               the information so use instructions were not mixed with 
               musings on the internal operation of the software.  Added
               a little extra information.

revision 1.2
Nov 3 2014 -- Forgot to include ibex.patch in gcc-4.8.2 with newlib-1.20.0
              instructions.
