# OSS-Fuzz: Continuous Fuzzing for Open Source Software

## Setup

1. Clone the submodule (the libxml2 library):
```bash
git clone https://github.com/Patrick-Pataky/oss-fuzz-libxml2.git
cd oss-fuzz-libxml2
git submodule update --init --recursive
cd projects/libxml2/libxml2 && git reset --hard 1039cd53
cd -
```

2. Build the libxml2 image:
```bash
python3 infra/helper.py build_image libxml2
```

## Report

The report is available at `report.pdf` in the root directory.

## Parts

### part1

```bash
cd part1
sh run.w_corpus.sh
sh run.w_o_corpus.sh
```

And get the coverage:
```bash
python3 ../infra/helper.py build_fuzzers --sanitizer coverage libxml2
python3 ../infra/helper.py coverage libxml2 --corpus-dir build/out/part1Seed/ --fuzz-target xml
python3 ../infra/helper.py coverage libxml2 --corpus-dir build/out/part1NoSeed/ --fuzz-target xml
```

### part3

Follow the instructions in `part3/README.md` to run the fuzzers.

### part4

Follow the instructions in `part4/README.md`.

## General Commands

The fuzzers are built from the `libxml2/fuzz/` directory.

3. Build the fuzzers:
This command uses the source code (for the fuzzers) already inside the Docker image:
```bash
python3 infra/helper.py build_fuzzers libxml2
mkdir -p build/out/corpus
```

4. Run a fuzzer:
```bash
python3 infra/helper.py run_fuzzer libxml2 <fuzzer> --corpus-dir build/out/corpus
```

5. Generate coverage:
```bash
python3 infra/helper.py build_fuzzers libxml2 --sanitizer coverage
python3 infra/helper.py coverage libxml2 --fuzz-target <fuzzer> --corpus-dir build/out/corpus
```

## Modifying the harnesses
After modifying the harnesses, first commit the changes to the `libxml2` submodule. Then, generate a patch file to be able to reproduce the changes:
```bash
./patch.sh generate
```

To apply a patch from another person, use the following command:
```bash
./patch.sh apply <patch_file>
# or apply all patches:
./patch.sh apply
```

To reset all patches, use:
```bash
./patch.sh reset
```

You can rebuild the fuzzers with the following command. It uses the source code (for the fuzzers) in ./projects/libxml2 directory:

```bash
python3 infra/helper.py build_fuzzers libxml2 --mount_path $(pwd)/projects/libxml2/libxml2
```

Then you can run the fuzzer you have modified:
```bash
python3 infra/helper.py run_fuzzer libxml2 <fuzzer> --corpus-dir build/out/corpus
```
