#!/bin/bash

# https://www.deutschestextarchiv.de/basisformat.rng
# https://www.deutschestextarchiv.de/basisformat_ms.rng

for url in https://www.deutschestextarchiv.de/basisformat.sch
do
    curl $url --output-dir /Q/src/Eclipse/dtabfvalid/src/main/schematron -O
done
