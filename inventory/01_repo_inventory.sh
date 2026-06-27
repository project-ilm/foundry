#!/usr/bin/env bash
###############################################################################
#
# Foundry Inventory Stage 01
#
# Repository Inventory
#
# Linux / WSL
#
# READ ONLY
#
###############################################################################

set -uo pipefail

FOUNDRY="${HOME}/work/foundry"

source "${FOUNDRY}/lib/common.sh"

OUTROOT="${HOME}/work/inventory/$(date +%F)"
mkdir -p "${OUTROOT}"

JSON="${OUTROOT}/repos.json"
CSV="${OUTROOT}/repos.csv"
MD="${OUTROOT}/repos.md"
HTML="${OUTROOT}/repos.html"

TMP="$(mktemp)"

echo "[" > "${JSON}"

FIRST=1

find "${HOME}/work" -type d -name ".git" | sort | while read GITDIR
do

ROOT="$(dirname "${GITDIR}")"

cd "${ROOT}" || continue

NAME="$(basename "${ROOT}")"

TOP="$(git rev-parse --show-toplevel 2>/dev/null || true)"

REMOTE="$(git remote get-url origin 2>/dev/null || echo "")"

BRANCH="$(git branch --show-current 2>/dev/null || echo "")"

DEFAULT="$(git remote show origin 2>/dev/null | sed -n '/HEAD branch/s/.*: //p')"

DIRTY="false"

git diff --quiet >/dev/null 2>&1 || DIRTY="true"

UNTRACKED="$(git ls-files --others --exclude-standard | wc -l)"

LAST="$(git log -1 --format='%h %ci %s' 2>/dev/null)"

SIZE="$(du -sh . 2>/dev/null | cut -f1)"

STATUS="$(git status --short | wc -l)"

SUBMODULES="$(test -f .gitmodules && grep path .gitmodules | wc -l || echo 0)"

URLTYPE="unknown"

case "${REMOTE}" in

git@github.com:*)
    URLTYPE="github"
    ;;

https://github.com/*)
    URLTYPE="github"
    ;;

git@gitlab*)
    URLTYPE="gitlab"
    ;;

esac

if [ ${FIRST} -eq 0 ]
then
    echo "," >> "${JSON}"
fi

FIRST=0

cat >> "${JSON}" <<JSONOBJ
{
"name":"${NAME}",
"path":"${TOP}",
"remote":"${REMOTE}",
"remote_type":"${URLTYPE}",
"branch":"${BRANCH}",
"default_branch":"${DEFAULT}",
"dirty":${DIRTY},
"status_entries":${STATUS},
"untracked":${UNTRACKED},
"submodules":${SUBMODULES},
"size":"${SIZE}",
"last_commit":"${LAST}"
}
JSONOBJ

printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
"${NAME}" \
"${TOP}" \
"${BRANCH}" \
"${DEFAULT}" \
"${DIRTY}" \
"${STATUS}" \
"${UNTRACKED}" \
"${SUBMODULES}" \
"${SIZE}" \
"${REMOTE}" >> "${TMP}"

done

echo "]" >> "${JSON}"

{
echo "# Repository Inventory"
echo
echo "|Repo|Branch|Dirty|Status|Untracked|Submodules|Size|"
echo "|----|------|-----|------|----------|----------|----|"

sort "${TMP}" | while IFS=, read N P B D DI ST U S SZ R
do
    echo "|${N}|${B}|${DI}|${ST}|${U}|${S}|${SZ}|"
done

} > "${MD}"

{
echo "<html><head><title>Repository Inventory</title>"
echo "<style>"
echo "body{font-family:system-ui;margin:2rem}"
echo "table{border-collapse:collapse}"
echo "td,th{border:1px solid #888;padding:.4rem}"
echo "</style>"
echo "</head><body>"
echo "<h1>Repository Inventory</h1>"
echo "<table>"
echo "<tr><th>Repo</th><th>Branch</th><th>Dirty</th><th>Status</th><th>Untracked</th><th>Submodules</th><th>Size</th></tr>"

sort "${TMP}" | while IFS=, read N P B D DI ST U S SZ R
do
echo "<tr>"
echo "<td>${N}</td>"
echo "<td>${B}</td>"
echo "<td>${DI}</td>"
echo "<td>${ST}</td>"
echo "<td>${U}</td>"
echo "<td>${S}</td>"
echo "<td>${SZ}</td>"
echo "</tr>"
done

echo "</table>"
echo "</body></html>"

} > "${HTML}"

rm -f "${TMP}"

section "Repository Inventory"

green "JSON : ${JSON}"
green "CSV  : ${CSV}"
green "MD   : ${MD}"
green "HTML : ${HTML}"

summary

###############################################################################
# Commit + Push
###############################################################################

cd "${FOUNDRY}"

git add .

git diff --cached --quiet || \
git commit -m "Stage 02 - Repository inventory"

git push origin "$(git branch --show-current)"

