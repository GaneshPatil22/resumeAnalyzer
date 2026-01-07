# Project Context Template

> **AI Prompting Techniques Used:** `Role-Based Prompting` + `Few-Shot Prompting`
>
> This template uses Role-Based Prompting to get business-focused answers, and Few-Shot Prompting to show AI exactly the format you want through examples.

---

## What is Role-Based Prompting?

**Definition:** Assigning AI a specific expert persona before giving a task. Different roles produce different perspectives on the same problem.

**Why it works:** AI contains knowledge from many perspectives. The role tells it WHICH expert's viewpoint to use.

**Example - Same Question, Different Roles:**

```
Question: "How should we handle user authentication?"

Role: Security Engineer
→ "Use JWT with refresh tokens, implement rate limiting, add 2FA..."

Role: UX Designer
→ "Keep login simple, offer social login options, remember user preferences..."

Role: Business Analyst
→ "Consider user conversion rates, reduce friction, track login abandonment..."
```

---

## What is Few-Shot Prompting?

**Definition:** Providing 2-4 examples BEFORE your actual request, so AI learns the pattern you want.

**When to use:**
- Consistent formatting needed
- Specific style or tone required
- Custom transformations
- Non-obvious output structure

**Structure:**
```
Here are examples of what I want:

Example 1:
Input: [example input]
Output: [example output]

Example 2:
Input: [example input]
Output: [example output]

Now do this:
Input: [your actual input]
```

---

## How to Use This Template

### Step 1: Copy the Prompt Below
### Step 2: Fill in Your Project Details
### Step 3: Paste into Any Free AI Tool

**Compatible Tools:**
- ChatGPT (Free)
- Google Gemini
- Continue.dev (VSCode)
- Codeium (VSCode)

---

## Prompt to Generate PROJECT_CONTEXT.md

```markdown
## ROLE
You are a senior product manager who excels at documenting project context for development teams. You focus on the "what" and "why" - not the technical "how".

## CONTEXT
I need to create a PROJECT_CONTEXT.md file that helps any developer (human or AI) understand my project's business logic, user flows, and domain knowledge.

**Project Name:** [YOUR_PROJECT_NAME]
**What it does:** [BRIEF_DESCRIPTION]
**Who uses it:** [TARGET_USERS]
**Main problem it solves:** [PROBLEM_STATEMENT]

## TASK
Generate a PROJECT_CONTEXT.md with these sections:
1. Problem Statement (2-3 sentences)
2. Target Users (primary and secondary)
3. Core User Flows (step-by-step)
4. Business Rules (explicit constraints)
5. Domain Glossary (project-specific terms)
6. What This Project is NOT
7. Current Limitations

## FORMAT
Follow this example structure for User Flows:

**Example Flow Format:**
```
### Flow: User Registration
**Trigger:** User clicks "Sign Up"
1. User enters email and password
2. System validates email format
3. System checks if email exists
4. If new → create account, send verification
5. If exists → show "already registered" message
**Outcome:** User account created OR error shown
```

Use this same format for all flows in the document.
```

---

## Example Output

When you use the above prompt with this context:

```
Project Name: Resume Analyzer
What it does: Analyzes resume against job description, shows match score and suggestions
Who uses it: Job seekers, career changers, recruiters
Main problem it solves: Job seekers don't know if their resume matches job requirements
```

**AI will generate:**

```markdown
# Project Context: Resume Analyzer

## Problem Statement

Job seekers apply to dozens of positions without knowing if their resume truly matches. They waste time on poor-fit applications and miss opportunities where they'd be strong candidates. Manual comparison is tedious and subjective.

## Target Users

### Primary Users
- **Job Seekers**: Actively applying to positions, want to optimize each application
- **Career Changers**: Need to identify skill gaps for new target roles

### Secondary Users
- **Recruiters**: Quick initial screening of candidate-job fit
- **Career Coaches**: Helping clients improve their resumes

## Core User Flows

### Flow 1: Resume Analysis
**Trigger:** User wants to check resume-job match

1. User uploads PDF resume (max 5MB)
2. System extracts text from PDF client-side
3. User pastes job description into text area
4. User clicks "Analyze"
5. System sends both texts to Gemini API
6. AI returns: match score, missing skills, improved bullets
7. User sees results in formatted display

**Outcome:** User understands match quality and what to improve

### Flow 2: Copy Improved Content
**Trigger:** User wants to use AI suggestions

1. User reviews suggested bullet points
2. User clicks copy button on desired bullet
3. Content copied to clipboard
4. User pastes into their resume editor

**Outcome:** Resume improved with AI suggestions

## Business Rules

- **BR-001:** Resume file must be PDF format only
- **BR-002:** Maximum file size is 5MB
- **BR-003:** All processing happens client-side (no server storage)
- **BR-004:** Match score is always 0-100 percentage
- **BR-005:** Minimum 3 improvement suggestions always provided

## Domain Glossary

| Term | Meaning in This Project |
|------|------------------------|
| Match Score | Percentage (0-100%) indicating resume-job alignment |
| Gap Analysis | List of skills/keywords in job desc but missing from resume |
| Improved Bullets | AI-rewritten resume bullet points with metrics/impact |
| Job Description | The full text of a job posting requirements section |

## What This Project is NOT

- **Not a resume builder** — we analyze, not create from scratch
- **Not a job board** — no job listings or applications
- **Not storing data** — everything processed client-side, nothing saved
- **Not ATS simulation** — we don't simulate Applicant Tracking Systems

## Current Limitations

- **PDF only**: No Word docs, images, or other formats
- **English only**: Analysis optimized for English language
- **Single resume**: Cannot compare multiple resumes at once
- **No save/history**: Results are not persisted between sessions
- **API dependency**: Requires active Gemini API key
```

---

## Tips for Better Results

### Tip 1: Be Specific About User Types
```
❌ "Users"
✅ "Job seekers actively applying to 10+ positions per week"
```

### Tip 2: Include Edge Cases in Business Rules
```
"What happens if PDF is corrupted?"
"What if job description is in a different language?"
"What's the minimum text length for analysis?"
```

### Tip 3: Use Few-Shot for Complex Sections
If AI doesn't format flows correctly, add more examples:
```
Here are 2 examples of how I want flows documented:

Example 1:
### Flow: Login
**Trigger:** User clicks login button
1. User enters credentials
2. System validates
3. Success → dashboard, Failure → error message
**Outcome:** User authenticated or shown error

Example 2:
### Flow: Password Reset
**Trigger:** User clicks "Forgot Password"
1. User enters email
2. System sends reset link
3. User clicks link, enters new password
**Outcome:** Password updated

Now document my flows using this exact format...
```

---

## Iteration Prompts

After initial generation, refine with:

```
"Add more detail to Flow 2 - include error scenarios"
```

```
"The Domain Glossary is missing 'ATS' - add it"
```

```
"Business rules should include rate limiting - add BR-006"
```

---

## When to Update This File

Update PROJECT_CONTEXT.md when:
- [ ] Adding new user types
- [ ] Changing core flows
- [ ] Adding new business rules
- [ ] Scope changes (moving something to "What This is NOT")
- [ ] New limitations discovered

---

## Related Files

- [README.md](./README.md) - Technical overview
- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Code conventions
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

---

*This template is part of the AI Workshop materials. Feed this file to AI before asking business logic questions.*
