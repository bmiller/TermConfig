#!/bin/sh
# Deletes the Xcode DerivedData folder(s) associated with a worktree,
# matched by the project/workspace path recorded in each DerivedData
# folder's info.plist (WorkspacePath).
#
# Usage: clean-derived-data.sh [path-to-worktree]
#   Defaults to the git worktree containing the current directory if no
#   path is given -- run this from inside the worktree you're deleting.

set -eu

WORKTREE_PATH="${1:-}"

if [ -z "$WORKTREE_PATH" ]; then
    WORKTREE_PATH=$(git rev-parse --show-toplevel 2>/dev/null || true)
fi

if [ -z "$WORKTREE_PATH" ] || [ ! -d "$WORKTREE_PATH" ]; then
    echo "clean-derived-data: could not resolve a worktree path (pass one explicitly)" >&2
    exit 1
fi

# Resolve symlinks so the path matches what Xcode records
WORKTREE_PATH=$(CDPATH= cd -P -- "$WORKTREE_PATH" && pwd)

DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"
if [ ! -d "$DERIVED_DATA_DIR" ]; then
    echo "clean-derived-data: no DerivedData directory found, nothing to do"
    exit 0
fi

FOUND=0
for dd in "$DERIVED_DATA_DIR"/*; do
    plist="$dd/info.plist"
    [ -f "$plist" ] || continue

    ws_path=$(/usr/libexec/PlistBuddy -c "Print :WorkspacePath" "$plist" 2>/dev/null || true)
    [ -n "$ws_path" ] || continue

    # Any project or workspace inside this worktree. The trailing slash keeps
    # /path/foo from matching /path/foo-bar.
    case "$ws_path" in
        "$WORKTREE_PATH"/*)
            echo "clean-derived-data: removing $dd (matches $ws_path)"
            rm -rf "$dd"
            FOUND=1
            ;;
    esac
done

if [ "$FOUND" -eq 0 ]; then
    echo "clean-derived-data: no matching DerivedData folder found for $WORKTREE_PATH"
fi