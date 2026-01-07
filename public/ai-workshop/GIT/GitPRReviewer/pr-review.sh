#!/bin/bash

# ============================================================================
# AI Code Review for Pull Requests
# ============================================================================
# This script generates AI-powered code reviews before submitting PRs.
#
# USAGE:
#   ./pr-review.sh                    # Review changes vs main branch
#   ./pr-review.sh --branch develop   # Review changes vs specific branch
#   ./pr-review.sh --files "*.tsx"    # Review only specific files
#   ./pr-review.sh --api              # Use Gemini API directly
#   ./pr-review.sh --help             # Show this help
#
# REQUIREMENTS:
#   - Git repository
#   - For --api mode: GEMINI_API_KEY environment variable
#
# AI TECHNIQUES: Role-Based + Constraint-Based + Few-Shot Prompting
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
BASE_BRANCH="main"
FILE_FILTER=""
USE_API=false

# ============================================================================
# FUNCTIONS
# ============================================================================

show_help() {
    echo ""
    echo -e "${BLUE}AI Code Review for Pull Requests${NC}"
    echo "==================================="
    echo ""
    echo "USAGE:"
    echo "  ./pr-review.sh                    Review changes vs main"
    echo "  ./pr-review.sh --branch develop   Review vs specific branch"
    echo "  ./pr-review.sh --files \"*.tsx\"    Review specific files"
    echo "  ./pr-review.sh --api              Use Gemini API directly"
    echo "  ./pr-review.sh --context          Include project context files"
    echo "  ./pr-review.sh --help             Show this help"
    echo ""
    echo "OPTIONS:"
    echo "  --branch, -b    Base branch to compare against (default: main)"
    echo "  --files, -f     Glob pattern for files to include"
    echo "  --api, -a       Use Gemini API instead of clipboard"
    echo "  --context, -c   Include PROJECT_CONTEXT.md and CODING_GUIDELINES.md"
    echo ""
    echo "EXAMPLES:"
    echo "  ./pr-review.sh"
    echo "  ./pr-review.sh --branch develop"
    echo "  ./pr-review.sh --files \"src/components/*.tsx\""
    echo "  ./pr-review.sh --api --context"
    echo ""
    echo "API SETUP:"
    echo "  export GEMINI_API_KEY='your-api-key-here'"
    echo "  Get free key: https://makersuite.google.com/app/apikey"
    echo ""
}

check_git_repo() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        exit 1
    fi
}

check_branch_exists() {
    if ! git rev-parse --verify "$BASE_BRANCH" > /dev/null 2>&1; then
        echo -e "${RED}Error: Branch '$BASE_BRANCH' not found.${NC}"
        echo "Available branches:"
        git branch -a | head -10
        exit 1
    fi
}

get_diff() {
    local diff_cmd="git diff $BASE_BRANCH...HEAD"

    if [ -n "$FILE_FILTER" ]; then
        diff_cmd="$diff_cmd -- $FILE_FILTER"
    fi

    eval "$diff_cmd"
}

get_prompt() {
    cat << 'PROMPT_EOF'
## ROLE
You are a senior code reviewer with 10+ years of experience. Your job is to be CRITICAL but CONSTRUCTIVE. Find problems that could cause bugs, security issues, or maintenance headaches.

## CONTEXT
Review this Pull Request code. Focus on:
1. Bugs and logic errors
2. Security vulnerabilities
3. Performance problems
4. Code clarity
5. Missing error handling
6. Edge cases

## TASK
Review the diff and provide feedback using this format:

## FORMAT
```
## Summary
[1-2 sentences: Overall assessment]

## Issues Found

### 🔴 CRITICAL: [Title]
**Location:** `filename:line`
**Problem:** [What's wrong]
**Fix:** [How to fix]

### 🟡 WARNING: [Title]
**Location:** `filename:line`
**Problem:** [What's wrong]
**Suggestion:** [How to improve]

### 🟢 SUGGESTION: [Title]
**Location:** `filename:line`
**Note:** [What could be better]
```

## CONSTRAINTS
- Be critical, not encouraging
- Security issues are ALWAYS critical
- Max 10 issues, prioritize most important
- Include code suggestions where helpful
- If genuinely no issues, say so briefly

## CODE DIFF
PROMPT_EOF
}

