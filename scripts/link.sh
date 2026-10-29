#!/usr/bin/env bash
# Links each skill in fstack/skills into ~/.claude/skills, so Claude Code loads it.
# Run it after you add a skill. It is safe to run again: a correct link stays as it is,
# and a real folder with the same name is never replaced (it is reported as CONFLICT).
set -euo pipefail
shopt -s nullglob
F=$(cd "$(dirname "$0")/.." && pwd)
C="$HOME/.claude/skills"
status=0

for d in "$F"/skills/*/; do
  s=$(basename "$d"); want="$F/skills/$s"; have="$C/$s"
  if [ -L "$have" ] && [ "$(readlink "$have")" = "$want" ]; then
    echo "ok        $s"
  elif [ -e "$have" ] || [ -L "$have" ]; then
    echo "CONFLICT  $s: $have exists and is not a link to fstack; merge it by hand"; status=1
  else
    ln -s "$want" "$have"; echo "linked    $s"
  fi
done

# A link into fstack whose skill is gone from fstack
for l in "$C"/*; do
  if [ -L "$l" ] && [[ "$(readlink "$l")" == "$F/skills/"* ]] && [ ! -e "$l" ]; then
    echo "DANGLING  $(basename "$l"): its skill is not in fstack any more"; status=1
  fi
done
exit $status
