#!/bin/bash

# Usage: ./run.improve1.sh

set -e

../patch.sh reset
../patch.sh apply catalog

HARNESS="catalog"

CURR_PATH=$(pwd)

P1="${CURR_PATH}/build/1"
P2="${CURR_PATH}/build/2"
P3="${CURR_PATH}/build/3"

mkdir -p $P1
mkdir -p $P2
mkdir -p $P3

# Run the harness 3 times for 4 hours each
python3 ../../infra/helper.py build_fuzzers libxml2

python3 ../../infra/helper.py run_fuzzer --corpus-dir $P1 --sanitizer none \
    libxml2 $HARNESS -- -max_total_time=14400
python3 ../../infra/helper.py run_fuzzer --corpus-dir $P2 --sanitizer none \
    libxml2 $HARNESS -- -max_total_time=14400 -fork=1
python3 ../../infra/helper.py run_fuzzer --corpus-dir $P3 --sanitizer none \
    libxml2 $HARNESS -- -max_total_time=14400 -fork=1

# Merge the corpus and run coverage
cp -r $P2/* $P1
cp -r $P3/* $P1

rm -rf $P2
rm -rf $P3

python3 ../../infra/helper.py build_fuzzers libxml2 --sanitizer coverage

python3 ../../infra/helper.py coverage libxml2 --fuzz-target $HARNESS --corpus-dir $P1

COV_PATH="${CURR_PATH}/coverage_improve1"
rm -rf $COV_PATH && mkdir -p $COV_PATH

cp -r ../../build/out/libxml2/report/* $COV_PATH

echo "Done!"