get_context_files() {
    local context=""

    # Look for project context files
    local project_root=$(git rev-parse --show-toplevel)
    local context_locations=(
        "$project_root/PROJECT_CONTEXT.md"
        "$project_root/ai-workshop/Project/PROJECT_CONTEXT.md"
        "$project_root/docs/PROJECT_CONTEXT.md"
    )

    local guidelines_locations=(
        "$project_root/CODING_GUIDELINES.md"
        "$project_root/ai-workshop/Project/CODING_GUIDELINES.md"
        "$project_root/docs/CODING_GUIDELINES.md"
    )

    # Find and include context
    for loc in "${context_locations[@]}"; do
        if [ -f "$loc" ]; then
            context+="

## PROJECT CONTEXT
$(cat "$loc")
"
            break
        fi
    done

    # Find and include guidelines
    for loc in "${guidelines_locations[@]}"; do
        if [ -f "$loc" ]; then
            context+="

## CODING GUIDELINES
$(cat "$loc")
"
            break
        fi
    done

    echo "$context"
}

copy_to_clipboard() {
    local content="$1"

    if command -v pbcopy &> /dev/null; then
        echo "$content" | pbcopy
        return 0
    elif command -v xclip &> /dev/null; then
        echo "$content" | xclip -selection clipboard
        return 0
    elif command -v xsel &> /dev/null; then
        echo "$content" | xsel --clipboard --input
        return 0
    elif command -v clip.exe &> /dev/null; then
        echo "$content" | clip.exe
        return 0
    fi

    echo -e "${YELLOW}Warning: No clipboard utility found.${NC}"
    echo "Content saved to: /tmp/pr-review-prompt.txt"
    echo "$content" > /tmp/pr-review-prompt.txt
    return 1
}

# ============================================================================
# MANUAL MODE
# ============================================================================

