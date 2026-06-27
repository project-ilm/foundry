#!/usr/bin/env bash
###############################################################################
#
# Foundry Publication Pipeline
#
# Stage 01
#
# Generic research artifact publisher
#
# Future targets
#
# Git
# GitHub
# GitHub Releases
# GitHub Pages
# Zenodo
# Misty DOI
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# CONFIG
###############################################################################

FOUNDRY="${HOME}/work/foundry"

ORG="project-ilm"

REPO="foundry"

DEFAULT_BRANCH="main"

VERSION="v0.1.0"

AUTHOR="Abhishek Choudhary"

ORGNAME="AyeCNSe · AyeAI ∴ AyeAM"

LICENSE="All rights reserved."

###############################################################################

usage(){

cat <<USAGE

Usage

publish_artifact.sh \\
    --file poster.pdf \\
    --title "Foundry" \\
    --type poster \\
    --version v0.1.0

Options

--file
--title
--type
--version
--dry-run

USAGE

exit 1

}

###############################################################################

FILE=""
TITLE=""
TYPE=""
DRYRUN=0

while [ $# -gt 0 ]
do

case "$1" in

--file)

FILE="$2"

shift 2
;;

--title)

TITLE="$2"

shift 2
;;

--type)

TYPE="$2"

shift 2
;;

--version)

VERSION="$2"

shift 2
;;

--dry-run)

DRYRUN=1

shift
;;

*)

echo "Unknown option $1"

usage

;;

esac

done

###############################################################################

[ -n "${FILE}" ] || usage

[ -n "${TITLE}" ] || usage

[ -n "${TYPE}" ] || usage

###############################################################################

if [ ! -f "${FILE}" ]
then

echo

echo "Artifact not found"

echo "${FILE}"

echo

exit 1

fi

###############################################################################

BASENAME="$(basename "${FILE}")"

EXT="${BASENAME##*.}"

DATE="$(date +%F)"

TARGET="${FOUNDRY}/artifacts/${TYPE}/${VERSION}"

mkdir -p "${TARGET}"

cp -v "${FILE}" "${TARGET}/${BASENAME}"

###############################################################################
# README
###############################################################################

cat > "${TARGET}/README.md" <<EOT
# ${TITLE}

Version

${VERSION}

Author

${AUTHOR}

Organisation

${ORGNAME}

Date

${DATE}

Artifact Type

${TYPE}

Copyright (C) 1993-2026 ${AUTHOR}

${LICENSE}

EOT

###############################################################################
# Metadata
###############################################################################

cat > "${TARGET}/metadata.json" <<EOT
{
    "title":"${TITLE}",
    "version":"${VERSION}",
    "author":"${AUTHOR}",
    "organisation":"${ORGNAME}",
    "type":"${TYPE}",
    "date":"${DATE}",
    "filename":"${BASENAME}"
}
EOT

###############################################################################
# CITATION
###############################################################################

if [ ! -f "${FOUNDRY}/CITATION.cff" ]
then

cat > "${FOUNDRY}/CITATION.cff" <<EOT
cff-version: 1.2.0

title: "${TITLE}"

authors:

- family-names: Choudhary
  given-names: Abhishek

version: "${VERSION}"

license: Proprietary

EOT

fi

###############################################################################
# codemeta
###############################################################################

if [ ! -f "${FOUNDRY}/codemeta.json" ]
then

cat > "${FOUNDRY}/codemeta.json" <<EOT
{
 "@context":"https://doi.org/10.5063/schema/codemeta-2.0",
 "@type":"SoftwareSourceCode",
 "name":"Foundry",
 "author":"${AUTHOR}",
 "version":"${VERSION}"
}
EOT

fi

###############################################################################
# GIT
###############################################################################

cd "${FOUNDRY}"

git add .

git commit -m "Publish ${TYPE}: ${TITLE} (${VERSION})" || true

###############################################################################
# PUSH
###############################################################################

BRANCH="$(git branch --show-current)"

echo

echo "Branch : ${BRANCH}"

if [ "${DRYRUN}" -eq 0 ]
then

git push origin "${BRANCH}"

fi

###############################################################################
# TAG
###############################################################################

if [ "${DRYRUN}" -eq 0 ]
then

git tag -f "${VERSION}"

git push origin "${VERSION}" --force

fi

###############################################################################
# RELEASE
###############################################################################

if [ "${DRYRUN}" -eq 0 ]
then

gh release view "${VERSION}" >/dev/null 2>&1 ||

gh release create "${VERSION}" \
    --title "${TITLE}" \
    --notes "Automated Foundry publication"

gh release upload "${VERSION}" \
    "${TARGET}/${BASENAME}" \
    --clobber

fi

###############################################################################
# NEXT STAGES
###############################################################################

echo
echo "=============================================================="
echo "READY FOR"
echo "=============================================================="
echo
echo "Stage 02  GitHub Pages"
echo "Stage 03  Zenodo deposition"
echo "Stage 04  Misty DOI"
echo "Stage 05  DOI synchronization"
echo

