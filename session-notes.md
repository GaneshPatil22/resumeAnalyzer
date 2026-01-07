# AI WORKSHOP SESSION NOTES
## Practical AI for Developers — From Prompting to Project Automation

**Duration:** 90-120 minutes | **Format:** Online Live Session

---

# WORKSHOP FLOW OVERVIEW

| Section | Topic | Time |
|---------|-------|------|
| 1 | Opening + R-C-T-F Framework | 15 min |
| 2 | Prompting Techniques Deep Dive | 20 min |
| 3 | MD Files as Project Brain | 25 min |
| 4 | Daily Developer Automations | 15 min |
| 5 | N8N Automation Teaser | 15 min |
| 6 | Live Build: Resume Analyzer | 25 min |
| - | Buffer/Q&A | 5 min |

---

# SECTION 1: HOW TO TALK TO AI — THE R-C-T-F FRAMEWORK
**Time: 15 minutes**

## Opening Hook (2 min)

**SAY THIS:**
> "Quick show of hands in chat — how many of you have asked ChatGPT something and thought 'this response is completely useless'? 
>
> Yeah, me too. Constantly. Until I figured out WHY.
>
> Here's the thing — most of us talk to AI like we talk to Google. We type 'best way to handle authentication' and expect magic. But AI isn't Google. Google finds existing answers. AI GENERATES answers based on what you tell it.
>
> Think of it this way: **AI is like a brilliant intern on their first day.** They graduated top of their class, they know everything in theory, but they have ZERO context about your project, your codebase, your constraints. If you say 'fix the bug,' they'll stare at you blankly. If you say 'In our React app, there's a useEffect that's causing infinite re-renders on the UserProfile component when fetching data — here's the code — can you spot the dependency array issue?' — NOW they can help."

**PAUSE — Let this sink in**

## The R-C-T-F Framework (8 min)

**SAY THIS:**
> "So how do we give AI the right instructions? I use something I call R-C-T-F. It's not fancy, but it works every single time."

**Write on screen:**
```
R = Role      → Who should AI be?
C = Context   → What's the background?
T = Task      → What exactly should it do?
F = Format    → How should the output look?
```

### Breaking Down Each Letter:

**R = ROLE**
> "This is like casting an actor. You're not just asking 'anyone' — you're asking a SPECIFIC expert. Watch the difference:
>
> ❌ 'Write code for login'
> ✅ 'You are a senior backend developer with 10 years of Node.js experience who prioritizes security...'
>
> Why does this matter? Because AI has ALL the knowledge — from a junior dev's approach to a FAANG architect's approach. The role tells it WHICH knowledge to use."

**C = CONTEXT**
> "Context is everything the AI DOESN'T know but NEEDS to know. Your tech stack. Your constraints. What you've already tried. The business requirement.
>
> Here's my rule: If you'd tell it to a new team member, tell it to AI."

**T = TASK**
> "Be stupidly specific. Not 'help me with this code' but 'review this code for memory leaks, suggest fixes, and explain why each fix works.'
>
> The more specific your task, the less you'll need to ask follow-up questions."

**F = FORMAT**
> "This is the secret weapon most people skip. Tell AI exactly how you want the output:
> - 'Give me a bullet list'
> - 'Use markdown with code blocks'
> - 'Start with a summary, then details'
> - 'Maximum 5 bullet points'
>
> Format prevents AI from writing essays when you need a quick answer."

## Live Demo: Bad vs Good Prompt (5 min)

**SAY THIS:**
> "Let me show you this in action. I'm going to type the exact same request two ways."

### Bad Prompt (Type this live):
```
write a function to validate email
```

**Show the output** — Point out:
- Generic solution
- No error handling approach specified
- No language preference respected
- Missing edge cases

### Good Prompt with R-C-T-F (Type this live):
```
ROLE: You are a senior TypeScript developer who writes production-grade code with comprehensive error handling.

CONTEXT: I'm building a user registration form for a B2B SaaS application. We need strict email validation because our users are enterprise customers who sometimes have complex email formats (subdomains, plus addressing, etc.). We're using React with TypeScript.

TASK: Write an email validation function that:
1. Validates standard email formats
2. Handles edge cases (plus addressing like user+tag@domain.com)
3. Returns specific error messages for different failure types
4. Is easy to unit test

FORMAT: 
- Provide the TypeScript function with full type definitions
- Add JSDoc comments explaining the regex pattern
- Include 5 example test cases at the bottom
- Keep the code under 50 lines
```

