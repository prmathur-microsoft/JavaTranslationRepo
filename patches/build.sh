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
export usr="/home/prmathur/Repo/nestedvm_new/nestedvm/upstream/install"
export MIPS_CFLAGS="$mips_optflags $flags -I. -I$usr/include/ -I$usr/mips-unknown-elf/incldue/ -Wall -Wno-unused -Werror"
export PATH=$PATH:$usr/bin/
