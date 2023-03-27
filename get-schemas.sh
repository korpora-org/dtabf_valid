#!/bin/sh

# validator downloads newest RNG on start.
# would be:
#
# https://www.deutschestextarchiv.de/basisformat.rng
# https://www.deutschestextarchiv.de/basisformat_ms.rng

for url in https://www.deutschestextarchiv.de/basisformat.sch
do
    curl "$url" --output-dir src/main/schematron -O
done
