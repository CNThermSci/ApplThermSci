#!/bin/bash

for D in $(find . -name '*-pt.tex' | sed 's|/[AC].*$||g'); do
    echo "$D" | center 72 | frame 72; sleep 1
    cd $D
    for A in 1 2; do
        touch *-pt.tex
        make *-PRES.pdf
    done
    cd -
    git commit -am "UPD recompiled $D PRES pdf's"
done
git push

