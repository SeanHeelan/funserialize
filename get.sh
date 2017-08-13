#!/usr/bin/env bash

set -e

DOWNLOADS_DIR=`pwd`/downloads
PHP_DST="$DOWNLOADS_DIR/php-src"
AFL_DST="$DOWNLOADS_DIR/afl-2.49b"
PHP_GIT="https://github.com/php/php-src.git"
AFL_VER="2.49b"
AFL_TGZ="afl-2.49b.tgz"
AFL_URL="http://lcamtuf.coredump.cx/afl/releases/$AFL_TGZ"

if [[ ! -d "$DOWNLOADS_DIR" ]]; then
	echo "[+] Creating downloads directory ..."
	mkdir "$DOWNLOADS_DIR"
fi

# PHP
if [[ -d "$PHP_DST" ]]; then 
	echo "[+] PHP's source already exists. Skipping ..."
else 
	echo "[+] Getting PHP ..."
 	git clone "$PHP_GIT" "$PHP_DST"
fi

# AFL
if [[ -d "$AFL_DST" ]]; then
	echo "[+] AFL ($AFL_VER) already exists. Skipping ..."
else
	echo "[+] Getting AFL ($AFL_VER) ..."
	wget --directory-prefix="$DOWNLOADS_DIR" "$AFL_URL"
	tar xf "$DOWNLOADS_DIR/$AFL_TGZ" -C "$DOWNLOADS_DIR"
	rm "$DOWNLOADS_DIR/$AFL_TGZ"
fi

echo "[+] Done"
