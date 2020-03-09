#!/bin/sh

# Replace compiler-gcc.h with one that works with newer GCC versions.
# Set REPLACE_GCCH=0 to avoid replacing an existing compiler-gcc.h file.
install_gcc_h() {
	_gcch="$builddir/include/linux/compiler-gcc.h"
	if [ -f "$_gcch" ]; then
		if [ "$REPLACE_GCCH" = "0" ]; then
			echo "NOTE: *not* replacing $_gcch, because of REPLACE_GCCH=0"
			return
		else
			echo "NOTE: replacing $_gcch! If your build breaks with 'Please"
			echo "don't include <linux/compiler-gcc.h> directly' or a similar"
			echo "compiler-gcc.h related error, then set"
			echo "  REPLACE_GCCH=0"
			echo "in your kernel APKBUILD at the start of the"
			echo "downstreamkernel_prepare.sh line."
		fi
	fi

	cp -v "/usr/share/devicepkg-dev/compiler-gcc.h" "$_gcch"
}

# Parse arguments
srcdir=$1
builddir=$2
_config=$3
_carch=$4
HOSTCC=$5

if [ -z "$srcdir" ] || [ -z "$builddir" ] || [ -z "$_config" ] ||
	[ -z "$_carch" ]; then
	echo "ERROR: missing argument!"
	echo "Please call downstreamkernel_prepare() with \$srcdir, \$builddir,"
	echo "\$_config, \$_carch (and optionally \$HOSTCC) as arguments."
	exit 1
fi

# Only override HOSTCC if set (to force use of an old gcc)
[ -z "$HOSTCC" ] || HOSTCC="HOSTCC=$HOSTCC"

# Support newer GCC versions
install_gcc_h

# Remove -Werror from all makefiles
makefiles="$(find "$builddir" -type f -name Makefile)
	$(find "$builddir" -type f -name Kbuild)"
for i in $makefiles; do
	sed -i 's/-Werror-/-W/g' "$i"
        sed -i 's/-Werror=/-W/g' "$i"
	sed -i 's/-Werror//g' "$i"
done

# Prepare kernel config ('yes ""' for kernels lacking olddefconfig)
mkdir "$builddir"/out
cp "$srcdir/$_config" "$builddir"/out/.config
# shellcheck disable=SC2086
yes "" | make -C "$builddir" O="$builddir"/out ARCH="$_carch" $HOSTCC oldconfig
