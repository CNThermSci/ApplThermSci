#!/bin/bash

# Background slide for composition
atop=${1:-Slide2.png}

# Constants
PRE='X2001-en-PRES'
geo='+486+174'

# Functions
function getFrames(){
    echo ${PRE}*png | sed "s|${PRE}-||g;s|\.png||g"
}

# Execution
cd "${PRE}.png"
for _F in $(getFrames); do
    echo "Composing (${atop}, ${PRE}-${_F}.png) --> slide-${_f}.png"
    _f=$(printf "%03d" $_F)
    composite \
        -geometry "${geo}" \
        ./${PRE}-${_F}.png \
        ../${atop} \
        ./slide-${_f}.png
done
cd - >/dev/null

