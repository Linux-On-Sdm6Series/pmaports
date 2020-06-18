#!/bin/sh -e
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

set -e
DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd "$DIR/.."

# Find CHANGEMEs in APKBUILDs
if grep -qr '(CHANGEME!)' *; then
	echo "ERROR: Please replace '(CHANGEME!)' in the following files:"
	grep --color=always -r '(CHANGEME!)' *
	exit 1
fi

# Shell: shellcheck
sh_files="
	./main/postmarketos-base/firmwareload.sh
	./main/postmarketos-mkinitfs/init.sh.in
	./main/postmarketos-mkinitfs/init_functions.sh
	./main/postmarketos-mkinitfs/mkinitfs.sh
	./main/postmarketos-mkinitfs/mkinitfs_functions.sh
	./main/postmarketos-mkinitfs/mkinitfs_test.sh
	./main/postmarketos-mkinitfs-hook-debug-shell/20-debug-shell.sh
	./main/postmarketos-update-kernel/update-kernel.sh
	./main/mdss-fb-init-hack/mdss-fb-init-hack.sh

	./hybris/lxc-android-9/lxc/mount-android.sh

	$(find . -path './main/postmarketos-ui-*/*.sh')
	$(find . -path './main/postmarketos-ui-*/*.pre-install')
	$(find . -path './main/postmarketos-ui-*/*.post-install')
	$(find . -path './main/postmarketos-ui-*/*.pre-upgrade')
	$(find . -path './main/postmarketos-ui-*/*.post-upgrade')
	$(find . -path './main/postmarketos-ui-*/*.pre-deinstall')
	$(find . -path './main/postmarketos-ui-*/*.post-deinstall')

	$(find . -name '*.trigger')
	$(find . -path './main/devicepkg-dev/*.sh')

	$(find . -path '.gitlab-ci/*.sh')
"
for file in $sh_files; do
	echo "Test with shellcheck: $file"
	cd "$DIR/../$(dirname "$file")"
	shellcheck -e SC1008 -x "$(basename "$file")"
done
