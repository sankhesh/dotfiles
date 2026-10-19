#!/usr/bin/env bash

set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPG_DIR="${GNUPGHOME:-${HOME}/.gnupg}"
GPG_CONFIG="${GPG_DIR}/gpg-agent.conf"
IS_MACOS=0
PINENTRY_PROGRAM=""

if [[ $(uname -s) == Darwin ]]; then
  IS_MACOS=1
  if ! PINENTRY_PROGRAM=$(command -v pinentry-mac); then
    printf 'pinentry-mac was not found in PATH.\n' >&2
    exit 1
  fi
fi

if [[ -e "$GPG_CONFIG" && ! -f "$GPG_CONFIG" ]]; then
  printf 'GPG agent config is not a regular file: %s\n' "$GPG_CONFIG" >&2
  exit 1
fi

mkdir -p -m 700 "$GPG_DIR"
TEMP_CONFIG=$(mktemp "${GPG_DIR}/gpg-agent.conf.XXXXXX")
trap 'rm -f "$TEMP_CONFIG"' EXIT
cat "${BASEDIR}/gpg-agent.conf" > "$TEMP_CONFIG"

# Apply repository defaults while retaining additional local options.
if [[ -f "$GPG_CONFIG" ]]; then
  awk -v macos="$IS_MACOS" '
    NR == FNR {
      if (NF && $1 !~ /^#/) managed[$1] = 1
      next
    }
    NF && $1 !~ /^#/ && !($1 in managed) &&
      !(macos == 1 && $1 == "pinentry-program")
  ' "${BASEDIR}/gpg-agent.conf" "$GPG_CONFIG" >> "$TEMP_CONFIG"
fi

if (( IS_MACOS )); then
  printf '\npinentry-program %s\n' "$PINENTRY_PROGRAM" >> "$TEMP_CONFIG"
fi

if [[ -f "$GPG_CONFIG" ]] && cmp -s "$TEMP_CONFIG" "$GPG_CONFIG"; then
  exit 0
fi

if [[ -f "$GPG_CONFIG" ]]; then
  BACKUP_CONFIG=$(mktemp "${GPG_CONFIG}.backup.XXXXXX")
  cp -p "$GPG_CONFIG" "$BACKUP_CONFIG"
  printf 'Backed up GPG agent config to %s\n' "$BACKUP_CONFIG"
fi

# Replace the destination itself so an existing symlink cannot edit the repo.
mv -f "$TEMP_CONFIG" "$GPG_CONFIG"
printf 'Configured GPG agent: %s\n' "$GPG_CONFIG"
if command -v gpgconf >/dev/null 2>&1; then
  gpgconf --homedir "$GPG_DIR" --reload gpg-agent
fi
