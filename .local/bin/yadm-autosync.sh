#!/usr/bin/env bash
# Auto-syncs both yadm dotfile repos (personal + work): pull, stage tracked
# changes, commit with a generic message, push. Run on a schedule via cron.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

LOG_FILE="$HOME/.local/share/yadm-autosync.log"
MAX_LOG_BYTES=$((1024 * 1024))
if [ -f "$LOG_FILE" ] && [ "$(wc -c <"$LOG_FILE")" -gt "$MAX_LOG_BYTES" ]; then
  mv -f "$LOG_FILE" "$LOG_FILE.1"
fi

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
