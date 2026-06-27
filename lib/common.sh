#!/usr/bin/env bash

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SELF}/platform.sh"

ROOT="${HOME}/work"

FOUNDRY="${ROOT}/foundry"

STAMP=$(date +%Y%m%d-%H%M%S)

REPORTDIR="${FOUNDRY}/reports"

LOGDIR="${FOUNDRY}/logs"

mkdir -p "${REPORTDIR}"

mkdir -p "${LOGDIR}"

PASS=0
WARN=0
FAIL=0

green(){ printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
red(){ printf "\033[31m%s\033[0m\n" "$*"; }

section(){

echo
echo "======================================================"
echo "$*"
echo "======================================================"

}

check(){

CMD="$1"

if command -v "$CMD" >/dev/null 2>&1
then
    PASS=$((PASS+1))
    green "[PASS] ${CMD}"
else
    WARN=$((WARN+1))
    yellow "[WARN] ${CMD}"
fi

}

summary(){

echo
echo "======================================================"
echo "SUMMARY"
echo "======================================================"

echo "PASS : ${PASS}"
echo "WARN : ${WARN}"
echo "FAIL : ${FAIL}"

echo

echo "Platform : $(platform)"

}
