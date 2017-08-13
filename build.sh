#!/usr/bin/env bash

set -e

ORIGIN=`pwd`
AFL_DIR="$ORIGIN/downloads/afl-2.49b"
PHP_DIR="$ORIGIN/downloads/php-src"
PHP_INSTALL_DIR="$PHP_DIR/install"

function ret_to_origin {
	cd "$ORIGIN"
}
trap ret_to_origin EXIT

if [[ ! -d "$AFL_DIR" || ! -d "$PHP_DIR" ]]; then
	echo "[!] AFL or PHP are missing. Run ./get.sh first."
	exit 1
fi

# AFL
function build_afl_clang_fast {
	if hash clang 2>/dev/null; then
		cd "$AFL_DIR/llvm_mode"
		make
	else
		echo -n "[!] clang is not installed. "
		echo "afl-clang-fast will not be built."
	fi
}

if [[ -f "$AFL_DIR/afl-fuzz" ]]; then
	if [[ -f "$AFL_DIR/afl-clang-fast" ]]; then 
		echo "[+] AFL already built. Skipping ..."
	else
		echo "[+] Building afl-clang-fast"
		build_afl_clang_fast
	fi
	cd "$ORIGIN"
else
	echo "[+] Building AFL ..."
	cd "$AFL_DIR"
	make 
	build_afl_clang_fast
	cd "$ORIGIN"
fi

if [[ -f "$AFL_DIR/afl-clang-fast" ]]; then
	AFL_CC="$AFL_DIR/afl-clang-fast"
else
	AFL_CC="$AFL_DIR/afl-gcc"
fi

if [[ ! -f "$AFL_CC" ]]; then
	echo "[!] Something has gone wrong. $AFL_CC does not exist."
	exit 1;
fi

# PHP

if [[ -f "$PHP_INSTALL_DIR/bin/php" ]]; then
	echo "[+] PHP already built. Skipping ..."
	exit 1
fi

echo "[+] Building PHP with $AFL_CC ..."
cd "$PHP_DIR"
./buildconf --force
./configure CC="$AFL_CC" --prefix="$PHP_INSTALL_DIR" --disable-phar

export AFL_USE_ASAN=1
make -j `grep -c ^processor /proc/cpuinfo`
make install-binaries

cd "$ORIGIN"

echo "[+] Done"
