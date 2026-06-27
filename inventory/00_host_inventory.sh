#!/usr/bin/env bash
###############################################################################
#
# Foundry Inventory Stage 00
#
# Host Inventory
#
# Linux
# WSL
# macOS (future)
#
# READ ONLY
#
###############################################################################

set -uo pipefail

FOUNDRY="${HOME}/work/foundry"

source "${FOUNDRY}/lib/common.sh"

OUTJSON="${FOUNDRY}/inventory/json/host.json"
OUTMD="${FOUNDRY}/inventory/md/host.md"
OUTHTML="${FOUNDRY}/web/host.html"

mkdir -p \
"${FOUNDRY}/inventory/json" \
"${FOUNDRY}/inventory/md" \
"${FOUNDRY}/web"

HOSTNAME="$(hostname 2>/dev/null || echo unknown)"
USER_NAME="$(id -un 2>/dev/null || echo unknown)"
OS="$(platform)"
KERNEL="$(uname -r 2>/dev/null)"
ARCH="$(uname -m 2>/dev/null)"
UPTIME="$(uptime -p 2>/dev/null || true)"
DATE="$(date --iso-8601=seconds 2>/dev/null || date)"

DISTRO="Unknown"

if [ -f /etc/os-release ]
then
    . /etc/os-release
    DISTRO="${PRETTY_NAME}"
fi

cat > "${OUTJSON}" <<JSON
{
  "hostname":"${HOSTNAME}",
  "user":"${USER_NAME}",
  "platform":"${OS}",
  "distribution":"${DISTRO}",
  "kernel":"${KERNEL}",
  "architecture":"${ARCH}",
  "uptime":"${UPTIME}",
  "timestamp":"${DATE}"
}
JSON

cat > "${OUTMD}" <<MD
# Host Inventory

| Item | Value |
|------|-------|
| Hostname | ${HOSTNAME} |
| User | ${USER_NAME} |
| Platform | ${OS} |
| Distribution | ${DISTRO} |
| Kernel | ${KERNEL} |
| Architecture | ${ARCH} |
| Uptime | ${UPTIME} |
| Timestamp | ${DATE} |
MD

cat > "${OUTHTML}" <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Foundry Host Inventory</title>
<style>
body{
    font-family:system-ui;
    max-width:1000px;
    margin:auto;
    padding:2rem;
}
table{
    border-collapse:collapse;
}
td,th{
    border:1px solid #999;
    padding:.5rem;
}
</style>
</head>
<body>

<h1>Foundry Host Inventory</h1>

<table>

<tr><th>Item</th><th>Value</th></tr>

<tr><td>Hostname</td><td>${HOSTNAME}</td></tr>

<tr><td>User</td><td>${USER_NAME}</td></tr>

<tr><td>Platform</td><td>${OS}</td></tr>

<tr><td>Distribution</td><td>${DISTRO}</td></tr>

<tr><td>Kernel</td><td>${KERNEL}</td></tr>

<tr><td>Architecture</td><td>${ARCH}</td></tr>

<tr><td>Uptime</td><td>${UPTIME}</td></tr>

<tr><td>Timestamp</td><td>${DATE}</td></tr>

</table>

</body>
</html>
HTML

section "Host Inventory"

green "JSON  : ${OUTJSON}"
green "MD    : ${OUTMD}"
green "HTML  : ${OUTHTML}"

summary
