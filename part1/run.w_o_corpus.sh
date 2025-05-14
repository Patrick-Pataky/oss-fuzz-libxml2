python3 ../infra/helper.py build_fuzzers libxml2
mkdir ../build
mkdir ../build/out
mkdir ../build/out/part1NoSeed
rm -rf ../build/out/liblxm2/xml_seed_corpus.zip
python3 ../infra/helper.py run_fuzzer libxml2 xml --corpus-dir=build/out/part1NoSeed