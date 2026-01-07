# Generating a Product Requirements Document (PRD)

> **AI Prompting Techniques Used:** `R-C-T-F Framework` + `Iterative Refinement` + `Constraint-Based Prompting`
>
> This prompt uses R-C-T-F for structure, iterative refinement through clarifying questions, and constraints to keep the PRD focused and actionable.

---

## What is a PRD?

A Product Requirements Document (PRD) describes WHAT a feature should do and WHY, without specifying HOW to build it. It's the bridge between business needs and technical implementation.

**PRD answers:**
- What problem are we solving?
- Who is the user?
- What should the feature do?
- What does success look like?

**PRD does NOT answer:**
- Which technology to use
- How to structure the code
- Database schema design

---

## What is Iterative Refinement?

**Definition:** Building on AI's response with follow-up prompts to improve and refine the output.

**Why it works:** Complex documents rarely come out perfect on the first try. Iteration allows you to:
1. Get a rough draft quickly
2. Refine specific sections
3. Add missing details
4. Adjust tone and depth

**Structure:**
```
Initial Prompt → AI Response
    ↓
Refinement 1: "Add more detail to [section]"
    ↓
Refinement 2: "The user stories need [X]"
    ↓
Final Document
```

---

## How to Use

### Step 1: Start with a Feature Idea
Have a rough idea of what you want to build.

### Step 2: Use the Initial Prompt
AI will ask clarifying questions.

### Step 3: Answer Questions
AI generates the PRD.

### Step 4: Refine
Iterate until the PRD is complete.

---

## The Prompts

### Phase 1: Initial Prompt (AI Asks Questions)

```markdown
## ROLE
You are a senior product manager who excels at writing clear, actionable PRDs. You ask smart clarifying questions before writing to ensure the document is useful for developers.

## CONTEXT
I have a feature idea and need help creating a PRD. Before writing the full document, I need you to ask clarifying questions to understand the requirements.

## TASK
Based on my feature description below, ask 3-5 clarifying questions that will help you write a complete PRD. Focus on:
- Who is the user?
- What's the core problem?
- What are the key constraints?
- How will we measure success?

## FORMAT FOR QUESTIONS
Number each question and provide multiple-choice options (A, B, C, D) plus an "Other" option. This makes it easy for me to respond quickly.

Example format:
```
1. Who is the primary user for this feature?
   A. New users during onboarding
   B. Existing power users
   C. Admin/internal users
   D. All users equally
   E. Other (please specify)
```

## MY FEATURE IDEA
[DESCRIBE YOUR FEATURE IDEA HERE]
```

---

### Phase 2: Generate PRD (After Answering Questions)

After you answer the questions, AI uses this structure:

```markdown
## TASK
Based on my answers, generate a complete PRD with these sections:

1. **Overview** - What is this feature and why does it matter?
2. **Goals** - What are we trying to achieve? (measurable)
3. **User Stories** - As a [user], I want [goal] so that [benefit]
4. **Functional Requirements** - Numbered list of what the feature must do
5. **Non-Goals** - What this feature will NOT do (scope boundaries)
6. **Success Metrics** - How we'll measure if this worked
7. **Open Questions** - Things still to be decided

## CONSTRAINTS
- Write for a junior developer audience
- Be specific and unambiguous
- Each requirement should be testable
- Keep it under 2 pages
- No technical implementation details
```

---

## Complete Example

### Step 1: Initial Feature Idea

**User Input:**
```
I want to add a "Quick Save" feature to our resume analyzer.
Users should be able to save their analysis results for later.
```

### Step 2: AI Asks Questions

**AI Response:**
```
Great feature idea! Before I write the PRD, I need to clarify a few things:

1. Where should the saved results be stored?
   A. Browser localStorage (single device, clears if browser data cleared)
   B. User account in database (requires login)
   C. Downloadable file (user manages storage)
   D. Other (please specify)

2. What should be saved?
   A. Full analysis results (score, gaps, suggestions)
   B. Just the score and job title
   C. Analysis results + original resume text
   D. User can choose what to save

3. How many analyses can a user save?
   A. Unlimited
   B. Last 10 only
   C. Configurable limit
   D. Other (please specify)

4. How important is cross-device access?
   A. Critical - users expect to access from any device
   B. Nice to have - but okay if single device only
   C. Not important - users are fine with single device
   D. Other (please specify)

5. What happens when storage is full (if limited)?
   A. Oldest automatically deleted
   B. User prompted to delete
   C. User cannot save until they delete
   D. Other (please specify)

Please respond with your selections (e.g., "1A, 2A, 3B, 4B, 5A")
```

### Step 3: User Answers

**User Response:**
```
1A, 2A, 3B, 4C, 5A
```

### Step 4: AI Generates PRD

