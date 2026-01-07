# Generating a Task List from Requirements

> **AI Prompting Techniques Used:** `Chain of Thought (CoT)` + `Few-Shot Prompting` + `Constraint-Based Prompting`
>
> This prompt uses step-by-step thinking to break down requirements, few-shot examples to show the exact task format, and constraints to ensure tasks are actionable by junior developers.

---

## What is This?

A task list generator that:
1. Takes a PRD or feature description
2. Breaks it into high-level parent tasks
3. Expands each into actionable sub-tasks
4. Identifies files that need to be created/modified
5. Outputs a checkbox-based task list for tracking progress

---

## Why Use a Task List?

**For developers:**
- Clear roadmap of what to build
- Progress tracking with checkboxes
- No decision fatigue - just work through the list
- Easy handoff if someone else takes over

**For AI coding assistants:**
- Can check off tasks as they complete them
- Structured context for implementation
- Clear scope boundaries

---

## How to Use

### Step 1: Have a PRD or Feature Description
Either use the output from `create-prd.md` or a written feature description.

### Step 2: Use Phase 1 Prompt
AI generates high-level tasks.

### Step 3: Confirm and Use Phase 2
AI expands into detailed sub-tasks.

### Step 4: Use the Task List
Work through tasks, checking them off as you go.

---

## The Prompts

### Phase 1: Generate Parent Tasks

```markdown
## ROLE
You are a senior tech lead who excels at breaking down features into implementable tasks. You think about the logical order of operations and dependencies between tasks.

## CONTEXT
I have a feature to implement and need a task breakdown. First, generate the high-level parent tasks, then we'll expand each into sub-tasks.

## TASK
Based on the requirements below, generate 5-8 high-level parent tasks that cover the complete implementation. Think step-by-step:

1. What needs to be set up first? (environment, dependencies)
2. What are the core components/features?
3. What order minimizes rework?
4. What testing/validation is needed?

## FORMAT
Use this exact format:
```
## Parent Tasks

- [ ] 0.0 Create feature branch
- [ ] 1.0 [First major task]
- [ ] 2.0 [Second major task]
- [ ] 3.0 [Third major task]
...
```

## CONSTRAINTS
- Always start with "0.0 Create feature branch"
- Order tasks by dependencies (what must come first)
- Each task should be completable in 1-4 hours
- Don't include sub-tasks yet - just parent tasks
- Include testing as a separate task

## REQUIREMENTS TO BREAK DOWN
[PASTE YOUR PRD OR FEATURE DESCRIPTION HERE]

---

After you review the parent tasks, respond with "Go" and I'll generate the detailed sub-tasks.
```

---

### Phase 2: Expand Sub-Tasks

After you confirm the parent tasks look good:

```markdown
## TASK
Now expand each parent task into specific, actionable sub-tasks. Think step-by-step for each parent:

1. What files need to be created/modified?
2. What's the logical order within this task?
3. What could a junior developer pick up and do?

## FORMAT
Use this exact format:
```markdown
## Relevant Files

- `path/to/file.tsx` - Brief description
- `path/to/file.test.tsx` - Tests for above file
...

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout new branch: `git checkout -b feature/[name]`

- [ ] 1.0 [Parent Task Title]
  - [ ] 1.1 [Specific sub-task]
  - [ ] 1.2 [Specific sub-task]
  - [ ] 1.3 [Specific sub-task]

- [ ] 2.0 [Parent Task Title]
  - [ ] 2.1 [Specific sub-task]
  ...
```

## CONSTRAINTS
- Each sub-task should be completable in 15-60 minutes
- Sub-tasks should be specific enough that a junior developer can do them
- Include file paths where relevant
- Include test tasks within each feature task (not just at the end)
- Number format: X.Y where X is parent, Y is sub-task
```

---

## Complete Example

### Input (Feature Description):

```markdown
## Feature: Quick Save

Allow users to save analysis results to localStorage.
- Save button on results screen
- History list showing saved items
- Maximum 10 items, oldest auto-deleted
- Manual delete option

Key files involved:
- src/components/Results.tsx (add save button)
- src/components/History.tsx (new component)
- src/services/storageService.ts (new service)
```