run_manual_mode() {
    echo -e "${BLUE}AI Code Review - Manual Mode${NC}"
    echo "=============================="
    echo ""

    check_git_repo
    check_branch_exists

    # Get diff
    DIFF=$(get_diff)

    if [ -z "$DIFF" ]; then
        echo -e "${YELLOW}No changes found between HEAD and $BASE_BRANCH${NC}"
        echo ""
        echo "Make sure you have commits not in $BASE_BRANCH"
        echo "Or specify different base: ./pr-review.sh --branch develop"
        exit 0
    fi

    DIFF_LINES=$(echo "$DIFF" | wc -l)
    DIFF_FILES=$(echo "$DIFF" | grep "^diff --git" | wc -l)

    echo -e "${GREEN}Found changes:${NC}"
    echo "  Files changed: $DIFF_FILES"
    echo "  Diff lines: $DIFF_LINES"
    echo "  Base branch: $BASE_BRANCH"
    echo ""

    # Build prompt
    FULL_PROMPT="$(get_prompt)"

    # Add context if requested
    if [ "$INCLUDE_CONTEXT" = true ]; then
        CONTEXT=$(get_context_files)
        if [ -n "$CONTEXT" ]; then
            FULL_PROMPT+="$CONTEXT"
            echo -e "${GREEN}✓ Project context included${NC}"
        else
            echo -e "${YELLOW}⚠ No context files found${NC}"
        fi
    fi

    FULL_PROMPT+="
$DIFF"

    # Check size
    PROMPT_SIZE=${#FULL_PROMPT}
    if [ $PROMPT_SIZE -gt 100000 ]; then
        echo -e "${YELLOW}Warning: Diff is very large ($PROMPT_SIZE chars)${NC}"
        echo "Consider reviewing specific files: ./pr-review.sh --files \"src/*.tsx\""
        echo ""
    fi

    # Copy to clipboard
    if copy_to_clipboard "$FULL_PROMPT"; then
        echo -e "${GREEN}✓ Review prompt copied to clipboard!${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Paste into ChatGPT, Gemini, or your AI tool"
    echo "2. Review the AI feedback"
    echo "3. Fix any critical issues"
    echo "4. Create your Pull Request"
    echo ""
    echo -e "${BLUE}Quick links:${NC}"
    echo "  ChatGPT: https://chat.openai.com"
    echo "  Gemini:  https://gemini.google.com"
    echo ""
}

# ============================================================================
# API MODE
# ============================================================================

run_api_mode() {
    echo -e "${BLUE}AI Code Review - API Mode${NC}"
    echo "=========================="
    echo ""

    check_git_repo
    check_branch_exists

    if [ -z "$GEMINI_API_KEY" ]; then
        echo -e "${RED}Error: GEMINI_API_KEY not set.${NC}"
        echo ""
        echo "Setup:"
        echo "  export GEMINI_API_KEY='your-key'"
        echo "  Get key: https://makersuite.google.com/app/apikey"
        exit 1
    fi

    if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: curl and jq required for API mode.${NC}"
        exit 1
    fi

    # Get diff
    DIFF=$(get_diff)

    if [ -z "$DIFF" ]; then
        echo -e "${YELLOW}No changes found.${NC}"
        exit 0
    fi

    echo -e "${GREEN}Analyzing code changes...${NC}"
    echo ""

    # Build prompt
    FULL_PROMPT="$(get_prompt)"

    if [ "$INCLUDE_CONTEXT" = true ]; then
        CONTEXT=$(get_context_files)
        FULL_PROMPT+="$CONTEXT"
    fi

    FULL_PROMPT+="
$DIFF"

    # Escape for JSON
    ESCAPED_PROMPT=$(echo "$FULL_PROMPT" | jq -Rs '.')

    # API request
    REQUEST_BODY=$(cat << EOF
{
  "contents": [{
    "parts": [{
      "text": $ESCAPED_PROMPT
    }]
  }],
  "generationConfig": {
    "temperature": 0.2,
    "maxOutputTokens": 2000
  }
}
EOF
)

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

    # Extract review
    REVIEW=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

    if [ -z "$REVIEW" ] || [ "$REVIEW" = "null" ]; then
        echo -e "${RED}Error: Could not parse response.${NC}"
        exit 1
    fi

    # Display review
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                      CODE REVIEW RESULTS                        ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "$REVIEW"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

    # Count issues
    CRITICAL=$(echo "$REVIEW" | grep -c "🔴 CRITICAL" || true)
    WARNING=$(echo "$REVIEW" | grep -c "🟡 WARNING" || true)
    SUGGESTION=$(echo "$REVIEW" | grep -c "🟢 SUGGESTION" || true)

    echo ""
    echo -e "${YELLOW}Issue Summary:${NC}"
    echo -e "  ${RED}🔴 Critical: $CRITICAL${NC}"
    echo -e "  ${YELLOW}🟡 Warnings: $WARNING${NC}"
    echo -e "  ${GREEN}🟢 Suggestions: $SUGGESTION${NC}"
    echo ""

    if [ "$CRITICAL" -gt 0 ]; then
        echo -e "${RED}⚠️  Address critical issues before creating PR!${NC}"
    elif [ "$WARNING" -gt 0 ]; then
        echo -e "${YELLOW}Consider addressing warnings before PR.${NC}"
    else
        echo -e "${GREEN}✓ Looking good! Ready for PR.${NC}"
    fi

    # Offer to save
    echo ""
    read -p "Save review to file? [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        FILENAME="pr-review-$TIMESTAMP.md"
        echo "$REVIEW" > "$FILENAME"
        echo -e "${GREEN}✓ Saved to: $FILENAME${NC}"
    fi
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

INCLUDE_CONTEXT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --branch|-b)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --files|-f)
            FILE_FILTER="$2"
            shift 2
            ;;
        --api|-a)
            USE_API=true
            shift
            ;;
        --context|-c)
            INCLUDE_CONTEXT=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# ============================================================================
# MAIN
# ============================================================================

if [ "$USE_API" = true ]; then
    run_api_mode
else
    run_manual_mode
fi
