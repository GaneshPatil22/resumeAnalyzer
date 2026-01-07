# Git Commit Message Generator

> **AI Prompting Techniques Used:** `R-C-T-F Framework` + `Constraint-Based Prompting`
>
> This prompt uses R-C-T-F to structure the request clearly and constraints to ensure commit messages follow conventional commit standards.

---

## What is This?

An AI-powered git commit message generator that:
1. Analyzes your staged changes (`git diff --staged`)
2. Generates conventional commit messages
3. Suggests splitting commits if changes are unrelated

---

## How to Use

### Option 1: Manual Copy-Paste (Any AI Tool)

1. Stage your changes: `git add .`
2. Copy your diff: `git diff --staged | pbcopy` (Mac) or `git diff --staged | clip` (Windows)
3. Paste the prompt below into ChatGPT/Gemini/etc
4. Paste your diff where indicated
5. Copy the generated commit message
6. Run: `git commit -m "your message"`

### Option 2: Shell Script (Automated)

```bash
# Run the script (copies prompt to clipboard)
./git-commit.sh

# Or with Gemini API (generates message directly)
./git-commit.sh --api
```

---

## The Prompt

Copy everything between the lines:

---

```markdown
## ROLE
You are a senior developer who writes clear, professional git commit messages following the Conventional Commits specification.

## CONTEXT
I need a commit message for my staged changes. The commit message should:
- Follow Conventional Commits format
- Be clear about WHAT changed and WHY
- Help future developers understand the change at a glance

**Conventional Commits Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change, no feature/fix
- `test`: Adding/updating tests
- `chore`: Maintenance, dependencies

## TASK
Analyze the git diff below and:
1. Identify the type of change (feat/fix/refactor/etc)
2. Determine the scope (component/file/feature affected)
3. Write a clear, concise description
4. Add body if the change needs explanation
5. If changes are unrelated, suggest splitting into multiple commits

## FORMAT
Output only the commit message(s), ready to copy-paste.

**Good examples:**
```
feat(auth): add password reset functionality

- Add sendResetEmail service method
- Create email template with reset link
- Add rate limiting (3 requests/hour)
```

```
fix(upload): handle corrupted PDF files gracefully

Previously crashed on malformed PDFs. Now shows user-friendly error.

Closes #42
```

## CONSTRAINTS
- Subject line: max 72 characters
- Use imperative mood ("add" not "added")
- Lowercase description, no period at end
- If multiple unrelated changes, output separate commits
- Don't explain obvious changes

## GIT DIFF
[PASTE YOUR GIT DIFF HERE]
```

---

## Example Usage

### Input (Git Diff):
```diff
diff --git a/src/components/FileUpload.tsx b/src/components/FileUpload.tsx
index 1234567..abcdefg 100644
--- a/src/components/FileUpload.tsx
+++ b/src/components/FileUpload.tsx
@@ -15,6 +15,12 @@ export const FileUpload = ({ onFileSelect }) => {
+  const [isDragging, setIsDragging] = useState(false);
+
+  const handleDragOver = (e: DragEvent) => {
+    e.preventDefault();
+    setIsDragging(true);
+  };
+
+  const handleDrop = (e: DragEvent) => {
+    e.preventDefault();
+    setIsDragging(false);
+    const file = e.dataTransfer.files[0];
+    if (file?.type === 'application/pdf') {
+      onFileSelect(file);
+    }
+  };
```

### Output (AI Generated):
```
feat(upload): add drag-and-drop support for PDF files

- Add isDragging state for visual feedback
- Implement handleDragOver and handleDrop handlers
- Validate dropped file is PDF before accepting
```

---

## Tips for Better Results

### Tip 1: Stage Related Changes Together
```bash
# Bad - mixing unrelated changes
git add .

# Good - stage related files
git add src/components/FileUpload.tsx src/components/FileUpload.test.tsx
```

### Tip 2: Add Context If Needed
If the diff doesn't explain WHY, add it:
```
[After the diff]

ADDITIONAL CONTEXT:
This change was needed because users reported uploads failing on mobile Safari.
```

### Tip 3: Request Specific Format
```
[Add to prompt]
Also include "Closes #123" at the end (this fixes issue #123)
```

---

## Conventional Commits Quick Reference

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature for user | `feat(search): add filter by date range` |
| `fix` | Bug fix | `fix(auth): prevent session timeout on mobile` |
| `docs` | Documentation | `docs(readme): add API setup instructions` |
| `style` | Formatting only | `style(button): fix inconsistent spacing` |
| `refactor` | Code restructure | `refactor(api): extract validation logic` |
| `test` | Tests | `test(upload): add edge case for large files` |
| `chore` | Maintenance | `chore(deps): update react to v19` |

---

## Troubleshooting

### "No staged changes"
```bash
# Check what's staged
git status

# Stage specific files
git add path/to/file.ts

# Stage all changes
git add .
```

### "Diff too large"
For large diffs, summarize:
```
[Instead of full diff]

CHANGES SUMMARY:
- Modified 5 files in src/components/
- Added new UserProfile component
- Updated styling in Button and Card components
- Fixed type errors in utils/
```

---

## Compatible AI Tools

| Tool | How to Use |
|------|------------|
| ChatGPT (Free) | Paste prompt + diff directly |
| Google Gemini | Paste prompt + diff directly |
| Continue.dev | Select diff, run prompt in chat |
| Codeium | Use chat panel with prompt |
| Cursor | CMD+K, paste prompt |

---

## Related Files

- [git-commit.sh](./git-commit.sh) - Automated shell script
- [GitPRReviewer](../GitPRReviewer/) - PR review prompts
- [GitArchitectureReviewer](../GitArchitectureReviewer/) - Architecture review

---

*This template is part of the AI Workshop materials. Use it to generate consistent, professional commit messages.*
