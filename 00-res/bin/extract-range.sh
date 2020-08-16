#!/bin/bash

file="${1}"
pref=${file%%.pdf}
frst="${2:-}"
last="${3:-}"

test -n "${frst}" -a "${frst}" -ge 0 2>/dev/null && OPT1="-dFirstPage=${frst}" || OPT1=""
test -n "${last}" -a "${last}" -ge 0 2>/dev/null && OPT2="-dLastPage=${last}"  || OPT2=""

if test -f "${file}"; then
    TMP=$(mktemp --directory --tmpdir=.)
    cd $TMP
    gs \
        -dBATCH \
        -dNOPAUSE \
        -sDEVICE=png16m \
        -r450 \
        -dUseCropBox ${OPT1} ${OPT2} \
        -sOutputFile=${pref}-%03d.png \
        ../${file}
    cd ..
    # rename
    if test -z "${frst}"; then
        mv -vf ${TMP}/"${pref}"*.png .
        rmdir -v ${TMP}
    else
        for F in ${TMP}/*png; do
            src=$(basename "$F" | sed "s|${pref}-||1;s|.png$||g")
            dst=$(printf "%03d" $(echo ${src}+${frst}-1 | bc))
            mv -vf ${TMP}/"${pref}-${src}.png" ./"${pref}-${dst}.png"
        done
        rmdir -v ${TMP}
    fi
else
    echo "Error: missing file name argument."
fi

