#!/usr/bin/env bash
###############################################################################
#
# Foundry Bootstrap
#
# Stage 00
#
# Initialize local repository and GitHub remote.
#
###############################################################################

set -euo pipefail

ORG="project-ilm"
REPO="foundry"

FOUNDRY="${HOME}/work/foundry"

cd "${FOUNDRY}"

###############################################################################

echo
echo "======================================================"
echo "Foundry Git Initialization"
echo "======================================================"

###############################################################################
# Verify gh
###############################################################################

gh auth status >/dev/null

###############################################################################
# Initialize git if required
###############################################################################

if [ ! -d .git ]
then
    echo "[INIT] git repository"
    git init
fi

###############################################################################
# Configure branch
###############################################################################

CURRENT="$(git branch --show-current 2>/dev/null || true)"

if [ -z "${CURRENT}" ]
then
    git checkout -B main
fi

###############################################################################
# Configure origin
###############################################################################

if git remote get-url origin >/dev/null 2>&1
then
    echo "[OK] origin exists"
else

    if gh repo view "${ORG}/${REPO}" >/dev/null 2>&1
    then
        echo "[OK] GitHub repo exists"

    else

        echo "[CREATE] GitHub repository"

        gh repo create \
            "${ORG}/${REPO}" \
            --public \
            --description "Canonical engineering operating model" \
            --disable-wiki

    fi

    git remote add origin \
        "git@github.com:${ORG}/${REPO}.git"

fi

###############################################################################
# Initial commit if required
###############################################################################

git add .

if ! git diff --cached --quiet
then

    git commit -m "Initial Foundry bootstrap"

fi

###############################################################################
# Push
###############################################################################

git push -u origin main

###############################################################################

echo
echo "======================================================"
echo "SUCCESS"
echo "======================================================"

echo
git remote -v

echo
git branch -vv

