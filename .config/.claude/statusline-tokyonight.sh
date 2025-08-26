#!/bin/bash

# TokyoNight-inspired statusline for Claude Code
# Colors based on TokyoNight theme
input=$(cat)

# Extract data from JSON input
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
proj=$(echo "$input" | jq -r '.workspace.project_dir')
output_style=$(echo "$input" | jq -r '.output_style.name')

# TokyoNight color palette
bg="#1a1b26"
fg="#c0caf5"
blue="#7aa2f7"
cyan="#7dcfff"
purple="#bb9af7"
green="#9ece6a"
yellow="#e0af68"
red="#f7768e"
orange="#ff9e64"
gray="#565f89"
bright_gray="#9aa5ce"

# Calculate directory display (similar to your p10k style)
if [[ "$cwd" == "$proj"* ]]; then
    rel=${cwd#$proj}
    rel=${rel#/}
    if [[ -z "$rel" ]]; then
        dir=$(basename "$proj")
    else
        dir="$(basename "$proj")/$rel"
    fi
else
    dir=$(basename "$cwd")
fi

# Git information (matching your p10k git style)
git_info=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    
    # Handle detached HEAD state
    if [[ -z "$branch" ]]; then
        branch="@$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    
    # Check for dirty state
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        branch="$branch*"
    fi
    
    # Check ahead/behind status (only for named branches)
    if [[ "$branch" != "@"* ]]; then
        ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
        behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
        
        if [[ "$behind" -gt 0 ]] && [[ "$ahead" -gt 0 ]]; then
            branch="$branch⇣⇡"
        elif [[ "$behind" -gt 0 ]]; then
            branch="$branch⇣"
        elif [[ "$ahead" -gt 0 ]]; then
            branch="$branch⇡"
        fi
    fi
    
    git_info=" \033[38;2;125;207;255m$branch\033[0m"
fi

# Format output style indicator
style_indicator=""
if [[ "$output_style" != "default" ]]; then
    style_indicator=" \033[38;2;187;154;247m[$output_style]\033[0m"
fi

# Build the statusline with TokyoNight colors
printf "\033[38;2;122;162;247m%s\033[38;2;86;95;137m%s\033[38;2;158;206;106m%s \033[38;2;86;95;137m│ \033[38;2;192;202;245m%s\033[0m" \
    "$dir" \
    "$git_info" \
    "$style_indicator" \
    "$model"