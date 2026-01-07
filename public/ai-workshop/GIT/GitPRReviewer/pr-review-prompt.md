# AI Code Review for Pull Requests

> **AI Prompting Techniques Used:** `Role-Based Prompting` + `Constraint-Based Prompting` + `Few-Shot Prompting`
>
> This prompt uses a strict reviewer role, clear constraints on output format, and examples of good review comments.

---

## What is This?

An AI-powered code reviewer that:
1. Analyzes your code changes before PR submission
2. Catches bugs, security issues, and style problems
3. Provides actionable, prioritized feedback
4. Saves human reviewers' time on obvious issues

---

## How to Use

### Option 1: Manual Copy-Paste (Any AI Tool)

1. Get your changes: `git diff main...HEAD` (or your base branch)
2. Copy the prompt below
3. Paste into ChatGPT/Gemini/etc
4. Paste your diff where indicated
5. Review and fix issues before creating PR

### Option 2: Shell Script (Automated)

```bash
# Copy prompt to clipboard
./pr-review.sh

# Or with API (auto-generates review)
./pr-review.sh --api

# Review specific files only
./pr-review.sh --files "src/components/*.tsx"
```

---

## The Prompt

Copy everything between the lines:

---

```markdown
## ROLE
You are a senior code reviewer with 10+ years of experience. Your job is to be CRITICAL but CONSTRUCTIVE. You've seen production outages caused by missed bugs and you take reviewing seriously.

You are NOT here to praise the code. You are here to find problems.

## CONTEXT
I'm about to submit a Pull Request and want you to review my code changes first. Catch issues before my human teammates see them.

**Review Focus Areas:**
1. Bugs and logic errors
2. Security vulnerabilities (injection, XSS, auth issues)
3. Performance problems (N+1, memory leaks, unnecessary renders)
4. Code clarity and maintainability
5. Missing error handling
6. Missing edge cases
7. Potential breaking changes

## TASK
Review the code diff below. For each issue found:
1. Identify the severity (Critical/Warning/Suggestion)
2. Locate the exact line/section
3. Explain what's wrong
4. Suggest how to fix it

## FORMAT
Use this exact format for your review:

```
## Summary
[1-2 sentences: Overall assessment]

## Issues Found

