# Architecture Documentation Template

> **AI Prompting Techniques Used:** `Chain of Thought (CoT)` + `Role-Based Prompting`
>
> This template uses Chain of Thought to make AI reason step-by-step through complex architecture decisions, and Role-Based prompting for expert-level technical analysis.

---

## What is Chain of Thought (CoT) Prompting?

**Definition:** Asking AI to "think step by step" or show its reasoning process before giving a final answer.

**Why it works:** For complex problems, AI makes fewer errors when it reasons through intermediate steps rather than jumping to conclusions.

**When to use:**
- Complex technical decisions
- Debugging and troubleshooting
- Architecture analysis
- Any multi-step problem

**Structure:**
```
[Your question/problem]

Think through this step-by-step:
1. First, identify [X]
2. Then, analyze [Y]
3. Consider [Z]
4. Finally, provide your recommendation
```

**Example:**
```
❌ Without CoT:
"Should I use Redux or Context API?"
→ AI gives generic answer without considering your specifics

✅ With CoT:
"Should I use Redux or Context API for my app?

Think step-by-step:
1. First, analyze my app's state complexity (I have 5 global states)
2. Then, consider update frequency (user data updates rarely, UI state updates often)
3. Evaluate team familiarity (team knows Context, not Redux)
4. Consider bundle size impact
5. Finally, recommend with reasoning"
→ AI provides thoughtful, context-aware recommendation
```

---

## How to Use This Template

### Step 1: Copy the Prompt Below
### Step 2: Fill in Your Architecture Details
### Step 3: Feed to AI for Architecture Documentation

**Compatible Tools:**
- ChatGPT (Free)
- Google Gemini
- Continue.dev (VSCode)
- Codeium (VSCode)

---

## Prompt to Generate ARCHITECTURE.md

```markdown
## ROLE
You are a senior software architect with 15 years of experience. You think systematically about system design, data flow, and technical tradeoffs. You create documentation that helps developers understand not just WHAT the architecture is, but WHY decisions were made.

## CONTEXT
I need an ARCHITECTURE.md file that documents my system architecture. This will be fed to AI tools when asking about where code should go, how data flows, and architectural decisions.

**Project Type:** [WEB_APP/API/MOBILE/etc]
**Tech Stack:** [YOUR_TECHNOLOGIES]
**Key Components:** [LIST_MAIN_PARTS]
**Data Flow:** [BRIEF_DESCRIPTION]
**External Services:** [APIS_DATABASES_etc]

## TASK
Generate an ARCHITECTURE.md with:

1. **System Architecture Diagram** (ASCII art)
2. **Data Flow** - Read and Write operations step-by-step
3. **Key Technical Decisions** - Table with decision, alternatives, choice, and why
4. **Module Dependencies** - What can import what
5. **Error Handling Strategy** - How errors flow through the system
6. **Environment Configuration** - Different environments and their setup

Think through each section step-by-step before writing it.

## FORMAT
For the architecture diagram, use ASCII art like this:
```
┌─────────────┐     ┌─────────────┐
│  Component  │────▶│  Component  │
└─────────────┘     └─────────────┘
```

For data flow, use numbered steps showing the exact path data takes.

For technical decisions, use this table format:
| Decision | Alternatives | Choice | Why |
|----------|--------------|--------|-----|
```

---

## Example Output

When you use the above prompt with this context:

```
Project Type: Web App (SPA)
Tech Stack: React 19, TypeScript, Vite, Tailwind, Google Gemini API
Key Components: PDF Upload, Text Input, AI Analysis, Results Display
Data Flow: User uploads PDF → Extract text → Send to Gemini → Display results
External Services: Google Gemini API (free tier)
```

**AI will generate:**

```markdown
# Architecture Overview

## System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         BROWSER (Client-Side Only)                │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      React Application                       │ │
│  │                                                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │ │
│  │  │   Upload     │  │   Input      │  │   Results    │      │ │
│  │  │  Component   │  │  Component   │  │  Component   │      │ │
│  │  │  (PDF file)  │  │ (Job Desc)   │  │  (Display)   │      │ │
│  │  └──────┬───────┘  └──────┬───────┘  └──────▲───────┘      │ │
│  │         │                 │                  │               │ │
│  │         ▼                 ▼                  │               │ │
│  │  ┌──────────────────────────────────────────┴─────────────┐ │ │
│  │  │                    App State (useState)                 │ │ │
│  │  │  - resumeText: string                                   │ │ │
│  │  │  - jobDescription: string                               │ │ │
│  │  │  - analysisResult: AnalysisResult | null                │ │ │
│  │  │  - status: 'idle' | 'loading' | 'success' | 'error'     │ │ │
│  │  └──────────────────────────┬─────────────────────────────┘ │ │
│  │                              │                               │ │
│  │                              ▼                               │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │                    Services Layer                        │ │ │
│  │  │  ┌─────────────┐    ┌─────────────┐                     │ │ │
│  │  │  │ pdfService  │    │geminiService│                     │ │ │
│  │  │  │ (pdf.js)    │    │ (API calls) │                     │ │ │
│  │  │  └─────────────┘    └──────┬──────┘                     │ │ │
│  │  └────────────────────────────┼────────────────────────────┘ │ │
│  └───────────────────────────────┼──────────────────────────────┘ │
│                                  │                                 │
└──────────────────────────────────┼─────────────────────────────────┘
                                   │ HTTPS
                                   ▼
                    ┌──────────────────────────────┐
                    │     Google Gemini API        │
                    │   (External - Free Tier)     │
                    └──────────────────────────────┘
```

## Data Flow