**Show the output** — Point out:
- Specific to TypeScript
- Has proper error messages
- Includes test cases as requested
- Production-ready quality

**ENGAGEMENT:**
> "See the difference? Same task, completely different output. Drop a '🔥' in chat if this clicks."

---

# SECTION 2: COMMON PROMPTING TECHNIQUES
**Time: 20 minutes**

**TRANSITION:**
> "Now that you know HOW to structure prompts, let's talk about different TECHNIQUES. Think of these as tools in your toolbox — each one is best for different situations."

## Technique 1: Zero-Shot Prompting

**WHAT IT IS:** Asking AI to do something with NO examples — just instructions.

**WHEN TO USE:** Simple, well-defined tasks where AI's default knowledge is enough.

**SAY THIS:**
> "Zero-shot is what most of you already do. You give a task, AI figures it out. Works great for simple stuff."

**EXAMPLE PROMPT:**
```
Convert this JavaScript function to Python:

function calculateTotal(items) {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

**EXPECTED OUTPUT:** Direct Python translation with equivalent syntax.

---

## Technique 2: Few-Shot Prompting

**WHAT IT IS:** Giving AI 2-4 examples BEFORE your actual request, so it learns the pattern.

**WHEN TO USE:** When you need consistent formatting, specific style, or custom transformations.

**SAY THIS:**
> "Few-shot is like showing a new designer your brand guidelines before they create something. You're saying 'THIS is what good looks like, now do one for me.'
>
> This is HUGE for consistency — especially when you need the same format across multiple items."

**EXAMPLE PROMPT:**
```
Convert plain error messages into user-friendly messages following this pattern:

Example 1:
Input: "ERR_CONNECTION_REFUSED"
Output: "We couldn't reach the server. Please check your internet connection and try again."

Example 2:
Input: "VALIDATION_FAILED_EMAIL"  
Output: "The email address doesn't look quite right. Please double-check the format."

Example 3:
Input: "AUTH_TOKEN_EXPIRED"
Output: "Your session has expired for security. Please sign in again to continue."

Now convert:
Input: "RATE_LIMIT_EXCEEDED"
```

**EXPECTED OUTPUT:** User-friendly message matching the tone and format of examples.

---

## Technique 3: Chain of Thought (CoT)

**WHAT IT IS:** Asking AI to "think step by step" before giving the final answer.

**WHEN TO USE:** Complex problems, debugging, logic-heavy tasks, anything where you need to SEE the reasoning.

**SAY THIS:**
> "This is my favorite technique. It's like asking someone to show their work in math class.
>
> Instead of AI just giving you an answer (which might be wrong), it walks through its thinking. This makes it WAY more accurate AND you can spot where it goes wrong."

**EXAMPLE PROMPT:**
```
I have a React component that re-renders infinitely. Think through this step-by-step:

1. First, identify what typically causes infinite re-renders
2. Then, analyze this specific code for each cause
3. Finally, provide the fix with explanation

Here's the code:
const UserProfile = ({ userId }) => {
    const [user, setUser] = useState(null);
    
    useEffect(() => {
        fetchUser(userId).then(setUser);
    });
    
    return <div>{user?.name}</div>;
};
```

**EXPECTED OUTPUT:** Step-by-step analysis identifying the missing dependency array, explaining WHY it causes infinite loops, and providing the fix.

---

## Technique 4: Role-Based Prompting

**WHAT IT IS:** Assigning AI a specific expert persona before the task.

**WHEN TO USE:** When you need domain-specific expertise or a particular perspective.

**SAY THIS:**
> "We covered this in R-C-T-F, but it's so powerful it deserves its own spotlight. Different roles = different answers."

**EXAMPLE PROMPT:**
```
You are a senior security engineer conducting a code review. Your job is to find vulnerabilities, not praise the code.

Review this authentication endpoint and list ONLY security concerns:

