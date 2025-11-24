#!/bin/bash
set -e

if [[ $TARGET_VERSION -eq 21 ]]; then
    git clone --branch jdk21.0.1 --depth 1 https://github.com/openjdk/jdk21u openjdk-21
    PATCH="${{GITHUB.WORKSPACE}}/patches/jre_21/ios/fix_fdopen.patch"
    echo "Looking for patch at $PATCH"
    if [ ! -f "$PATCH" ]; then
        echo "Patch not found at $PATCH" >&2
        exit 1
    fi

    # If the patch cleanly applies, apply it.
    if git apply --check "$PATCH" 2>/dev/null; then
        git apply "$PATCH"
        echo "Patch applied"
    # If the reverse of the patch applies cleanly, the patch was already applied.
    elif git apply --check --reverse "$PATCH" 2>/dev/null; then
        echo "Patch already applied; skipping"
    else
        echo "Patch cannot be applied cleanly. Showing git apply --check output:" >&2
        git apply --check "$PATCH" || true
        echo "Attempting git apply --reject to capture rejects for manual inspection" >&2
        git apply --reject "$PATCH" || true
        exit 1
    fi
else
    git clone --depth 1 https://github.com/openjdk/jdk17u openjdk-17
fi