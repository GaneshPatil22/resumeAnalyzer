# Project README Template

> **AI Prompting Technique Used:** `R-C-T-F Framework` + `Zero-Shot Prompting`
>
> This template uses the R-C-T-F (Role-Context-Task-Format) framework to help AI understand your project quickly. Zero-Shot means the AI can generate useful output without needing examples - just clear instructions.

---

## What is R-C-T-F Framework?

| Letter | Meaning | Purpose |
|--------|---------|---------|
| **R** | Role | Who should the AI pretend to be? (Expert persona) |
| **C** | Context | What background info does AI need? |
| **T** | Task | What specific action should AI take? |
| **F** | Format | How should the output look? |

**Why use it?** AI has ALL knowledge but doesn't know WHICH knowledge to apply. R-C-T-F tells it exactly what perspective and format you need.

---

## What is Zero-Shot Prompting?

**Definition:** Asking AI to perform a task with NO examples - just direct instructions.

**When to use:**
- Simple, well-defined tasks
- When AI's default knowledge is sufficient
- Quick questions with clear answers

**Example:**
```
❌ Bad (vague): "Tell me about this project"
✅ Good (zero-shot): "Summarize this README in 3 bullet points focusing on tech stack, purpose, and how to run it"
```

---

## How to Use This Template

### Step 1: Copy the Template Below
### Step 2: Fill in Your Project Details
### Step 3: Use with Any Free AI Tool

**Compatible Tools:**
- ChatGPT (Free) - Paste directly
- Google Gemini - Paste directly
- Continue.dev (VSCode) - Use in chat panel
- Codeium (VSCode) - Use in chat panel

---

## Prompt to Generate README

Copy this prompt and paste it into your AI tool along with your project details:

```markdown
## ROLE
You are a senior technical writer who creates clear, developer-friendly documentation.

## CONTEXT
I'm creating a README for my project. Here are the details:

**Project Name:** [YOUR_PROJECT_NAME]
**One-line Description:** [WHAT_DOES_IT_DO]
**Tech Stack:** [LIST_YOUR_TECHNOLOGIES]
**How to Run:** [COMMANDS_TO_START]

## TASK
Generate a professional README.md that includes:
1. Project title and description
2. Tech stack table
3. Quick start section with terminal commands
4. Available scripts table
5. Environment variables table (if any)
6. Project structure overview

## FORMAT
- Use Markdown formatting
- Keep it concise - no fluff
- Use tables for structured data
- Use code blocks for commands
- Maximum 100 lines
```

---

## Example Output

When you use the above prompt with this context:

```
Project Name: Resume Analyzer
One-line Description: Analyze resume against job description, get match score and suggestions
Tech Stack: React 19, TypeScript, Vite 7, Tailwind CSS, Google Gemini API
How to Run: npm install && npm run dev
```

**AI will generate something like:**

```markdown
# Resume Analyzer

Analyze your resume against job descriptions to get match scores and actionable improvement suggestions.

## Tech Stack

| Category | Technology |
|----------|------------|
| Frontend | React 19 + TypeScript |
| Build | Vite 7 + SWC |
| Styling | Tailwind CSS |
| AI/LLM | Google Gemini API |
| PDF Parsing | pdf.js (client-side) |

## Quick Start

```bash
# Clone the repository
git clone <repo-url>
cd resume-analyzer

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Add your GEMINI_API_KEY to .env

# Start development server
npm run dev
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server with HMR |
| `npm run build` | TypeScript compile + production build |
| `npm run lint` | Run ESLint |
| `npm run preview` | Preview production build |

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_GEMINI_API_KEY` | Google Gemini API key | Yes |

## Project Structure

```
src/
├── components/     # UI components
├── services/       # API integrations
├── utils/          # Helper functions
├── types/          # TypeScript types
├── constants/      # App constants
└── App.tsx         # Main component
```
```

---

## Tips for Better Results

### Tip 1: Be Specific About Tech Stack
```
❌ "Frontend framework"
✅ "React 19 with TypeScript 5.3"
```

### Tip 2: Include Constraints
```
Add to your prompt:
"Keep the README under 80 lines"
"Don't include Contributing section"
"Focus on quick start - assume reader wants to run it fast"
```

### Tip 3: Iterate If Needed
First response not perfect? Follow up with:
```
"Add a Troubleshooting section with 3 common issues"
"Remove the badges section"
"Make the Quick Start steps numbered instead of bullets"
```

---

## Quick Reference Card

| What You Want | Add This to Prompt |
|---------------|-------------------|
| Shorter README | "Maximum 50 lines" |
| More detail | "Include API documentation section" |
| Badges | "Add shields.io badges for build, license, version" |
| No emojis | "Professional tone, no emojis" |
| Specific sections only | "Only include: Quick Start, Tech Stack, Scripts" |

---

## Related Files

- [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) - Business context and user flows
- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Code conventions
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

---

*This template is part of the AI Workshop materials. Use it to create consistent, AI-friendly documentation.*
