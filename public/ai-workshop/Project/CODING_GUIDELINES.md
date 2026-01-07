# Coding Guidelines Template

> **AI Prompting Techniques Used:** `Constraint-Based Prompting` + `Few-Shot Prompting`
>
> This template uses Constraint-Based Prompting to set explicit boundaries on AI output, and Few-Shot examples to show exact coding patterns you expect.

---

## What is Constraint-Based Prompting?

**Definition:** Setting explicit boundaries on what AI can and cannot do, include or exclude.

**Why it works:** Without constraints, AI gives generic, bloated answers. Constraints focus the response on exactly what you need.

**Structure:**
```
CONSTRAINTS:
- Do NOT use [X]
- Do NOT suggest [Y]
- Maximum [N] lines/items
- Must include [Z]
- Only use [specific technologies]
```

**Example:**
```
❌ Without constraints:
"Write a login function"
→ AI writes 200 lines with every possible feature

✅ With constraints:
"Write a login function.
CONSTRAINTS:
- Maximum 30 lines
- No external libraries except axios
- Must handle: success, invalid credentials, network error
- Do NOT include: remember me, social login, password reset"
→ AI writes focused, usable code
```

---

## How to Use This Template

### Step 1: Copy the Prompt Below
### Step 2: Fill in Your Project's Conventions
### Step 3: Save as CODING_GUIDELINES.md
### Step 4: Feed to AI Before Asking for Code

**Compatible Tools:**
- ChatGPT (Free)
- Google Gemini
- Continue.dev (VSCode)
- Codeium (VSCode)

---

## Prompt to Generate CODING_GUIDELINES.md

```markdown
## ROLE
You are a senior tech lead who writes clear, enforceable coding standards. You've seen codebases ruined by inconsistency and know exactly what rules prevent that.

## CONTEXT
I need a CODING_GUIDELINES.md file that AI tools can use to generate code matching our project's style. This file will be fed to AI before asking for any code.

**Tech Stack:** [YOUR_TECH_STACK]
**Language:** [PRIMARY_LANGUAGE]
**Framework:** [FRAMEWORK]
**State Management:** [STATE_SOLUTION]
**Styling:** [CSS_APPROACH]

## TASK
Generate a CODING_GUIDELINES.md with:
1. File & Folder naming conventions (with examples)
2. Variable & Function naming conventions (with examples)
3. Component structure pattern (with code example)
4. Patterns we USE (with code examples)
5. Patterns to AVOID (with bad → good examples)
6. Error handling pattern (with code example)
7. File structure convention

## FORMAT
Use this Few-Shot pattern for naming conventions:

**Example Format for Conventions:**
```
### Files & Folders
| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase + use | `useAuth.ts` |
```

**Example Format for Patterns:**
```typescript
// ✅ Good - What we do
const goodExample = () => { ... }

// ❌ Bad - What we avoid
const badExample = () => { ... }
```

## CONSTRAINTS
- Every rule must have a concrete example
- No vague rules like "write clean code"
- Include TypeScript-specific rules if using TS
- Maximum 150 lines total
- Focus on rules that AI tends to get wrong
```

---

## Example Output

When you use the above prompt with this context:

```
Tech Stack: React 19, TypeScript, Vite, Tailwind CSS
Language: TypeScript
Framework: React
State Management: useState + useContext (no Redux)
Styling: Tailwind CSS
```

**AI will generate:**

```markdown
# Coding Guidelines

## Naming Conventions

### Files & Folders
| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase + use prefix | `useAuth.ts` |
| Utilities | camelCase | `formatDate.ts` |
| Constants | SCREAMING_SNAKE_CASE | `API_ENDPOINTS.ts` |
| Types/Interfaces | PascalCase | `UserTypes.ts` |
| Services | camelCase + Service | `apiService.ts` |

### Variables & Functions
```typescript
// Booleans: is, has, should, can prefix
const isLoading = true;
const hasPermission = false;
const shouldRefresh = true;

// Event handlers: handle prefix
const handleClick = () => {};
const handleSubmit = () => {};

// Data fetching: fetch, get, load prefix
const fetchUsers = async () => {};
const getUserById = async (id: string) => {};

// Transformers: format, parse, transform prefix
const formatCurrency = (amount: number) => {};
const parseApiResponse = (data: unknown) => {};
```

### Component Props
```typescript
// Interface above component, Props suffix
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  isEditable?: boolean;  // Optional props last
}

// Destructure in function signature with defaults
export const UserCard: React.FC<UserCardProps> = ({
  user,
  onEdit,
  isEditable = false
}) => {
  // ...
};
```

## Component Structure

```typescript
// 1. Imports (external first, then internal)
import { useState, useEffect } from 'react';
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks/useAuth';
import type { User } from '@/types';

// 2. Types/Interfaces
interface ProfileCardProps {
  user: User;
  onSave: (user: User) => void;
}

// 3. Constants (component-specific)
const MAX_BIO_LENGTH = 500;