**AI Response:**
```markdown
# PRD: Quick Save Feature

## Overview

The Quick Save feature allows users to save their resume analysis results to their browser for later reference. This enables users to compare how their resume matches different job descriptions over time without re-running analyses.

**Why it matters:** Users currently lose their analysis when they close the browser. This feature addresses the #1 user request from feedback forms.

## Goals

1. Allow users to save analysis results with one click
2. Enable users to view and compare past analyses
3. Provide simple management of saved items
4. Zero server-side storage required (privacy-first approach)

## User Stories

**US-001:** As a job seeker, I want to save my analysis results so that I can reference them later without re-uploading my resume.

**US-002:** As a job seeker, I want to see a list of my saved analyses so that I can compare how my resume matches different jobs.

**US-003:** As a job seeker, I want to delete old analyses so that I can manage my saved items.

**US-004:** As a user, I want to understand the storage limitations so that I'm not surprised when old items are removed.

## Functional Requirements

### Saving
- **FR-001:** System shall provide a "Save" button on the results screen
- **FR-002:** System shall save: match score, gap analysis, improvement suggestions, job title, and timestamp
- **FR-003:** System shall allow user to add an optional name/label to saved analysis
- **FR-004:** System shall show confirmation when save is successful
- **FR-005:** System shall show error message if save fails (e.g., storage full)

### Viewing History
- **FR-006:** System shall display a "History" section accessible from main screen
- **FR-007:** System shall list saved analyses showing: name/label, score, date
- **FR-008:** System shall allow user to click on a saved item to view full results
- **FR-009:** System shall sort saved items by date (newest first)

### Storage Management
- **FR-010:** System shall store maximum 10 analyses
- **FR-011:** When limit reached, system shall automatically delete oldest item
- **FR-012:** System shall allow user to manually delete any saved item
- **FR-013:** System shall show current count (e.g., "5/10 saved")
- **FR-014:** System shall use browser localStorage for persistence

### Edge Cases
- **FR-015:** System shall handle localStorage being disabled gracefully
- **FR-016:** System shall handle corrupted localStorage data gracefully
- **FR-017:** System shall warn user that data is browser-specific (not synced)

## Non-Goals (Out of Scope)

- **No cloud sync** - Data stays in browser only
- **No user accounts** - No login required
- **No export feature** - Cannot export saved analyses (future consideration)
- **No sharing** - Cannot share saved analyses with others
- **No resume storage** - Only analysis results saved, not original resume

## Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Feature adoption | 40% of users save at least one analysis | localStorage analytics |
| Retention impact | 20% increase in return visits | Browser fingerprint tracking |
| User satisfaction | Positive feedback | In-app feedback prompt |

## Open Questions

1. Should we show a tutorial/tooltip on first use?
2. Should "Save" be automatic or require user action?
3. Do we need a "Clear All" option in addition to individual delete?
4. Should we support localStorage alternatives (IndexedDB) for more storage?

## Technical Notes

*For developer context (not requirements):*
- Consider using a localStorage wrapper library for cross-browser compatibility
- Consider versioning the data schema for future migrations
- Test behavior when localStorage is full/disabled
```

---

### Step 5: Iterate and Refine

**Refinement Prompts:**

```
"Add more detail to FR-006 through FR-009.
What should the history list UI show exactly?"
```

```
"The success metrics need baseline numbers.
What's the current return visit rate we're comparing against?"
```

```
"Add a section about error states and edge cases.
What does the user see if localStorage is disabled?"
```

---

## PRD Quality Checklist

Before considering your PRD complete:

### Completeness
- [ ] Problem statement is clear
- [ ] User stories cover all personas
- [ ] Requirements are numbered
- [ ] Non-goals explicitly stated
- [ ] Success metrics are measurable

### Clarity
- [ ] Junior developer can understand it
- [ ] No ambiguous language ("easy", "fast", "nice")
- [ ] Each requirement is testable
- [ ] No implementation details

### Scope
- [ ] Feature is appropriately sized
- [ ] Dependencies identified
- [ ] Timeline realistic (if included)
- [ ] MVP vs future features clear

---

## Tips for Better PRDs

### Tip 1: Start Small, Then Expand
```
❌ "Build a full user dashboard with analytics, settings, and history"
✅ "Add a history feature for saved analyses"
```

### Tip 2: Be Specific About Users
```
❌ "Users can save results"
✅ "Job seekers actively applying to positions can save results"
```

### Tip 3: Make Requirements Testable
```
❌ "System should be fast"
✅ "System shall display results within 3 seconds"
```

### Tip 4: Constrain the AI
```
Add to your prompt:
"Focus only on the MVP - no nice-to-haves"
"Keep requirements under 20 items"
"This is for a solo developer - keep scope realistic"
```

---

## Compatible AI Tools

| Tool | Tips |
|------|------|
| ChatGPT (Free) | Good at follow-ups, use "Continue" if cut off |
| Google Gemini | Handles longer context well |
| Continue.dev | Can reference project files for context |
| Codeium | Good for quick iterations |

---

## Output

Save your PRD as:
- **Filename:** `prd-[feature-name].md`
- **Location:** `/tasks/` or `/docs/`
- **Example:** `prd-quick-save.md`

---

## Related Files

- [generate-tasks.md](./generate-tasks.md) - Generate task list from PRD
- [PROJECT_CONTEXT.md](../Project/PROJECT_CONTEXT.md) - Add context to PRD prompts
- [GitArchitectureReviewer](../GIT/GitArchitectureReviewer/) - Review PRD architecture

---

## Workflow Integration

```
Feature Idea
    ↓
[This File] Create PRD → prd-feature.md
    ↓
[generate-tasks.md] Create Task List → tasks-feature.md
    ↓
Implementation
    ↓
[GitPRReviewer] Code Review
    ↓
Merge
```

---

*This template is part of the AI Workshop materials. Use it to create clear, actionable PRDs before writing code.*
