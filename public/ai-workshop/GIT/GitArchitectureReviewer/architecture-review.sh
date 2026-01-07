#!/bin/bash

# ============================================================================
# AI Architecture Review
# ============================================================================
# This script helps get AI-powered architecture reviews for proposed changes.
#
# USAGE:
#   ./architecture-review.sh               # Interactive mode
#   ./architecture-review.sh --arch FILE   # Include architecture file
#   ./architecture-review.sh --api         # Use Groq API directly
#   ./architecture-review.sh --help        # Show help
#
# REQUIREMENTS:
#   - For --api mode: GROQ_API_KEY environment variable
#
# AI TECHNIQUES: Chain of Thought + Role-Based + Iterative Refinement
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
ARCH_FILE=""
USE_API=false
PROPOSAL_FILE=""

# ============================================================================
# FUNCTIONS
# ============================================================================

show_help() {
    echo ""
    echo -e "${BLUE}AI Architecture Review${NC}"
    echo "========================"
    echo ""
    echo "USAGE:"
    echo "  ./architecture-review.sh               Interactive mode"
    echo "  ./architecture-review.sh --arch FILE   Include architecture file"
    echo "  ./architecture-review.sh --proposal F  Read proposal from file"
    echo "  ./architecture-review.sh --api         Use Groq API"
    echo "  ./architecture-review.sh --help        Show this help"
    echo ""
    echo "INTERACTIVE MODE:"
    echo "  The script will prompt you for:"
    echo "  1. Current architecture description"
    echo "  2. Proposed change description"
    echo "  3. Reason for change"
    echo ""
    echo "WITH FILES:"
    echo "  ./architecture-review.sh --arch ./ARCHITECTURE.md"
    echo "  ./architecture-review.sh --arch ./docs/arch.md --proposal ./proposal.md"
    echo ""
    echo "API SETUP:"
    echo "  export GROQ_API_KEY='your-key'"
    echo "  Get free key: https://console.groq.com/keys"
    echo ""
}

get_prompt_template() {
    cat << 'PROMPT_EOF'
## ROLE
You are a senior software architect with 15+ years of experience. Think like a skeptical architect in a design review meeting. Find holes in the plan.

## TASK
Analyze this architectural proposal step by step:

1. **Pattern Fit**: Does this match existing patterns?
2. **Scaling**: How does this behave at 10x scale?
3. **Failure Modes**: What can go wrong?
4. **Complexity**: Is there a simpler approach?
5. **Migration**: How do we get there safely?

## FORMAT
```
## Summary
[2-3 sentences: Overall assessment]

## Pattern Fit
✅ [What fits]
⚠️ [Concerns]
❌ [What doesn't fit]

## Scaling Concerns
[Numbered list]

## Failure Modes
[What can go wrong and how to handle it]

## Simpler Alternatives
[At least one alternative approach]

## Migration Path
[How to implement safely]

## Recommendation
🟢 APPROVE / 🟡 APPROVE WITH CHANGES / 🔴 RECONSIDER
[Final recommendation with reasoning]
```

## CONSTRAINTS
- Be critical - I want to know what could go wrong
- Always suggest at least one alternative
- Consider operational complexity
PROMPT_EOF
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
    echo "Content saved to: /tmp/architecture-review-prompt.txt"
    echo "$content" > /tmp/architecture-review-prompt.txt
    return 1
}

read_single_line() {
    local prompt="$1"
    echo -e "${CYAN}$prompt${NC}"
    read -r REPLY
    echo "$REPLY"
}

# ============================================================================
# INTERACTIVE MODE
# ============================================================================

run_interactive_mode() {
    echo -e "${BLUE}AI Architecture Review - Interactive Mode${NC}"
    echo "==========================================="
    echo ""

    # Get current architecture
    if [ -n "$ARCH_FILE" ] && [ -f "$ARCH_FILE" ]; then
        echo -e "${GREEN}Using architecture file: $ARCH_FILE${NC}"
        CURRENT_ARCH=$(cat "$ARCH_FILE")
    else
        echo -e "${YELLOW}Tip: Use --arch FILE to load from a file${NC}"
        CURRENT_ARCH=$(read_single_line "Describe your current architecture (brief):")
    fi

    echo ""

    # Get proposed change
    if [ -n "$PROPOSAL_FILE" ] && [ -f "$PROPOSAL_FILE" ]; then
        echo -e "${GREEN}Using proposal file: $PROPOSAL_FILE${NC}"
        PROPOSED_CHANGE=$(cat "$PROPOSAL_FILE")
    else
        echo -e "${YELLOW}Tip: Use --proposal FILE to load from a file${NC}"
        PROPOSED_CHANGE=$(read_single_line "Describe your proposed change (brief):")
    fi

    echo ""

    # Get reason
    CHANGE_REASON=$(read_single_line "Why are you making this change?")

    echo ""

    # Build the full prompt
    FULL_PROMPT="$(get_prompt_template)

## CURRENT ARCHITECTURE
$CURRENT_ARCH

## PROPOSED CHANGE
$PROPOSED_CHANGE

## REASON FOR CHANGE
$CHANGE_REASON"

    # Copy to clipboard
    if copy_to_clipboard "$FULL_PROMPT"; then
        echo -e "${GREEN}✓ Review prompt copied to clipboard!${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Paste into ChatGPT or Gemini"
    echo "2. Review the architecture analysis"
    echo "3. Ask follow-up questions as needed"
    echo ""
    echo -e "${BLUE}Follow-up prompt ideas:${NC}"
    echo "  - 'Deep dive on the scaling concern about [X]'"
    echo "  - 'Compare alternative 1 vs my original proposal'"
    echo "  - 'What's the simplest possible version of this?'"
    echo ""
}

