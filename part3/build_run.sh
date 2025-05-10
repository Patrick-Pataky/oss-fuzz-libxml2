#!/bin/bash

set -e

cd ..

mkdir -p build/out/$1

python3 infra/helper.py build_fuzzers libxml2
python3 infra/helper.py run_fuzzer libxml2 $1 --corpus-dir build/out/$1 \
    -e ASAN_OPTIONS="detect_leaks=0" \
    -e LSAN_OPTIONS="detect_leaks=0"
