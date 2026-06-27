#!/usr/bin/env bash
###############################################################################
#
# Foundry Bootstrap
#
# Stage 00a
#
# Normalize git branch and push.
#
###############################################################################

set -euo pipefail

cd ~/work/foundry

echo
echo "======================================================"
echo "Normalize Git Branch"
echo "======================================================"

###############################################################################
# Rename master -> main if needed
###############################################################################

CURRENT="$(git branch --show-current)"

if [ "${CURRENT}" = "master" ]
then
    echo "[INFO] Renaming master -> main"
    git branch -M main
fi

###############################################################################
# Ensure origin exists
###############################################################################

if ! git remote get-url origin >/dev/null 2>&1
then
    git remote add origin git@github.com:project-ilm/foundry.git
fi

###############################################################################
# Push
###############################################################################

git push -u origin "$(git branch --show-current)"

###############################################################################
# GitHub default branch
###############################################################################

gh repo edit project-ilm/foundry \
    --default-branch "$(git branch --show-current)"

###############################################################################
# Show state
###############################################################################

echo
git remote -v

echo
git branch -vv

echo
echo "SUCCESS"

