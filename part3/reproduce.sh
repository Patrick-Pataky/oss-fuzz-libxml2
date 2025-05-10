#!/bin/bash

set -e

cd ..

python3 infra/helper.py build_fuzzers libxml2 #--sanitizer none
python infra/helper.py reproduce libxml2 catalog \
    build/out/libxml2/leak-c67be65e77fca0912ba00e113cd81dcb12eebd9a \
    -e ASAN_OPTIONS="detect_leaks=0" \
    -e LSAN_OPTIONS="detect_leaks=0"

# Debug using gdb:
# python ../infra/helper.py shell base-runner-debug
# gdb --args /out/libxml2/catalog /out/libxml2/leak-c67be65e77fca0912ba00e113cd81dcb12eebd9a
