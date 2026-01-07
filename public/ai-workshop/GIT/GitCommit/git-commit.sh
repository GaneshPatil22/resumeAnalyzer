#!/bin/bash

# ============================================================================
# Git Commit Message Generator
# ============================================================================
# This script generates AI-powered commit messages from your staged changes.
#
# USAGE:
#   ./git-commit.sh           # Copies prompt to clipboard (for manual paste)
#   ./git-commit.sh --api     # Uses Gemini API directly (requires API key)
#   ./git-commit.sh --help    # Shows this help
#
# REQUIREMENTS:
#   - Git repository with staged changes
#   - For --api mode: GEMINI_API_KEY environment variable set
#
# AI TECHNIQUE: R-C-T-F Framework + Constraint-Based Prompting
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# FUNCTIONS
# ============================================================================

show_help() {
    echo ""
    echo -e "${BLUE}Git Commit Message Generator${NC}"
    echo "================================"
    echo ""
    echo "USAGE:"
    echo "  ./git-commit.sh           Copy prompt to clipboard (manual mode)"
    echo "  ./git-commit.sh --api     Use Gemini API directly (auto mode)"
    echo "  ./git-commit.sh --help    Show this help"
    echo ""
    echo "MANUAL MODE:"
    echo "  1. Stage your changes: git add ."
    echo "  2. Run: ./git-commit.sh"
    echo "  3. Prompt + diff copied to clipboard"
    echo "  4. Paste into ChatGPT/Gemini/etc"
    echo "  5. Copy the generated message"
    echo "  6. Run: git commit -m \"message\""
    echo ""
    echo "API MODE:"
    echo "  1. Set GEMINI_API_KEY environment variable"
    echo "  2. Stage your changes: git add ."
    echo "  3. Run: ./git-commit.sh --api"
    echo "  4. Message generated and shown"
    echo "  5. Confirm to commit or edit"
    echo ""
    echo "SETUP GEMINI API KEY:"
    echo "  export GEMINI_API_KEY='your-api-key-here'"
    echo "  # Add to ~/.bashrc or ~/.zshrc for persistence"
    echo ""
    echo "GET FREE API KEY:"
    echo "  https://makersuite.google.com/app/apikey"
    echo ""
}

check_staged_changes() {
    if [ -z "$(git diff --staged)" ]; then
        echo -e "${RED}Error: No staged changes found.${NC}"
        echo ""
        echo "Stage your changes first:"
        echo "  git add <files>    # Stage specific files"
        echo "  git add .          # Stage all changes"
        echo ""
        exit 1
    fi
}

check_git_repo() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        echo "Run this script from inside a git repository."
        exit 1
    fi
}

get_prompt() {
    cat << 'PROMPT_EOF'
## ROLE
You are a senior developer who writes clear, professional git commit messages following the Conventional Commits specification.

## CONTEXT
I need a commit message for my staged changes. The commit message should:
- Follow Conventional Commits format: <type>(<scope>): <description>
- Be clear about WHAT changed and WHY
- Help future developers understand the change at a glance

**Types:** feat, fix, docs, style, refactor, test, chore

## TASK
Analyze the git diff below and:
1. Identify the type of change
2. Determine the scope (component/file/feature affected)
3. Write a clear, concise description
4. Add body if the change needs explanation
5. If changes are unrelated, suggest splitting into multiple commits

## FORMAT
Output ONLY the commit message, ready to use. No explanations.

## CONSTRAINTS
- Subject line: max 72 characters
- Use imperative mood ("add" not "added")
- Lowercase description, no period at end
- If multiple unrelated changes, output separate commits

## GIT DIFF
PROMPT_EOF
}

# ============================================================================
# CLIPBOARD DETECTION
# ============================================================================

copy_to_clipboard() {
    local content="$1"

    # macOS
    if command -v pbcopy &> /dev/null; then
        echo "$content" | pbcopy
        return 0
    fi

    # Linux with xclip
    if command -v xclip &> /dev/null; then
        echo "$content" | xclip -selection clipboard
        return 0
    fi

    # Linux with xsel
    if command -v xsel &> /dev/null; then
        echo "$content" | xsel --clipboard --input
        return 0
    fi

    # Windows (Git Bash / WSL)
    if command -v clip.exe &> /dev/null; then
        echo "$content" | clip.exe
        return 0
    fi

    # Fallback
    echo -e "${YELLOW}Warning: No clipboard utility found.${NC}"
    echo "Install one of: pbcopy (macOS), xclip, xsel (Linux)"
    echo ""
    echo "Manual copy required. Content saved to: /tmp/git-commit-prompt.txt"
    echo "$content" > /tmp/git-commit-prompt.txt
    return 1
}

