#!/usr/bin/env bash
# Auto-syncs both yadm dotfile repos (personal + work): pull, stage tracked
# changes, commit with a generic message, push. Run on a schedule via cron.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

MSG="Automated dotfiles sync"

sync_repo() {
  local label="$1"
  shift
  local -a yadm=("$@")

  echo "[$(date -Iseconds)] ${label}: syncing"

  "${yadm[@]}" pull
  "${yadm[@]}" add -u

  if ! "${yadm[@]}" diff --cached --quiet; then
    "${yadm[@]}" commit -m "$MSG"
  else
    echo "[$(date -Iseconds)] ${label}: nothing to commit"
  fi

  "${yadm[@]}" push
}

sync_repo "personal" yadm
sync_repo "work" yadm --yadm-dir "$HOME/.config/yadm-work" --yadm-data "$HOME/.local/share/yadm-work"

echo "[$(date -Iseconds)] done"