### Output (Task List):

```markdown
# Task List: Quick Save Feature

## Relevant Files

- `src/services/storageService.ts` - localStorage wrapper service
- `src/services/storageService.test.ts` - Unit tests for storage service
- `src/components/History.tsx` - History list component
- `src/components/History.test.tsx` - Unit tests for History component
- `src/components/HistoryItem.tsx` - Individual history item component
- `src/components/Results.tsx` - Add save button (existing file)
- `src/types/index.ts` - Add SavedAnalysis type
- `src/constants/index.ts` - Add storage constants

### Notes

- Unit tests should be placed alongside the code files they test
- Use `npm test` to run all tests
- Use `npm test -- --watch` during development

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, check it off by changing `- [ ]` to `- [x]`. This tracks progress and ensures no steps are skipped.

Example:
- `- [ ] 1.1 Create file` → `- [x] 1.1 Create file` (after completing)

---

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout new branch: `git checkout -b feature/quick-save`

- [ ] 1.0 Set up types and constants
  - [ ] 1.1 Add `SavedAnalysis` interface to `src/types/index.ts`:
    ```typescript
    interface SavedAnalysis {
      id: string;
      name: string;
      score: number;
      gaps: string[];
      suggestions: string[];
      jobTitle: string;
      savedAt: string;
    }
    ```
  - [ ] 1.2 Add storage constants to `src/constants/index.ts`:
    ```typescript
    export const STORAGE_KEY = 'resume_analyzer_history';
    export const MAX_SAVED_ITEMS = 10;
    ```

- [ ] 2.0 Create storage service
  - [ ] 2.1 Create `src/services/storageService.ts` with:
    - `saveAnalysis(analysis: SavedAnalysis): void`
    - `getHistory(): SavedAnalysis[]`
    - `deleteAnalysis(id: string): void`
    - `clearHistory(): void`
  - [ ] 2.2 Implement localStorage read/write with JSON parsing
  - [ ] 2.3 Implement auto-delete of oldest when limit reached
  - [ ] 2.4 Add error handling for localStorage disabled/full
  - [ ] 2.5 Write unit tests in `storageService.test.ts`:
    - Test save/retrieve cycle
    - Test max items limit
    - Test delete functionality
    - Test localStorage disabled scenario

- [ ] 3.0 Create History components
  - [ ] 3.1 Create `src/components/HistoryItem.tsx`:
    - Display: name, score, date
    - Delete button
    - Click to view full results
  - [ ] 3.2 Create `src/components/History.tsx`:
    - Fetch history from storageService
    - Render list of HistoryItem components
    - Show "No saved analyses" when empty
    - Show count: "5/10 saved"
  - [ ] 3.3 Style components with Tailwind CSS
  - [ ] 3.4 Write tests for History component:
    - Renders empty state
    - Renders list of items
    - Delete button calls service

- [ ] 4.0 Add save functionality to Results
  - [ ] 4.1 Add "Save Analysis" button to Results.tsx
  - [ ] 4.2 Create save handler that:
    - Generates unique ID
    - Prompts for optional name
    - Calls storageService.saveAnalysis()
    - Shows success toast
  - [ ] 4.3 Add error handling for save failures
  - [ ] 4.4 Disable save button if already saved (optional)

- [ ] 5.0 Integrate History into app
  - [ ] 5.1 Add History component to main layout/navigation
  - [ ] 5.2 Add route or tab for History view (if using routing)
  - [ ] 5.3 Add click handler to load saved analysis into results view
  - [ ] 5.4 Test full flow: save → view history → load saved

- [ ] 6.0 Edge cases and polish
  - [ ] 6.1 Handle localStorage disabled:
    - Detect on app load
    - Show warning banner
    - Disable save button with tooltip
  - [ ] 6.2 Handle corrupted data:
    - Wrap JSON.parse in try-catch
    - Clear and restart if corrupted
  - [ ] 6.3 Add "Clear All History" option
  - [ ] 6.4 Add first-time tooltip/hint for save button

- [ ] 7.0 Final testing and cleanup
  - [ ] 7.1 Run full test suite: `npm test`
  - [ ] 7.2 Manual testing checklist:
    - [ ] Save works
    - [ ] History displays
    - [ ] Delete works
    - [ ] Max limit works
    - [ ] Load saved analysis works
    - [ ] Error states display correctly
  - [ ] 7.3 Remove any console.logs or debug code
  - [ ] 7.4 Update any relevant documentation

- [ ] 8.0 Create pull request
  - [ ] 8.1 Push branch: `git push -u origin feature/quick-save`
  - [ ] 8.2 Create PR with description of changes
  - [ ] 8.3 Run PR review using `pr-review.sh`
  - [ ] 8.4 Address any review feedback
```

