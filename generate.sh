#!/bin/sh

ROOT="output_"
[ -d "$ROOT" ] && rm -r -- "$ROOT"
mkdir "$ROOT"
ROOT=$(readlink -e "output_") # replace with absolute path
export ROOT
echo "Output directory: $ROOT"

raco make rktree.rkt &

cd src

# mirror directory structure
find . -type d | cpio -dumpl "$ROOT"

find . -type f -name "*.md" -print0  \
    | parallel --env ROOT --null 'pandoc -t html5 --self-contained --smart --toc -c "../css/style.css" -o "$ROOT/{.}.html" {}'

cd "$ROOT"

SITE_INDEX_MD="site-index.md"

wait
racket ../rktree.rkt --title "Site Index" --whitelist .html > "$SITE_INDEX_MD"
pandoc -t html5 --self-contained --smart -c ../css/style.css -o "$ROOT"/site-index.html "$SITE_INDEX_MD"
rm "$SITE_INDEX_MD"

cp -r ../static/ "$ROOT"/.