app.post('/login', async (req, res) => {
    const { email, password } = req.body;
    const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`);
    if (user && user.password === password) {
        const token = jwt.sign({ userId: user.id }, 'secret123');
        res.json({ token });
    }
    res.status(401).json({ error: 'Invalid credentials' });
});
```

**EXPECTED OUTPUT:** List of security issues: SQL injection, plain text password comparison, hardcoded JWT secret, missing rate limiting, etc.

---

## Technique 5: Constraint-Based Prompting

**WHAT IT IS:** Setting explicit boundaries on what AI can/cannot do.

**WHEN TO USE:** When you need specific output limits, want to exclude certain solutions, or need focused answers.

**SAY THIS:**
> "Constraints prevent AI from going off on tangents. It's like telling a contractor 'budget is $10K, must be done in 2 weeks, no structural changes.' Clear boundaries = focused solutions."

**EXAMPLE PROMPT:**
```
Suggest ways to improve this function's performance.

CONSTRAINTS:
- Do NOT suggest changing the data structure (we're locked into this API response format)
- Do NOT suggest caching (we need real-time data)
- Do NOT use any external libraries
- Maximum 3 suggestions
- Each suggestion must include Big O improvement

function findDuplicates(arr) {
    const duplicates = [];
    for (let i = 0; i < arr.length; i++) {
        for (let j = i + 1; j < arr.length; j++) {
            if (arr[i] === arr[j] && !duplicates.includes(arr[i])) {
                duplicates.push(arr[i]);
            }
        }
    }
    return duplicates;
}
```

**EXPECTED OUTPUT:** Exactly 3 focused suggestions within constraints, with Big O analysis.

---

## Technique 6: Iterative Refinement

**WHAT IT IS:** Building on AI's response with follow-up prompts to improve it.

**WHEN TO USE:** Complex tasks where the first output needs improvement, or when requirements evolve.

**SAY THIS:**
> "This is how professionals actually work with AI. You rarely get perfect output on the first try. The skill is knowing HOW to refine.
>
> Think of it like sculpting — you start with a rough shape, then refine details."

**EXAMPLE SEQUENCE:**

**Prompt 1:**
```
Write a README for a Node.js REST API that manages a todo list.
```

**After seeing output, Prompt 2:**
```
Good start. Now improve it:
1. Add a "Quick Start" section with actual terminal commands
2. Add API endpoint table with example request/response
3. Make the installation steps numbered, not bullets
4. Add badges for Node version, license, and build status at the top
```

**After seeing output, Prompt 3:**
```
Almost there. Final tweaks:
- Add a "Troubleshooting" section with 3 common issues
- Add environment variables table with descriptions
- Remove the "Contributing" section, we don't need it
```

**EXPECTED OUTPUT:** Professional README that evolved through 3 iterations.

**ENGAGEMENT:**
> "Which technique do you think you'll use most? Drop a number 1-6 in the chat!"

---

# SECTION 3: MD FILES AS YOUR PROJECT BRAIN
**Time: 25 minutes**

**TRANSITION:**
> "Okay, now we're getting to the good stuff. Everything we've covered works for one-off prompts. But what about when you're working on a PROJECT? When AI needs to understand your ENTIRE codebase, your architecture, your conventions?
>
> This is where most developers struggle. They ask AI about their project, and AI gives generic answers because it has NO CONTEXT.
>
> The solution? Markdown files. Your project's brain dump that you can feed to AI anytime."

## Why MD Files Matter

**SAY THIS:**
> "Here's the reality: AI can't read your mind, and it can't read your codebase... unless you TELL it.
>
> These four files are like giving AI a 2-week onboarding in 30 seconds:
> - README.md — The 'what is this' file
> - PROJECT_CONTEXT.md — The 'why does this exist' file  
> - CODING_GUIDELINES.md — The 'how we do things here' file
> - ARCHITECTURE.md — The 'how it's built' file
>
> Create these once, use them forever. Every time you prompt AI about your project, paste the relevant file first."

---

## File 1: README.md

**PURPOSE:** Quick overview for anyone (human OR AI) encountering your project for the first time.

**SAY THIS:**
> "Your README should answer: What is this? How do I run it? What's the tech stack? That's it. Keep it practical."

**TEMPLATE:**
```markdown
# Project Name

One-line description of what this project does.

## Tech Stack

| Category | Technology |
|----------|------------|
| Frontend | React 18, TypeScript, TailwindCSS |
| State | Zustand |
| API | REST, Axios |
| Testing | Jest, React Testing Library |
| Build | Vite |

## Quick Start

```bash
# Clone the repository
git clone https://github.com/username/project.git

# Navigate to project
cd project

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Start development server
npm run dev
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server at localhost:5173 |
| `npm run build` | Create production build |
| `npm run test` | Run test suite |
| `npm run lint` | Run ESLint |

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_API_URL` | Backend API base URL | Yes |
| `VITE_GA_ID` | Google Analytics ID | No |

## Project Status

🟢 Active Development — v1.2.0
```

**HOW TO USE WITH AI:**
```
Here's my project README for context:

[PASTE README.md]

Now, [YOUR SPECIFIC QUESTION]
```

---

## File 2: PROJECT_CONTEXT.md

**PURPOSE:** Business logic, user stories, what problem this solves — the HUMAN understanding.

**SAY THIS:**
> "This is the file that makes AI understand WHY your code does what it does. Without this, AI gives technically correct but contextually wrong answers."

**TEMPLATE:**
```markdown
# Project Context: [Project Name]

## Problem Statement

[2-3 sentences: What problem does this solve? Who has this problem?]

Example: "Small business owners waste 5+ hours weekly manually matching invoices to payments. Our app automates this reconciliation, reducing the process to minutes."

## Target Users

- **Primary:** [Who uses this daily?]
- **Secondary:** [Who uses this occasionally?]
- **Admin:** [Who manages/configures?]

## Core User Flows

### Flow 1: [Name]
1. User does X
2. System responds with Y
3. User sees Z

### Flow 2: [Name]
1. ...

## Business Rules

- [Rule 1: e.g., "Users can only belong to one organization"]
- [Rule 2: e.g., "Free tier limited to 100 records/month"]
- [Rule 3: e.g., "All amounts stored in cents, displayed in dollars"]

## Key Domain Terms

| Term | Meaning in THIS Project |
|------|------------------------|
| Workspace | A company's isolated data container |
| Member | User with access to a workspace |
| Reconciliation | Matching invoice to payment |

## What This Project is NOT

- Not a full accounting system
- Not a payment processor (we don't handle money)
- Not multi-currency (USD only for v1)

## Current Limitations / Known Issues

- Large file uploads (>10MB) timeout on slow connections
- Search doesn't support fuzzy matching yet
- Mobile view is functional but not optimized
```

**HOW TO USE WITH AI:**
```
Before you help me, understand what this project is about:

[PASTE PROJECT_CONTEXT.md]

Now, I need to [YOUR TASK]. Make sure your solution aligns with our business rules and user flows.
```

---

## File 3: CODING_GUIDELINES.md

**PURPOSE:** How you write code in THIS project — naming, patterns, conventions.

**SAY THIS:**
> "This file is your team's style guide. When AI generates code, it should MATCH your existing patterns. This file makes that happen."

**TEMPLATE:**
```markdown
# Coding Guidelines

## Naming Conventions

### Files & Folders
- Components: PascalCase → `UserProfile.tsx`
- Hooks: camelCase with 'use' prefix → `useAuth.ts`
- Utils: camelCase → `formatDate.ts`
- Constants: SCREAMING_SNAKE_CASE → `API_ENDPOINTS.ts`

### Variables & Functions
- Boolean variables: `is`, `has`, `should` prefix → `isLoading`, `hasAccess`
- Event handlers: `handle` prefix → `handleSubmit`, `handleClick`
- Async functions: descriptive verb → `fetchUsers`, `createOrder`

### Component Props
```typescript
// Always define props interface above component
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  isEditable?: boolean;  // Optional props last
}
```

## Patterns We Use

### State Management
- Local UI state: useState
- Shared state: Zustand store
- Server state: React Query
- NO prop drilling beyond 2 levels — use context or store

### API Calls
- All API calls through `/services` layer
- Never call fetch/axios directly in components
- Always handle loading, error, success states

```typescript
// ✅ Good
const users = await userService.getAll();

// ❌ Bad
const users = await axios.get('/api/users');
```

### Error Handling
- Use custom Error classes
- Always show user-friendly messages
- Log technical details to console

```typescript
// ✅ Good
try {
  await submitForm(data);
} catch (error) {
  toast.error(getUserFriendlyMessage(error));
  console.error('Form submission failed:', error);
}
```

## Patterns to AVOID

- ❌ `any` type (use `unknown` if type is truly unknown)
- ❌ Nested ternaries beyond 1 level
- ❌ Magic numbers/strings — use constants
- ❌ Console.log in production code
- ❌ Commented-out code — delete it
- ❌ Functions longer than 50 lines

## File Structure Convention

```
src/
├── components/
│   ├── common/          # Reusable UI components
│   ├── features/        # Feature-specific components
│   └── layout/          # Layout components
├── hooks/               # Custom hooks
├── services/            # API service layer
├── stores/              # Zustand stores
├── types/               # TypeScript types/interfaces
├── utils/               # Utility functions
└── constants/           # App constants
```

## Testing Conventions

- Test file next to source: `Button.tsx` → `Button.test.tsx`
- Test description format: `should [action] when [condition]`
- Minimum: Test happy path + one error case
```

**HOW TO USE WITH AI:**
```
Follow these coding guidelines for our project:

[PASTE CODING_GUIDELINES.md]

Now write a [component/function/etc] for [YOUR TASK].
```

---

## File 4: ARCHITECTURE.md

**PURPOSE:** Technical architecture, data flow, system design — the HOW of your codebase.

**SAY THIS:**
> "This is for complex questions. When you're asking AI about 'where should this live' or 'how does data flow' — this file gives it the mental model."

**TEMPLATE:**
```markdown
# Architecture Overview

## System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                        Frontend                          │
│  React + TypeScript + TailwindCSS (Vite)                │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Pages     │  │ Components  │  │   Stores    │     │
│  │  (routes)   │→ │   (UI)      │← │  (Zustand)  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│         │                │               ↑               │
│         └────────────────┴───────────────┘               │
│                          │                               │
│                   ┌──────┴──────┐                       │
│                   │  Services   │                       │
│                   │  (API Layer)│                       │
│                   └──────┬──────┘                       │
└──────────────────────────┼───────────────────────────────┘
                           │
                    [REST API Calls]
                           │
┌──────────────────────────┼───────────────────────────────┐
│                          ↓                               │
│                      Backend                             │
│         Node.js + Express + PostgreSQL                   │
└──────────────────────────────────────────────────────────┘
```

## Data Flow

### Read Flow (Getting Data)
1. Component mounts → calls custom hook
2. Hook checks Zustand store for cached data
3. If no cache → calls service layer
4. Service makes API request
5. Response stored in Zustand
6. Component re-renders with data

### Write Flow (Saving Data)  
1. User submits form → handler calls service
2. Service makes POST/PUT/DELETE request
3. On success → invalidate/update Zustand store
4. Optimistic UI updates where appropriate

## Key Architectural Decisions

| Decision | Reason |
|----------|--------|
| Zustand over Redux | Simpler API, less boilerplate for our scale |
| REST over GraphQL | Team familiarity, simpler caching |
| Vite over CRA | Faster builds, better DX |
| TailwindCSS | Rapid prototyping, consistent design |

## Module Dependencies

```
Pages → Components → Hooks → Services → API
         ↓
       Stores
```

- Pages can import: Components, Hooks
- Components can import: Hooks, other Components, Utils
- Hooks can import: Services, Stores, Utils
- Services can import: API client, Types
- NO circular dependencies allowed

## Authentication Flow

1. User logs in → credentials sent to /auth/login
2. Server validates → returns JWT + refresh token
3. JWT stored in memory (Zustand)
4. Refresh token in httpOnly cookie
5. Axios interceptor adds JWT to all requests
6. 401 response → interceptor tries refresh
7. Refresh fails → redirect to login

## Environment Configuration

| Environment | API URL | Features |
|-------------|---------|----------|
| Development | localhost:3001 | Mock data, debug tools |
| Staging | api.staging.app.com | Real data, logging |
| Production | api.app.com | Real data, error tracking |
```

**HOW TO USE WITH AI:**
```
Here's our system architecture:

[PASTE ARCHITECTURE.md]

I need to add a new feature: [FEATURE]. 
- Which layer should the logic live in?
- What's the data flow?
- Any architectural concerns?
```

---

## Live Demo: With vs Without Context Files (5 min)

**SAY THIS:**
> "Let me show you why these files are game-changers."

### Without Context:
```
Write a function to format user display names.
```

**Output:** Generic function, doesn't match your conventions.

### With Context:
```
Follow these coding guidelines:
[Paste CODING_GUIDELINES.md section on naming]

Our business context:
- Users can have firstName, lastName, or just email
- Display name priority: fullName > firstName > email username

Write a function to format user display names.
```

**Output:** Function matching your conventions, handling your specific business cases.

**ENGAGEMENT:**
> "These four files take maybe 2 hours to create initially. But they save you HUNDREDS of hours of fixing AI's generic output. Worth it? Drop a 👍 in chat."

---

# SECTION 4: AI AUTOMATIONS FOR DAILY DEVELOPER WORK
**Time: 15 minutes**

**TRANSITION:**
> "We've covered prompting and project context. Now let's get practical — automations you can set up TODAY that will save time EVERY day."

## 4.1 Git Commit Message Generator

**SAY THIS:**
> "Writing good commit messages is important but tedious. Let AI do it."

**SETUP:**
1. Create a file `generate-commit.md` in your project root
2. Stage your changes: `git add .`
3. Run: `git diff --staged | pbcopy` (Mac) or `git diff --staged | clip` (Windows)
4. Paste to ChatGPT with this prompt:

**PROMPT TEMPLATE:**
```
You are a senior developer who writes clear, conventional commit messages.

CONVENTIONS:
- Format: <type>(<scope>): <description>
- Types: feat, fix, docs, style, refactor, test, chore
- Description: imperative mood, lowercase, no period
- Max 72 characters for subject line
- Add body if change is significant

STAGED CHANGES:
[PASTE GIT DIFF HERE]

Generate the commit message. If multiple distinct changes, suggest splitting into separate commits.
```

**DEMO:** Show real git diff → AI generates message like:
```
feat(auth): add password reset email functionality

- Add sendResetEmail service method
- Create email template with reset link
- Add rate limiting (3 requests/hour)
```

---

## 4.2 AI as PR Reviewer (Code Level)

**SAY THIS:**
> "Before your human reviewers see your PR, let AI catch the obvious stuff."

**PROMPT TEMPLATE:**
```
You are a senior code reviewer. Your job is to be critical but constructive.

FOCUS AREAS:
- Bugs or logic errors
- Security vulnerabilities  
- Performance issues
- Code clarity and maintainability
- Missing error handling
- Test coverage gaps

CODE TO REVIEW:
[PASTE CODE]

Format your review as:
🔴 Critical: [Must fix before merge]
🟡 Warning: [Should fix, not blocking]
🟢 Suggestion: [Nice to have]
💡 Questions: [Need clarification]
```

**EXPECTED OUTPUT:** Structured review with prioritized issues.

---

## 4.3 AI as Architecture Reviewer (System Level)

**SAY THIS:**
> "For bigger changes — new features, system refactors — you need design review, not just code review."

**PROMPT TEMPLATE:**
```
You are a senior architect reviewing a proposed system change.

CURRENT ARCHITECTURE:
[Paste ARCHITECTURE.md or describe current state]

PROPOSED CHANGE:
[Describe what you want to add/change]

Review for:
1. Does this fit our existing patterns?
2. What are potential scaling issues?
3. What could go wrong? (Failure modes)
4. What's the migration path?
5. Any simpler alternatives?

Be critical. Point out things I might have missed.
```

---

## Tool Alternatives to Mention

**SAY THIS:**
> "Quick mention of other tools that do specific things well:
> - **Cursor** — IDE with built-in AI, great for code generation
> - **Continue.dev** — Open source, plugs into VS Code
> - **Cody by Sourcegraph** — Good for large codebase understanding
> - **GitHub Copilot** — Best for autocomplete as you type
>
> Each has strengths. Experiment and find your mix."

---

# SECTION 5: N8N AUTOMATION TEASER
**Time: 15 minutes**

**TRANSITION:**
> "Last section before our live build. Let me blow your mind real quick with N8N."

## What is N8N?

**SAY THIS:**
> "N8N is like Zapier but free and self-hosted. You can automate ANYTHING that has an API.
>
> The visual workflow builder means you can create automations without writing code. Perfect for tedious recurring tasks.
>
> I'm going to show you 5 automations you can build this weekend."

---

## Template 1: Job Finder Automation

**WHAT IT DOES:** Scrapes job boards, filters by your keywords, sends daily digest.

**NODES USED:**
- Schedule Trigger (daily)
- HTTP Request (job board APIs)
- IF (filter by keywords)
- Gmail/Slack (send notification)

**BUILD STEPS:**
1. Create new workflow
2. Add Schedule Trigger → set to 8 AM daily
3. Add HTTP Request → hit job board API (e.g., RemoteOK API)
4. Add IF node → filter: title contains "React" OR "Node"
5. Add Gmail node → send matching jobs as digest

---

## Template 2: Tech News Collector

**WHAT IT DOES:** Aggregates from multiple sources, summarizes with AI.

**NODES USED:**
- Schedule Trigger
- RSS Feed (multiple)
- Merge
- OpenAI (summarize)
- Gmail

**BUILD STEPS:**
1. Schedule Trigger → once daily
2. Add multiple RSS nodes (HackerNews, Dev.to, etc.)
3. Merge all feeds
4. OpenAI node → "Summarize these headlines, highlight top 5"
5. Gmail → send summary

---

## Template 3: GitHub Activity Digest

**WHAT IT DOES:** Weekly summary of repo activities.

**NODES USED:**
- Schedule Trigger (weekly)
- GitHub nodes (get commits, PRs, issues)
- OpenAI (summarize)
- Slack/Email

**BUILD STEPS:**
1. Weekly trigger
2. GitHub → Get commits from last 7 days
3. GitHub → Get merged PRs
4. GitHub → Get new issues
5. OpenAI → Generate summary
6. Slack → Post to team channel

---

## Template 4: Meeting Notes Processor

**WHAT IT DOES:** Takes raw notes, generates structured action items.

**NODES USED:**
- Webhook (trigger)
- OpenAI (process)
- Google Docs/Notion (save)
- Slack (notify)

**BUILD STEPS:**
1. Webhook → receives raw notes (from a form or direct POST)
2. OpenAI → extract action items, decisions, follow-ups
3. Google Docs → create formatted meeting notes
4. Slack → notify attendees with link

---

## Template 5: Social Media Content Scheduler

**WHAT IT DOES:** Simple posting automation.

**NODES USED:**
- Google Sheets (content calendar)
- Schedule Trigger
- Twitter/LinkedIn nodes

**BUILD STEPS:**
1. Google Sheet with columns: date, content, platform
2. Schedule Trigger → check daily
3. Filter → today's posts
4. Twitter/LinkedIn node → post content

---

**ENGAGEMENT:**
> "Which automation would save YOU the most time? Type the number 1-5 in chat!"

---

# SECTION 6: LIVE BUILD — REACTJS RESUME ANALYZER
**Time: 25 minutes**

**TRANSITION:**
> "Alright, grand finale. We're going to BUILD something together. Not a todo app. Something actually useful — a Resume Analyzer.
>
> Upload your resume, paste a job description, get a match score and suggestions. And we'll build it using EVERYTHING we learned today."

## Project Overview (2 min)

**SAY THIS:**
> "Here's what we're building:
> - Upload PDF resume
> - Paste job description
> - AI analyzes the match
> - Shows score, missing skills, and improved bullet points
>
> ALL client-side, FREE Gemini API, nothing fancy."

## Step 1: Create Project Context Files First (5 min)

**SAY THIS:**
> "Before we write any code, let's create our MD files. This is the practice we want to build."

**Live: Create PROJECT_CONTEXT.md for this app:**
```markdown
# Resume Analyzer - Project Context

## Problem Statement
Job seekers apply to dozens of positions without knowing if their resume matches. They waste time on poor-fit applications and miss opportunities where they'd be strong candidates.

## Solution
A simple tool that compares resume content against job descriptions, showing:
- Match percentage
- Missing skills/keywords
- Suggested improvements to existing bullet points

## Target Users
- Job seekers actively applying
- Career changers wanting to identify gaps
- Recruiters doing initial screenings

## Core Flow
1. User uploads resume (PDF)
2. User pastes job description
3. Click "Analyze"
4. See match score, gaps, and suggestions

## What This is NOT
- Not a resume builder
- Not a job board
- Not storing any user data
```

## Step 2: Use AI to Generate Component Structure (3 min)

**PROMPT:**
```
ROLE: Senior React developer

CONTEXT: Building a resume analyzer app. Tech: React + TypeScript + TailwindCSS + Gemini API. Must be 100% client-side.

TASK: Give me the component structure and file organization for:
- FileUpload component (PDF)
- JobDescriptionInput component (textarea)
- AnalyzeButton component  
- ResultsDisplay component (score, gaps, suggestions)

FORMAT: Folder structure with brief description of each file.
```

## Step 3: Build Components with AI (10 min)

**For each component, use R-C-T-F:**

**FileUpload Prompt:**
```
ROLE: Senior React TypeScript developer

CONTEXT: Resume analyzer app. Need to upload PDF and parse text client-side.
Using pdf.js (pdfjs-dist package).

TASK: Create FileUpload component that:
1. Accepts PDF drag-drop or click to upload
2. Parses PDF to text using pdfjs-dist
3. Passes extracted text to parent via callback
4. Shows upload status (idle, processing, done, error)

FORMAT:
- Full TypeScript component
- TailwindCSS styling
- Include the pdfjs-dist import and worker setup
```

**AnalysisService Prompt:**
```
ROLE: Senior developer integrating Gemini API

CONTEXT: Need to analyze resume text against job description using free Gemini API (gemini-pro model).

TASK: Create an analysis service that:
1. Takes resume text and job description
2. Calls Gemini API with a structured prompt
3. Returns: matchScore (0-100), missingSkills (array), improvedBullets (array)

FORMAT:
- TypeScript service file
- Include the Gemini API call setup
- Include the exact prompt used for analysis
- Handle errors gracefully
```

## Step 4: Iterative Refinement (5 min)

**SAY THIS:**
> "Watch how I refine the output. First result is never perfect."

**Refinement prompts:**
- "The PDF parsing isn't handling multi-page. Fix that."
- "Add loading skeleton to ResultsDisplay while analyzing."
- "The improved bullets should be editable. Add that UI."

## Wrap Up & Next Steps

**SAY THIS:**
> "That's the whole app, built with AI in 25 minutes. The key points:
> 1. We created context files FIRST
> 2. We used R-C-T-F for every prompt
> 3. We iterated and refined
>
> This is how you work with AI professionally. Not random prompts — structured collaboration."

---

# CLOSING (2 min)

**SAY THIS:**
> "Let's recap what you learned today:
> 
> ✅ R-C-T-F framework for prompts that work
> ✅ 6 prompting techniques for different situations  
> ✅ 4 MD files to give AI project context
> ✅ Git commit, PR, and architecture review automation
> ✅ N8N for workflow automation
> ✅ How to build a real project with AI assistance
>
> Here's my challenge: Pick ONE thing from today and implement it this week. Start with the MD files — they have the highest ROI.
>
> Questions? Drop them in chat. And if you found this valuable, I'd love a testimonial!
>
> Thanks everyone. Go build something great with AI!"

---

# Q&A BUFFER (5 min)

Keep these ready for common questions:
- "What about Copilot vs ChatGPT?" → Different tools, different strengths. Copilot for inline, ChatGPT for discussion.
- "Does this work with Claude?" → Yes, all techniques work with any LLM.
- "Is my code sent to AI servers?" → Yes with ChatGPT/Gemini. Self-host if sensitive.
- "Best model for coding?" → GPT-4 or Claude for complex, GPT-3.5/Gemini for simple.