---

## Task List Quality Checklist

### Structure
- [ ] Starts with branch creation (0.0)
- [ ] Ends with PR creation
- [ ] Tasks numbered consistently (X.Y format)
- [ ] Relevant files section complete

### Granularity
- [ ] Sub-tasks are 15-60 minutes each
- [ ] Junior developer can understand each task
- [ ] No ambiguous tasks like "implement feature"
- [ ] File paths specified where relevant

### Completeness
- [ ] Tests included for each feature task
- [ ] Error handling tasks included
- [ ] Edge cases covered
- [ ] Final testing task included

### Dependencies
- [ ] Tasks ordered by dependencies
- [ ] Types/interfaces created before use
- [ ] Services created before components that use them
- [ ] Integration tested last

---

## Tips for Better Task Lists

### Tip 1: Add Code Snippets to Tasks
```markdown
- [ ] 1.1 Add SavedAnalysis interface:
  ```typescript
  interface SavedAnalysis {
    id: string;
    // ...
  }
  ```
```

### Tip 2: Include Commands Where Helpful
```markdown
- [ ] 7.1 Run tests: `npm test -- --coverage`
- [ ] 8.1 Push branch: `git push -u origin feature/name`
```

### Tip 3: Break Down "Implement X" Tasks
```markdown
❌ Bad:
- [ ] 2.0 Implement storage service

✅ Good:
- [ ] 2.0 Create storage service
  - [ ] 2.1 Create file with function signatures
  - [ ] 2.2 Implement saveAnalysis
  - [ ] 2.3 Implement getHistory
  - [ ] 2.4 Implement deleteAnalysis
  - [ ] 2.5 Add error handling
  - [ ] 2.6 Write unit tests
```

### Tip 4: Constrain for Your Situation
```
Add to prompt:
"This is for a solo developer - keep total tasks under 30"
"Junior developer will implement - be very specific"
"We don't have tests set up - skip test tasks"
```

---

## Using with AI Coding Assistants

Many AI coding tools (Cursor, Continue.dev, Codeium, GitHub Copilot Chat) can use this task list to:

1. **Navigate implementation:** Share the task list in context
2. **Track progress:** AI can check off tasks as it completes them
3. **Maintain scope:** "Only implement task 2.3, nothing else"

**Example prompt for AI coding:**
```
Here's my task list:
[Paste task list]

Implement task 2.3 only. Don't modify any other files.
Mark the task as complete when done.
```

---

## Output

Save your task list as:
- **Filename:** `tasks-[feature-name].md`
- **Location:** `/tasks/`
- **Example:** `tasks-quick-save.md`

---

## Workflow Integration

```
Feature Idea
    ↓
[create-prd.md] Create PRD → prd-feature.md
    ↓
[This File] Create Task List → tasks-feature.md
    ↓
Implementation (check off tasks)
    ↓
[GitPRReviewer] Code Review
    ↓
Merge & Close
```

---

## Related Files

- [create-prd.md](./create-prd.md) - Generate PRD before tasks
- [GitCommit](../GIT/GitCommit/) - Generate commit messages for completed tasks
- [GitPRReviewer](../GIT/GitPRReviewer/) - Review code before PR

---

## Compatible AI Tools

| Tool | Best Use |
|------|----------|
| ChatGPT (Free) | Task list generation |
| Google Gemini | Longer PRDs/task lists |
| Continue.dev | Implementation with task context |
| Codeium | Quick task implementation |
| Cursor | Full workflow with task tracking |

---

*This template is part of the AI Workshop materials. Use it to break down features into actionable, trackable tasks.*
