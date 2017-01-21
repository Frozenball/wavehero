#!/bin/bash
set -e
git checkout master
npm run build
git checkout gh-pages
mv dist/* .
git add index.html static
git commit -m 'Build'
git push
git checkout master