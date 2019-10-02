#!/bin/bash

set -x

cd dest

echo "www.manageiq.org" > CNAME

git config --global user.name "ManageIQ Bot"
git config --global user.email "noreply@manageiq.org"

git clone --bare --branch master --depth 5 https://miq-bot:${GITHUB_TOKEN}@github.com/ManageIQ/manageiq.github.io .git
git config core.bare false
git add -A
git commit -m "${TRAVIS_COMMIT_MESSAGE}"
git push origin master
