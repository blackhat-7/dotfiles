#! /bin/sh
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
PATTERN="^(fix|feat|BREAKING CHANGE): .+$"

if ! echo "$COMMIT_MSG" | grep -Eq "$PATTERN"; then
  echo "Commit message does not follow the semantic versioning format (fix:, feat:, BREAKING CHANGE:)"
  exit 1
fi

