#!/bin/bash

# Note: its already applied!
# Rescale original to more sizes
# To use it take images from cursors_bak and place them
# into `cursors` directory
# Newly re-sized images will be placed in `res` directory

set -e

[[ -d "res" ]] || mkdir res

for x in cursors/*; do
    [[ -L $x ]] || cp "$x" res/
done

cd res
[[ -d "tmp" ]] || mkdir tmp

for x in *; do
    [[ ! -d $x ]] || continue
    rm -rf tmp/*
    cp "$x" tmp/file
    echo "Working on $x..."
    (
        cd tmp
        xcur2png file
        rm -rf file
        to_ch=$(< file.conf tail -n +2)
        for y in 24 32 48 64 96; do
            echo -ne "$to_ch" | awk "{\$1=$y ; print ;}" | sed "s|file|${y}_file|g" >> new.conf
            for z in file_*.png; do
                # See https://legacy.imagemagick.org/Usage/resize/
                convert -scale ${y}x${y} "$z" "${y}_${z}"
            done
        done
        xcursorgen new.conf > cursor
    )
    cp tmp/cursor "$x"
done

rm -rf tmp

echo "Done! Have a nice day!"
