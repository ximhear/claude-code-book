#!/bin/bash
# 문서 내 깨진 내부 링크를 검사하는 스크립트

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"

errors=0

echo "Checking internal links..."

# Find all markdown links that reference local files
while IFS= read -r file; do
    while IFS= read -r link; do
        # Extract the path from markdown link [text](path)
        target=$(echo "$link" | grep -oP '\]\(\K[^)]+' | head -1)

        # Skip external links and anchors
        if [[ "$target" == http* ]] || [[ "$target" == "#"* ]] || [[ -z "$target" ]]; then
            continue
        fi

        # Resolve relative path
        dir=$(dirname "$file")
        resolved="$dir/$target"

        if [ ! -f "$resolved" ]; then
            echo "BROKEN: $file -> $target"
            errors=$((errors + 1))
        fi
    done < <(grep -oP '\[.*?\]\(.*?\)' "$file" 2>/dev/null || true)
done < <(find "$DOCS_DIR" -name '*.md' -type f)

if [ $errors -eq 0 ]; then
    echo "All links OK."
else
    echo ""
    echo "Found $errors broken link(s)."
    exit 1
fi
