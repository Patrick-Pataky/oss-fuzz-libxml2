python3 ../infra/helper.py build_fuzzers libxml2
mkdir ../build
mkdir ../build/out
mkdir ../build/out/part1Seed
cp -av ./seeds/xml/* ../build/out/part1Seed/
python3 ../infra/helper.py run_fuzzer libxml2 xml --corpus-dir=build/out/part1Seed