#!/usr/bin/env bash

ORIGIN=`pwd`
AFL_BIN="$ORIGIN/downloads/afl-2.49b/afl-fuzz"
PHP_BIN="$ORIGIN/downloads/php-src/install/bin/php"

# Fuzzer configuration vars
MEM_LIMIT=500
SEEDS="$ORIGIN/aux/seeds/"
DRIVER="$ORIGIN/aux/driver.php"
DICTIONARY="$ORIGIN/aux/dictionary.txt"
OUTPUT_DIR="afl_working_dir"

SCREEN_SESS_NAME="fuzz"
SLAVE_COUNT=1

CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)

set -e
function ret_to_origin {
	cd "$ORIGIN"
}
trap ret_to_origin EXIT

if [[ ! "$#" -eq 2 ]]; then
	echo "[!] Usage: fuzz.sh outputdir slavecount"
	exit 1
fi

OUTPUT_DIR=$1
SLAVE_COUNT=$2

if [[ "$SLAVE_COUNT" -gt "$((CPU_COUNT - 1))" ]]; then
	echo "[!] You do not have enough cores to run that many slaves"
	exit 1
fi

if [[ ! -f "$AFL_BIN" || ! -f "$PHP_BIN" ]]; then
	echo -n "[!] The AFL or PHP binaries are missing. Run get.sh and "
	echo "build.sh first."
	exit 1
fi
	
if ! hash screen 2>/dev/null; then
	echo "[!] GNU screen is not installed"
	exit 1
fi

echo "[+] Starting AFL (using $OUTPUT_DIR as the output directory) ..."
screen -dmAS "$SCREEN_SESS_NAME" -t master \
	"$AFL_BIN" -m "$MEM_LIMIT" -i "$SEEDS" -o \
	"$OUTPUT_DIR" -x "$DICTIONARY" -M -- "$PHP_BIN" "$DRIVER" @@

for i in $(seq 1 "$SLAVE_COUNT"); do
	echo "[+] Starting slave $i ..."
	NAME="slave$i"
	screen -S "$SCREEN_SESS_NAME" -X screen -t "$NAME" \
		"$AFL_BIN" -m "$MEM_LIMIT" -i "$SEEDS" \
		-o "$OUTPUT_DIR" -x "$DICTIONARY" -S "$NAME" -- \
		"$PHP_BIN" "$DRIVER" @@
done

echo "[+] Fuzzing started. Attach via 'screen -r $SCREEN_SESS_NAME'"