# ============================================================================
# API MODE
# ============================================================================

run_api_mode() {
    echo -e "${BLUE}AI Architecture Review - API Mode${NC}"
    echo "==================================="
    echo ""

    if [ -z "$GROQ_API_KEY" ]; then
        echo -e "${RED}Error: GROQ_API_KEY not set.${NC}"
        echo ""
        echo "Setup:"
        echo "  export GROQ_API_KEY='your-key'"
        echo "  Get key: https://console.groq.com/keys"
        exit 1
    fi

    if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: curl and jq required for API mode.${NC}"
        exit 1
    fi

    # Get current architecture
    if [ -n "$ARCH_FILE" ] && [ -f "$ARCH_FILE" ]; then
        echo -e "${GREEN}Using architecture file: $ARCH_FILE${NC}"
        CURRENT_ARCH=$(cat "$ARCH_FILE")
    else
        echo -e "${YELLOW}Tip: Use --arch FILE to load from a file${NC}"
        CURRENT_ARCH=$(read_single_line "Describe your current architecture (brief):")
    fi

    echo ""

    # Get proposed change
    if [ -n "$PROPOSAL_FILE" ] && [ -f "$PROPOSAL_FILE" ]; then
        echo -e "${GREEN}Using proposal file: $PROPOSAL_FILE${NC}"
        PROPOSED_CHANGE=$(cat "$PROPOSAL_FILE")
    else
        echo -e "${YELLOW}Tip: Use --proposal FILE to load from a file${NC}"
        PROPOSED_CHANGE=$(read_single_line "Describe your proposed change (brief):")
    fi

    echo ""

    # Get reason
    CHANGE_REASON=$(read_single_line "Why are you making this change?")

    echo ""
    echo -e "${GREEN}Analyzing architecture...${NC}"
    echo ""

    # Build prompt
    FULL_PROMPT="$(get_prompt_template)

## CURRENT ARCHITECTURE
$CURRENT_ARCH

## PROPOSED CHANGE
$PROPOSED_CHANGE

## REASON FOR CHANGE
$CHANGE_REASON"

    # Escape for JSON
    ESCAPED_PROMPT=$(echo "$FULL_PROMPT" | jq -Rs '.')

    # API request (OpenAI-compatible format for Groq)
    REQUEST_BODY=$(cat << EOF
{
  "model": "llama-3.3-70b-versatile",
  "messages": [{
    "role": "user",
    "content": $ESCAPED_PROMPT
  }],
  "temperature": 0.3,
  "max_tokens": 3000
}
EOF
)

    RESPONSE=$(curl -s -X POST \
        "https://api.groq.com/openai/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -d "$REQUEST_BODY")

    # Check for errors
    if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message')
        echo -e "${RED}API Error: $ERROR_MSG${NC}"
        exit 1
    fi

    # Extract review (OpenAI format)
    REVIEW=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

    if [ -z "$REVIEW" ] || [ "$REVIEW" = "null" ]; then
        echo -e "${RED}Error: Could not parse response.${NC}"
        exit 1
    fi

    # Display review
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                   ARCHITECTURE REVIEW                          ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "$REVIEW"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

    # Offer follow-up
    echo ""
    echo -e "${YELLOW}Would you like to ask a follow-up question? [y/N]${NC}"
    read -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Enter your follow-up question:${NC}"
        read -r FOLLOWUP

        FOLLOWUP_PROMPT="Based on your previous architecture review, I have a follow-up question:

$FOLLOWUP

Think through this step by step."

        ESCAPED_FOLLOWUP=$(echo "$FOLLOWUP_PROMPT" | jq -Rs '.')

        FOLLOWUP_BODY=$(cat << EOF
{
  "model": "llama-3.3-70b-versatile",
  "messages": [{
    "role": "user",
    "content": $ESCAPED_FOLLOWUP
  }],
  "temperature": 0.3,
  "max_tokens": 2000
}
EOF
)

        echo ""
        echo -e "${GREEN}Processing follow-up...${NC}"
        echo ""

        FOLLOWUP_RESPONSE=$(curl -s -X POST \
            "https://api.groq.com/openai/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $GROQ_API_KEY" \
            -d "$FOLLOWUP_BODY")

        FOLLOWUP_ANSWER=$(echo "$FOLLOWUP_RESPONSE" | jq -r '.choices[0].message.content')

        echo -e "${CYAN}Follow-up Response:${NC}"
        echo "─────────────────────"
        echo "$FOLLOWUP_ANSWER"
        echo ""
    fi

    # Save option
    echo -e "${YELLOW}Save review to file? [y/N]${NC}"
    read -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        FILENAME="architecture-review-$TIMESTAMP.md"
        echo "$REVIEW" > "$FILENAME"
        echo -e "${GREEN}✓ Saved to: $FILENAME${NC}"
    fi
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --arch|-a)
            ARCH_FILE="$2"
            if [ ! -f "$ARCH_FILE" ]; then
                echo -e "${RED}Error: Architecture file not found: $ARCH_FILE${NC}"
                exit 1
            fi
            shift 2
            ;;
        --proposal|-p)
            PROPOSAL_FILE="$2"
            if [ ! -f "$PROPOSAL_FILE" ]; then
                echo -e "${RED}Error: Proposal file not found: $PROPOSAL_FILE${NC}"
                exit 1
            fi
            shift 2
            ;;
        --api)
            USE_API=true
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
    run_interactive_mode
fi
