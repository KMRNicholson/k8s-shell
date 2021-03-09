#!/bin/sh

STEPS=(
    'prepare_install'
    'install'
    'post_install'
)

for step in "${STEPS[@]}"
do
    cd $step
    . run.sh
    cd ..
done