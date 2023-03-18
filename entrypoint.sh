#!/bin/env bash
set -euo pipefile

BRANCHES_CLEANER_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [ "$BRANCHES_CLEANER_HOME" == "/" ]; then
  BRANCHES_CLEANER_HOME=""
fi

export BRANCHES_CLEANER_HOME

source "$BRANCHES_CLEANER_HOME/src/main.sh"

for a in "${@}"; do
  arg=$(echo "$a" | tr '\n' ' ' | xargs echo | sed "s/'//g"| sed "s/’//g")
  sanitizedArgs+=("$arg")
done

main "${sanitizedArgs[@]}"

exit $?