// 4. Component
export const ProfileCard: React.FC<ProfileCardProps> = ({ user, onSave }) => {
  // 4a. Hooks first (useState, useEffect, custom hooks)
  const [isEditing, setIsEditing] = useState(false);
  const { currentUser } = useAuth();

  // 4b. Derived values
  const canEdit = currentUser?.id === user.id;

  // 4c. Event handlers
  const handleSave = () => {
    onSave(user);
    setIsEditing(false);
  };

  // 4d. Effects (use sparingly)
  useEffect(() => {
    // Side effect logic
  }, [dependency]);

  // 4e. Early returns for loading/error states
  if (!user) return <LoadingSkeleton />;

  // 4f. Main render
  return (
    <div className="p-4 rounded-lg bg-white shadow">
      {/* JSX */}
    </div>
  );
};
```

## Patterns We Use

### API Calls - Through Service Layer
```typescript
// ✅ Good - All API calls through services
const users = await userService.getAll();
const result = await analysisService.analyzeResume(resume, jobDesc);

// ❌ Bad - Direct fetch in component
const users = await fetch('/api/users').then(r => r.json());
```

### State Management
```typescript
// ✅ Good - Local state for UI
const [isOpen, setIsOpen] = useState(false);

// ✅ Good - Context for shared state
const { user } = useAuth();

// ❌ Bad - Prop drilling beyond 2 levels
<GrandParent user={user}>
  <Parent user={user}>
    <Child user={user}>  // Too deep - use Context
```

### Conditional Rendering
```typescript
// ✅ Good - Early return
if (isLoading) return <Spinner />;
if (error) return <ErrorMessage error={error} />;
return <Content data={data} />;

// ❌ Bad - Nested ternaries
return isLoading ? <Spinner /> : error ? <Error /> : <Content />;
```

### Error Handling
```typescript
// ✅ Good - Consistent pattern
try {
  const result = await someAsyncOperation();
  return result;
} catch (error) {
  // User-friendly message to UI
  toast.error(getErrorMessage(error));
  // Technical details to console
  console.error('[functionName]:', error);
  throw error; // Re-throw if caller needs to handle
}
```

## Patterns to AVOID

| Don't | Do Instead | Why |
|-------|------------|-----|
| `any` type | `unknown` or proper type | Type safety |
| Nested ternaries | Early returns or `if/else` | Readability |
| Magic numbers | Named constants | Maintainability |
| `console.log` | Remove or use logger | Clean production code |
| Commented-out code | Delete it | Git has history |
| Functions >50 lines | Extract smaller functions | Testability |
| Prop drilling >2 levels | Context or composition | Maintainability |

## File Structure

```
src/
├── components/
│   ├── common/          # Button, Input, Modal, Card
│   ├── features/        # Feature-specific: ResumeUpload, AnalysisResults
│   └── layout/          # Header, Footer, Sidebar
├── hooks/               # useAuth, useAnalysis, useFileUpload
├── services/            # apiService, geminiService, pdfService
├── types/               # All TypeScript interfaces/types
├── utils/               # formatters, validators, helpers
├── constants/           # API_URLS, ERROR_MESSAGES, CONFIG
└── App.tsx
```

## TypeScript Rules

```typescript
// ✅ Always type function parameters and returns
const formatScore = (score: number): string => {
  return `${score}%`;
};

// ✅ Use type inference where obvious
const count = 0; // number is inferred

// ✅ Prefer interfaces for objects, type for unions
interface User {
  id: string;
  name: string;
}

type Status = 'idle' | 'loading' | 'success' | 'error';

// ❌ Never use any
const processData = (data: any) => {}; // BAD
const processData = (data: unknown) => {}; // BETTER
const processData = (data: ApiResponse) => {}; // BEST
```
```

---

## Tips for Better AI Code Generation

### Tip 1: Feed Guidelines Before Every Code Request
```
"Here are my coding guidelines:
[Paste CODING_GUIDELINES.md]

Now write a [component/function] that..."
```

### Tip 2: Add Specific Constraints Per Request
```
"Following my coding guidelines above, write a UserCard component.

Additional constraints for this component:
- Must use Tailwind CSS only
- Include loading and error states
- Make it accessible (proper ARIA labels)"
```

### Tip 3: Correct AI When It Breaks Rules
```
"You used nested ternaries on line 15. Per our guidelines,
use early returns instead. Please fix."
```

---

## Quick Reference: What AI Gets Wrong

| AI Tends To | Our Rule |
|-------------|----------|
| Use `any` type | Use proper types or `unknown` |
| Write long functions | Keep under 50 lines |
| Nest ternaries | Use early returns |
| Skip error handling | Always try-catch async |
| Use inline styles | Use Tailwind classes |
| Create unnecessary abstractions | Keep it simple |

---

## Related Files

- [README.md](./README.md) - Project overview
- [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) - Business logic
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

---

*This template is part of the AI Workshop materials. Feed this file to AI before asking for any code.*
