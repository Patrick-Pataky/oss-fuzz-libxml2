# OSS-Fuzz: Continuous Fuzzing for Open Source Software

## Setup

1. Clone the submodule (the libxml2 library):
```bash
git submodule update --init --recursive
```

2. Build the libxml2 image:
```bash
python3 infra/helper.py build_image libxml2
```

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

You can rebuild the fuzzers with the following command. It uses the source code (for the fuzzers) in ./projects/libxml2 directory:

```bash
python3 infra/helper.py build_fuzzers libxml2 --mount_path $(pwd)/projects/libxml2/libxml2
```

Then you can run the fuzzer you have modified:
```bash
python3 infra/helper.py run_fuzzer libxml2 <fuzzer> --corpus-dir build/out/corpus
```
