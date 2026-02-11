#!/bin/bash
# 전체 문서를 하나의 파일로 병합하는 빌드 스크립트

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_FILE="$BUILD_DIR/claude-code-book.md"
VERSION=$(cat "$PROJECT_ROOT/VERSION" | tr -d '[:space:]')

mkdir -p "$BUILD_DIR"

echo "Building Claude Code Book v${VERSION}..."
echo ""

# Header
cat > "$OUTPUT_FILE" << EOF
# Claude Code 완벽 가이드 v${VERSION}

> 최종 빌드: $(date '+%Y-%m-%d %H:%M:%S')

---

EOF

# Table of Contents
echo "## 목차" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

chapter_num=0
for chapter_dir in "$DOCS_DIR"/*/; do
    if [ -d "$chapter_dir" ]; then
        chapter_name=$(basename "$chapter_dir")
        # Extract display name from the directory (e.g., 01-getting-started -> Getting Started)
        display_name=$(echo "$chapter_name" | sed 's/^[0-9]*-//' | sed 's/-/ /g')
        chapter_num=$((chapter_num + 1))

        echo "### Part ${chapter_num}: ${display_name}" >> "$OUTPUT_FILE"

        for doc in "$chapter_dir"*.md; do
            if [ -f "$doc" ]; then
                title=$(head -1 "$doc" | sed 's/^#* *//')
                echo "- ${title}" >> "$OUTPUT_FILE"
            fi
        done
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Merge all documents
for chapter_dir in "$DOCS_DIR"/*/; do
    if [ -d "$chapter_dir" ]; then
        for doc in "$chapter_dir"*.md; do
            if [ -f "$doc" ]; then
                cat "$doc" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "---" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
    fi
done

line_count=$(wc -l < "$OUTPUT_FILE")
echo "Build complete: $OUTPUT_FILE (${line_count} lines)"