# ============================================================================
# MANUAL MODE (Clipboard)
# ============================================================================

run_manual_mode() {
    echo -e "${BLUE}Git Commit Message Generator - Manual Mode${NC}"
    echo "============================================"
    echo ""

    check_git_repo
    check_staged_changes

    # Get diff
    DIFF=$(git diff --staged)
    DIFF_LINES=$(echo "$DIFF" | wc -l)

    echo -e "${GREEN}Found staged changes:${NC} $DIFF_LINES lines"
    echo ""

    # Combine prompt and diff
    FULL_PROMPT="$(get_prompt)
$DIFF"

    # Copy to clipboard
    if copy_to_clipboard "$FULL_PROMPT"; then
        echo -e "${GREEN}✓ Prompt + diff copied to clipboard!${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Paste into ChatGPT, Gemini, or your AI tool"
    echo "2. Copy the generated commit message"
    echo "3. Run: git commit -m \"<paste message>\""
    echo ""
    echo -e "${BLUE}Quick links:${NC}"
    echo "  ChatGPT: https://chat.openai.com"
    echo "  Gemini:  https://gemini.google.com"
    echo ""
}

# ============================================================================
# API MODE (Gemini)
# ============================================================================

run_api_mode() {
    echo -e "${BLUE}Git Commit Message Generator - API Mode${NC}"
    echo "========================================="
    echo ""

    check_git_repo
    check_staged_changes

    # Check for API key
    if [ -z "$GEMINI_API_KEY" ]; then
        echo -e "${RED}Error: GEMINI_API_KEY environment variable not set.${NC}"
        echo ""
        echo "Setup:"
        echo "  1. Get free API key: https://makersuite.google.com/app/apikey"
        echo "  2. Set environment variable:"
        echo "     export GEMINI_API_KEY='your-key-here'"
        echo ""
        echo "Or use manual mode: ./git-commit.sh"
        exit 1
    fi

    # Check for curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required for API mode.${NC}"
        exit 1
    fi

    # Get diff
    DIFF=$(git diff --staged)

    echo -e "${GREEN}Analyzing staged changes...${NC}"
    echo ""

    # Build the prompt
    PROMPT="$(get_prompt)
$DIFF"

    # Escape for JSON
    ESCAPED_PROMPT=$(echo "$PROMPT" | jq -Rs '.')

    # Build request body
    REQUEST_BODY=$(cat << EOF
{
  "contents": [{
    "parts": [{
      "text": $ESCAPED_PROMPT
    }]
  }],
  "generationConfig": {
    "temperature": 0.3,
    "maxOutputTokens": 500
  }
}
EOF
)

    # Call Gemini API
    RESPONSE=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$REQUEST_BODY")

    # Check for errors
    if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message')
        echo -e "${RED}API Error: $ERROR_MSG${NC}"
        exit 1
    fi

    # Extract message
    COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | sed 's/^```//g' | sed 's/```$//g' | xargs)

    if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" = "null" ]; then
        echo -e "${RED}Error: Could not parse API response.${NC}"
        echo "Raw response:"
        echo "$RESPONSE"
        exit 1
    fi

    # Show generated message
    echo -e "${GREEN}Generated commit message:${NC}"
    echo "─────────────────────────"
    echo "$COMMIT_MSG"
    echo "─────────────────────────"
    echo ""

    # Ask for confirmation
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo "  [y] Use this message and commit"
    echo "  [e] Edit message before committing"
    echo "  [c] Copy to clipboard only"
    echo "  [n] Cancel"
    echo ""
    read -p "Choice [y/e/c/n]: " -n 1 -r
    echo ""

    case $REPLY in
        [Yy])
            git commit -m "$COMMIT_MSG"
            echo -e "${GREEN}✓ Committed successfully!${NC}"
            ;;
        [Ee])
            # Open in editor
            TEMP_FILE=$(mktemp)
            echo "$COMMIT_MSG" > "$TEMP_FILE"
            ${EDITOR:-vi} "$TEMP_FILE"
            EDITED_MSG=$(cat "$TEMP_FILE")
            rm "$TEMP_FILE"

            if [ -n "$EDITED_MSG" ]; then
                git commit -m "$EDITED_MSG"
                echo -e "${GREEN}✓ Committed with edited message!${NC}"
            else
                echo -e "${YELLOW}Cancelled - empty message.${NC}"
            fi
            ;;
        [Cc])
            if copy_to_clipboard "$COMMIT_MSG"; then
                echo -e "${GREEN}✓ Message copied to clipboard!${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}Cancelled.${NC}"
            ;;
    esac
}

# ============================================================================
# MAIN
# ============================================================================

case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --api|-a)
        run_api_mode
        ;;
    "")
        run_manual_mode
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
