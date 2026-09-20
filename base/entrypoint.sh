#!/usr/bin/env bash
set -e

# Create group with the target GID if it doesn't exist yet
if ! getent group "${PGID}" > /dev/null 2>&1; then
    groupadd -g "${PGID}" appgroup
fi

# Create user with the target UID if it doesn't exist yet
if ! getent passwd "${PUID}" > /dev/null 2>&1; then
    useradd -u "${PUID}" -g "${PGID}" -M -s /bin/bash appuser
fi

# Chown any directories listed in CHOWN_DIRS to the target user
if [ -n "${CHOWN_DIRS:-}" ]; then
    IFS=',' read -ra DIRS <<< "${CHOWN_DIRS}"
    for dir in "${DIRS[@]}"; do
        [ -d "$dir" ] && chown -R "${PUID}:${PGID}" "$dir"
    done
fi

exec gosu "${PUID}" "$@"