### 🔴 CRITICAL: [Issue Title]
**Location:** `filename:line`
**Problem:** [What's wrong]
**Risk:** [What could happen]
**Fix:** [How to fix]
```code suggestion if applicable```

### 🟡 WARNING: [Issue Title]
**Location:** `filename:line`
**Problem:** [What's wrong]
**Suggestion:** [How to improve]

### 🟢 SUGGESTION: [Issue Title]
**Location:** `filename:line`
**Note:** [What could be better]

### 💡 QUESTION: [What needs clarification]
**Location:** `filename:line`
**Question:** [What you're unsure about]

## Checklist
- [ ] All critical issues addressed
- [ ] Security concerns reviewed
- [ ] Error handling verified
- [ ] Edge cases covered
```

## CONSTRAINTS
- Be critical — don't say "looks good" if there are issues
- Focus on WHAT could go wrong, not style preferences
- Security issues are ALWAYS critical
- If code is genuinely good, say so briefly and move on
- Don't nitpick formatting if there's a linter
- Max 10 issues — prioritize the most important
- If no issues: state that clearly (rare)

## EXAMPLES OF GOOD REVIEW COMMENTS

**Example 1 - Security (Critical):**
```
### 🔴 CRITICAL: SQL Injection Vulnerability
**Location:** `src/api/users.ts:45`
**Problem:** User input directly concatenated into SQL query
**Risk:** Attacker can execute arbitrary SQL, steal/delete data
**Fix:** Use parameterized queries
```typescript
// Bad
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// Good
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```
```

**Example 2 - Bug (Critical):**
```
### 🔴 CRITICAL: Race Condition in State Update
**Location:** `src/components/Form.tsx:23`
**Problem:** setCount called with stale state in async callback
**Risk:** Lost updates when user clicks rapidly
**Fix:** Use functional update form
```typescript
// Bad
setCount(count + 1);

// Good
setCount(prev => prev + 1);
```
```

**Example 3 - Performance (Warning):**
```
### 🟡 WARNING: Unnecessary Re-renders
**Location:** `src/hooks/useData.ts:15`
**Problem:** New object created on every render as dependency
**Suggestion:** Memoize the options object or use primitive dependencies
```typescript
// Bad
useEffect(() => {}, [{ page, limit }]); // New object every render

// Good
useEffect(() => {}, [page, limit]); // Primitives compared by value
```
```

## CODE TO REVIEW
[PASTE YOUR GIT DIFF HERE]

---

## Optional: Add Project Context

For better reviews, add your project context:

```
## PROJECT CONTEXT
[Paste relevant sections from your PROJECT_CONTEXT.md]

## CODING GUIDELINES
[Paste relevant sections from your CODING_GUIDELINES.md]

## CODE TO REVIEW
[Your diff]
```
```

---

## Example Usage

### Input (Git Diff):
```diff
diff --git a/src/api/users.ts b/src/api/users.ts
index 1234567..abcdefg 100644
--- a/src/api/users.ts
+++ b/src/api/users.ts
@@ -10,6 +10,15 @@ export async function getUser(req: Request, res: Response) {
+  const userId = req.params.id;
+  const query = `SELECT * FROM users WHERE id = '${userId}'`;
+  const user = await db.query(query);
+
+  if (user) {
+    res.json(user);
+  }
+}
```

### Output (AI Review):
```
## Summary
Critical security vulnerability found. This code should NOT be merged.

## Issues Found

### 🔴 CRITICAL: SQL Injection Vulnerability
**Location:** `src/api/users.ts:12`
**Problem:** User-controlled `userId` directly interpolated into SQL string
**Risk:** Attacker can inject `'; DROP TABLE users; --` and destroy database
**Fix:** Use parameterized queries
```typescript
// Current (VULNERABLE)
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// Fixed (SAFE)
const query = 'SELECT * FROM users WHERE id = $1';
const user = await db.query(query, [userId]);
```

### 🔴 CRITICAL: Missing Input Validation
**Location:** `src/api/users.ts:11`
**Problem:** `userId` not validated before use
**Risk:** Invalid IDs could cause errors or unexpected behavior
**Fix:** Validate and sanitize input
```typescript
const userId = req.params.id;
if (!userId || typeof userId !== 'string') {
  return res.status(400).json({ error: 'Invalid user ID' });
}
```

### 🟡 WARNING: Missing Error Response
**Location:** `src/api/users.ts:14-16`
**Problem:** No response sent when user not found
**Suggestion:** Add 404 response for missing users
```typescript
if (user) {
  res.json(user);
} else {
  res.status(404).json({ error: 'User not found' });
}
```

### 🟡 WARNING: Missing Error Handling
**Location:** `src/api/users.ts:13`
**Problem:** Database query not wrapped in try-catch
**Suggestion:** Add error handling for database failures
```typescript
try {
  const user = await db.query(query, [userId]);
  // ...
} catch (error) {
  console.error('Database error:', error);
  res.status(500).json({ error: 'Internal server error' });
}
```

## Checklist
- [ ] Fix SQL injection (CRITICAL)
- [ ] Add input validation (CRITICAL)
- [ ] Add 404 response
- [ ] Add try-catch error handling
```

---

## Review Checklist by Category

Use this to guide your own review after AI:

### Security
- [ ] No SQL/NoSQL injection
- [ ] No XSS vulnerabilities
- [ ] Auth checks on protected routes
- [ ] Sensitive data not exposed
- [ ] Input validation present

### Logic
- [ ] Edge cases handled
- [ ] Null/undefined checks
- [ ] Correct comparison operators
- [ ] No off-by-one errors

### Performance
- [ ] No unnecessary loops
- [ ] No memory leaks
- [ ] Proper caching
- [ ] No N+1 queries

### React Specific
- [ ] Correct useEffect dependencies
- [ ] Keys on list items
- [ ] No unnecessary re-renders
- [ ] Proper state updates

---

## Compatible AI Tools

| Tool | How to Use |
|------|------------|
| ChatGPT (Free) | Paste prompt + diff directly |
| Google Gemini | Paste prompt + diff directly |
| Continue.dev | Select code, run prompt in chat |
| Codeium | Use chat panel with prompt |
| Cursor | Select code, CMD+K, paste prompt |

---

## Related Files

- [pr-review.sh](./pr-review.sh) - Automated shell script
- [GitCommit](../GitCommit/) - Commit message generator
- [GitArchitectureReviewer](../GitArchitectureReviewer/) - Architecture review

---

*This template is part of the AI Workshop materials. Use it to catch issues before human code review.*
