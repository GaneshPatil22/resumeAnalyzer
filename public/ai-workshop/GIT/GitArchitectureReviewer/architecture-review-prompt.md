# AI Architecture Review

> **AI Prompting Techniques Used:** `Chain of Thought (CoT)` + `Role-Based Prompting` + `Iterative Refinement`
>
> This prompt uses step-by-step reasoning to analyze architectural decisions, a senior architect role for expert perspective, and supports follow-up questions for deeper analysis.

---

## What is This?

An AI-powered architecture reviewer that:
1. Analyzes proposed architectural changes
2. Identifies potential scaling issues
3. Considers failure modes and edge cases
4. Suggests simpler alternatives
5. Validates against existing patterns

---

## When to Use

Use Architecture Review when:
- Adding a new major feature
- Changing data flow patterns
- Adding external service integrations
- Refactoring significant portions of code
- Making technology decisions
- Planning system migrations

---

## How to Use

### Option 1: Manual Copy-Paste (Any AI Tool)

1. Copy the prompt below
2. Fill in your current architecture and proposed changes
3. Paste into ChatGPT/Gemini/etc
4. Review the analysis and follow up with questions

### Option 2: Shell Script (Automated)

```bash
# Interactive mode - prompts for input
./architecture-review.sh

# With architecture file
./architecture-review.sh --arch ./ARCHITECTURE.md

# Using API
./architecture-review.sh --api
```

---

## The Prompt

Copy everything between the lines:

---

```markdown
## ROLE
You are a senior software architect with 15+ years of experience in distributed systems, scalable applications, and system design. You've seen patterns succeed and fail. You're here to prevent bad architectural decisions before they become expensive mistakes.

Think like a skeptical architect in a design review meeting. Your job is to find holes in the plan.

## CONTEXT
I'm proposing an architectural change and want your critical analysis. Don't just validate my ideas — challenge them.

## CURRENT ARCHITECTURE
[Describe or paste your current ARCHITECTURE.md here]

## PROPOSED CHANGE
[Describe what you want to add or change]

**Why this change:**
[What problem are you solving?]

**Impact areas:**
[What parts of the system will be affected?]

## TASK
Analyze this architectural proposal step by step:

### Step 1: Pattern Fit Analysis
Think through whether this change fits existing patterns:
- Does it follow current data flow?
- Does it match existing module boundaries?
- Will it create new dependencies?

### Step 2: Scaling Analysis
Think through how this scales:
- What happens with 10x more users?
- What happens with 10x more data?
- Are there bottlenecks?

### Step 3: Failure Mode Analysis
Think through what can go wrong:
- What if the new component fails?
- What if dependencies are slow?
- What's the fallback?

### Step 4: Complexity Analysis
Think through the complexity:
- Does this add unnecessary abstraction?
- Is there a simpler approach?
- Will new developers understand this?

### Step 5: Migration Analysis
Think through the transition:
- How do we get from current to proposed state?
- Can this be done incrementally?
- What's the rollback plan?

## FORMAT
Provide your analysis in this format:

```
## Summary
[2-3 sentences: Overall assessment — approve, concerns, or reject]

