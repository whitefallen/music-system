#!/bin/bash
# fix-content.sh
# Fixes Hugo content issues:
# 1. Markdown headings before front matter (# Heading before ---)
# 2. Missing _index.md files in directories

set -e

CONTENT_DIR="${1:-content}"
FIXED_FRONTMATTER=0
CREATED_INDEX=0

echo "=== Fixing Content in $CONTENT_DIR ==="

# ------------------------------------------------------------------------------
# Fix 1: Headings before front matter
# Detects any # heading that appears before the first ---
# Converts it to proper YAML front matter with title
# ------------------------------------------------------------------------------

fix_frontmatter() {
    local file="$1"
    
    # Read first 20 lines to analyze structure
    local head_content=$(head -20 "$file")
    
    # Find line number of first ---
    local first_delimiter=$(echo "$head_content" | grep -n '^---$' | head -1 | cut -d: -f1)
    
    # If no --- found, skip
    if [ -z "$first_delimiter" ]; then
        return
    fi
    
    # Check if any # heading appears before first ---
    local lines_before=$(head -$((first_delimiter - 1)) "$file" 2>/dev/null)
    
    # Look for markdown heading (# Title, ## Title, etc.)
    local heading_line=$(echo "$lines_before" | grep -n '^#' | head -1)
    
    if [ -z "$heading_line" ]; then
        return
    fi
    
    # Extract the heading text (remove # symbols)
    local heading_linenum=$(echo "$heading_line" | cut -d: -f1)
    local heading_text=$(echo "$heading_line" | cut -d: -f2- | sed 's/^#* *//')
    
    echo "Fixing: $file"
    echo "  Found heading before front matter: $heading_text"
    
    # Find second --- (end of front matter)
    local second_delimiter=$(echo "$head_content" | grep -n '^---$' | sed -n '2p' | cut -d: -f1)
    
    if [ -z "$second_delimiter" ]; then
        echo "  Warning: Could not find closing --- in $file, skipping"
        return
    fi
    
    # Extract existing YAML content (between first and second ---)
    local yaml_content=$(sed -n "$((first_delimiter + 1)),$((second_delimiter - 1))p" "$file")
    
    # Check if title already exists in YAML
    if echo "$yaml_content" | grep -q '^title:'; then
        echo "  Title already in YAML, removing heading line only"
        # Just remove the heading line
        sed -i "${heading_linenum}d" "$file"
    else
        # Build new file content
        {
            # Lines before the heading (if any)
            if [ "$heading_linenum" -gt 1 ]; then
                head -$((heading_linenum - 1)) "$file"
            fi
            
            # New front matter with title
            echo "---"
            echo "title: \"$heading_text\""
            echo "$yaml_content"
            echo "---"
            
            # Everything after second ---
            tail -n +$((second_delimiter + 1)) "$file"
        } > "$file.tmp"
        
        mv "$file.tmp" "$file"
    fi
    
    FIXED_FRONTMATTER=$((FIXED_FRONTMATTER + 1))
}

# Process all markdown files
while IFS= read -r -d '' file; do
    fix_frontmatter "$file"
done < <(find "$CONTENT_DIR" -name "*.md" -type f -print0)

# ------------------------------------------------------------------------------
# Fix 2: Missing _index.md files
# Creates _index.md for any directory that contains .md files or subdirectories
# ------------------------------------------------------------------------------

create_missing_indexes() {
    while IFS= read -r -d '' dir; do
        # Skip root content directory
        if [ "$dir" = "$CONTENT_DIR" ]; then
            continue
        fi
        
        # Check if _index.md already exists
        if [ -f "$dir/_index.md" ]; then
            continue
        fi
        
        # Check if directory has content (other .md files or subdirectories)
        local has_content=false
        
        if ls "$dir"/*.md 2>/dev/null | grep -v "_index.md" > /dev/null 2>&1; then
            has_content=true
        fi
        
        if [ -d "$dir" ] && [ "$(find "$dir" -mindepth 1 -type d | head -1)" ]; then
            has_content=true
        fi
        
        if [ "$has_content" = false ]; then
            continue
        fi
        
        # Generate title from directory name
        local dirname=$(basename "$dir")
        # Convert kebab-case to Title Case
        local title=$(echo "$dirname" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        
        echo "Creating: $dir/_index.md"
        cat > "$dir/_index.md" << EOF
---
title: "$title"
---
EOF
        
        CREATED_INDEX=$((CREATED_INDEX + 1))
    done < <(find "$CONTENT_DIR" -type d -print0)
}

create_missing_indexes

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

echo ""
echo "=== Summary ==="
echo "Fixed front matter: $FIXED_FRONTMATTER files"
echo "Created index files: $CREATED_INDEX files"

# Exit with code indicating if changes were made
if [ $FIXED_FRONTMATTER -gt 0 ] || [ $CREATED_INDEX -gt 0 ]; then
    echo "Changes were made"
    exit 0
else
    echo "No changes needed"
    exit 0
fi
