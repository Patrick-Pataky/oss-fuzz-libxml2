#!/bin/bash

set -e

cd ..

python3 infra/helper.py build_fuzzers libxml2 --sanitizer coverage
python3 infra/helper.py coverage libxml2 --fuzz-target $1 --corpus-dir build/out/$1