## Pattern Fit
✅ [What fits well]
⚠️ [Concerns]
❌ [What doesn't fit]

## Scaling Concerns
[Numbered list of scaling issues]

## Failure Modes
[Table or list of failure scenarios and mitigations]

## Simpler Alternatives
[If any exist, describe them]

## Migration Path
[Recommended approach]

## Recommendation
🟢 APPROVE / 🟡 APPROVE WITH CHANGES / 🔴 RECONSIDER

[Final recommendation with reasoning]
```

## CONSTRAINTS
- Be critical — I want to know what could go wrong
- Think about edge cases
- Consider operational complexity, not just code
- If the proposal is good, say so briefly
- Always suggest at least one alternative approach
```

---

## Example Usage

### Input:

```markdown
## CURRENT ARCHITECTURE
Simple client-side React app.
- User uploads PDF → pdf.js extracts text
- User pastes job description
- Both sent to Gemini API
- Results displayed

No backend, no database, no user accounts.

## PROPOSED CHANGE
Add a "history" feature where users can see their past analyses.

**Why this change:**
Users asked for it. They want to compare how their resume matches different jobs.

**Impact areas:**
- Need to store analysis results
- Need to identify users (sessions or accounts)
- UI changes for history list
```

### Output (AI Analysis):

```
## Summary
This proposal fundamentally changes the application from stateless to stateful. While the feature request is valid, the implementation requires careful consideration of data storage, privacy, and complexity trade-offs.

## Pattern Fit

✅ **Fits well:**
- Natural extension of existing analyze flow
- UI patterns exist (add history sidebar/tab)

⚠️ **Concerns:**
- Currently 100% client-side; this requires persistence
- No existing user identity mechanism
- No existing backend infrastructure

❌ **Doesn't fit:**
- Current "no data stored" promise would be broken
- Privacy model changes significantly

## Scaling Concerns

1. **Storage scaling**: If popular, could accumulate large amounts of data. Need retention policy.

2. **User identification**: Sessions are temporary. Accounts add significant complexity.

3. **Query patterns**: "Show my last 10 analyses" is simple, but "search my history" is complex.

## Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|------------|
| Storage full | New saves fail | Implement limits (max 50 per user) |
| Data loss | User frustration | Clear expectation that this is convenience, not backup |
| Browser data cleared | History lost (if localStorage) | Consider server-side storage |
| Account system breach | Privacy issue | Don't store unless needed; minimize data |

## Simpler Alternatives

### Alternative 1: Client-Side Only (Recommended for v1)
- Store in localStorage
- No accounts needed
- Limited to single browser
- Privacy preserved
```javascript
// Simple implementation
localStorage.setItem('history', JSON.stringify([...history, newResult]));
```
**Trade-off:** Lost on browser clear, no cross-device sync

### Alternative 2: Export/Import
- User can "Save" analysis as JSON file
- User can "Import" past analyses
- Zero storage needed
**Trade-off:** Manual process, but user controls their data

### Alternative 3: Anonymous Sessions with Backend
- Generate random session ID
- Store on backend with session ID only
- No true "accounts"
- 7-day retention
**Trade-off:** Still needs backend, but simpler than full auth

## Migration Path

**If going with localStorage approach:**
1. Add localStorage service (2-3 hours)
2. Save analysis results on completion (1 hour)
3. Add history UI component (4-6 hours)
4. Add "clear history" option (1 hour)

**If going with backend approach:**
1. Set up database and API (1-2 days)
2. Implement session/auth system (2-3 days)
3. Add history endpoints (1 day)
4. Add history UI (1 day)
5. Privacy policy updates (required)

## Recommendation
🟡 APPROVE WITH CHANGES

**Recommended approach:** Start with **localStorage** (Alternative 1)

**Reasoning:**
- Preserves current simplicity
- No backend needed
- No privacy concerns
- Users get the core feature
- Can upgrade to server-side later if needed

**If localStorage isn't enough later:**
- Revisit with export/import first
- Full backend only if strong demand + willingness to handle privacy

**Do NOT do:**
- Don't build full account system for this single feature
- Don't promise data persistence you can't guarantee
```

---

## Follow-Up Prompts (Iterative Refinement)

After the initial analysis, dig deeper:

### Question 1: Deep dive on specific concern
```
You mentioned localStorage could be cleared.
Think step by step: What's the best way to warn users about this limitation
while still providing value?
```

### Question 2: Compare alternatives
```
Compare localStorage vs IndexedDB for this use case.
Think through:
1. Storage limits
2. API complexity
3. Browser support
4. Performance with 100+ saved analyses
```

### Question 3: Challenge the recommendation
```
Play devil's advocate: What if we DID go with a full backend solution?
Think through:
1. What would we gain?
2. What's the simplest backend architecture?
3. Is there a middle ground between localStorage and full accounts?
```

---

## Architecture Review Checklist

Use this to guide your own thinking:

### Pattern Questions
- [ ] Does this follow existing data flow?
- [ ] Does it create circular dependencies?
- [ ] Can new developers understand it?

### Scale Questions
- [ ] What's the growth assumption?
- [ ] Where are the bottlenecks?
- [ ] What are the resource limits?

### Failure Questions
- [ ] What happens if [X] is down?
- [ ] What's the degraded experience?
- [ ] Is there a circuit breaker?

### Security Questions
- [ ] What new attack surfaces?
- [ ] What data is exposed?
- [ ] Who can access what?

### Operations Questions
- [ ] How is this monitored?
- [ ] How is this deployed?
- [ ] How do we roll back?

---

## Compatible AI Tools

| Tool | How to Use |
|------|------------|
| ChatGPT (Free) | Paste prompt directly, good for follow-ups |
| Google Gemini | Paste prompt directly |
| Continue.dev | Use in chat panel |
| Codeium | Use chat panel with prompt |

---

## Related Files

- [architecture-review.sh](./architecture-review.sh) - Automated shell script
- [ARCHITECTURE.md](../../Project/ARCHITECTURE.md) - Architecture template
- [GitPRReviewer](../GitPRReviewer/) - Code-level review

---

*This template is part of the AI Workshop materials. Use it before making significant architectural decisions.*
