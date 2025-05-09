#!/bin/bash

set -e

cd ..

python3 infra/helper.py build_fuzzers libxml2
python infra/helper.py reproduce libxml2 catalog \
    build/out/libxml2/leak-c67be65e77fca0912ba00e113cd81dcb12eebd9a