### Read Flow: PDF to Text
```
Step-by-step reasoning:
1. User needs to upload a file
2. We need to extract text without server
3. pdf.js can do client-side extraction
4. Extracted text goes to state

Flow:
User selects PDF → FileInput onChange triggers
    → pdfService.extractText(file) called
    → pdf.js parses PDF in browser (no upload)
    → Returns extracted text
    → setResumeText(text) updates state
    → UI shows success indicator
```

### Write Flow: Analysis Request
```
Step-by-step reasoning:
1. User has both texts ready
2. We need to send to Gemini API
3. API key must be protected (env variable)
4. Response needs parsing into our format

Flow:
User clicks "Analyze" → handleAnalyze() triggered
    → Validate both texts exist
    → setStatus('loading')
    → geminiService.analyze(resumeText, jobDescription) called
    → Construct prompt with both texts
    → Fetch to Gemini API with API key
    → Parse JSON response
    → setAnalysisResult(parsed)
    → setStatus('success')
    → UI renders results

Error path:
    → API error caught
    → setStatus('error')
    → setError(message)
    → UI shows error message
```

## Key Technical Decisions

| Decision | Alternatives Considered | Choice | Reasoning |
|----------|------------------------|--------|-----------|
| Client-side PDF parsing | Server-side parsing, third-party service | pdf.js client-side | No server needed, privacy (file never uploaded), free |
| Gemini over GPT | OpenAI GPT-4, Claude API, local LLM | Google Gemini | Free tier generous, good quality, simple API |
| No backend | Vercel serverless, Express server | Pure client-side | Simpler deployment, no server costs, API key in env |
| useState over Redux | Redux, Zustand, Jotai | useState | Simple app, <5 state variables, no complex updates |
| Tailwind CSS | CSS Modules, styled-components | Tailwind | Rapid development, consistent design, small bundle |
| Vite over CRA | Create React App, Next.js | Vite | Faster dev server, simpler config, modern defaults |

## Module Dependencies

```
Allowed Import Directions:

┌─────────────────────────────────────────────────────────┐
│                    Components                            │
│  (Can import: hooks, services, utils, types, constants)  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                      Hooks                               │
│  (Can import: services, utils, types, constants)         │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Services                              │
│  (Can import: utils, types, constants)                   │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Utils / Types / Constants                   │
│  (Can import: only each other, no circular)              │
└─────────────────────────────────────────────────────────┘

Rules:
✅ Components → Services (allowed)
✅ Hooks → Utils (allowed)
❌ Services → Components (NOT allowed)
❌ Utils → Hooks (NOT allowed)
❌ Any circular imports (NOT allowed)
```

## Error Handling Strategy

```typescript
// Error flow through the system:

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Service   │────▶│    Hook     │────▶│  Component  │
│  (throws)   │     │  (catches)  │     │  (displays) │
└─────────────┘     └─────────────┘     └─────────────┘

// Service Layer: Throws specific errors
class GeminiApiError extends Error {
  constructor(message: string, public code: string) {
    super(message);
  }
}

// Hook/Component Layer: Catches and transforms
try {
  const result = await geminiService.analyze(...);
  setResult(result);
} catch (error) {
  if (error instanceof GeminiApiError) {
    setError(getUserFriendlyMessage(error.code));
  } else {
    setError('Something went wrong. Please try again.');
  }
  console.error('[Analysis Error]:', error);
}

// Error Code Mapping:
const ERROR_MESSAGES = {
  'RATE_LIMIT': 'Too many requests. Please wait a moment.',
  'INVALID_KEY': 'API configuration error. Check setup.',
  'NETWORK': 'Connection failed. Check your internet.',
  'PARSE_ERROR': 'Could not read the PDF. Try another file.',
};
```

## Environment Configuration

| Environment | API URL | Features | Notes |
|-------------|---------|----------|-------|
| Development | localhost:5173 | Hot reload, debug logs | Use `.env.local` |
| Production | your-domain.com | Minified, no logs | Use environment variables in hosting |

### Environment Variables

```bash
# .env.local (development)
VITE_GEMINI_API_KEY=your_dev_api_key

# Production (set in hosting platform)
VITE_GEMINI_API_KEY=your_prod_api_key
```

### Security Notes
- API key exposed in client-side code (acceptable for free tier)
- For production with paid API, use serverless function as proxy
- No user data stored or transmitted to our servers
```

---

## Tips for Architecture Questions

### Tip 1: Ask "Where Should This Go?"
```
"Here's my architecture:
[Paste ARCHITECTURE.md]

I need to add a feature that caches analysis results.
Think step-by-step:
1. Where in the architecture should caching logic live?
2. What are the tradeoffs of different approaches?
3. Recommend the best approach for this architecture."
```

### Tip 2: Ask for Architecture Review
```
"Here's my current architecture:
[Paste ARCHITECTURE.md]

I'm planning to add:
[Describe new feature]

Think step-by-step:
1. Does this fit existing patterns?
2. What could go wrong?
3. Any simpler alternatives?
4. Specific recommendations?"
```

### Tip 3: Debug Data Flow Issues
```
"Here's my architecture:
[Paste data flow section]

Bug: Analysis results show briefly then disappear.

Think step-by-step through the data flow:
1. Where does data enter?
2. What could cause it to be lost?
3. Most likely cause?
4. How to fix?"
```

---

## When to Update This File

Update ARCHITECTURE.md when:
- [ ] Adding new external services
- [ ] Changing data flow patterns
- [ ] Making significant technical decisions
- [ ] Adding new layers or modules
- [ ] Changing state management approach

---

## Related Files

- [README.md](./README.md) - Project overview
- [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) - Business logic
- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Code conventions

---

*This template is part of the AI Workshop materials. Feed this file to AI when asking about system design, data flow, or where to put new code.*
