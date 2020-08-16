#!/bin/bash

test -d ../text || mkdir -p ../text

for _f in *png; do
    touch ../text/${_f%%.png}.txt
done

