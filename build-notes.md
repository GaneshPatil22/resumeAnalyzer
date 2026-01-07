# PERSONAL BUILD NOTES
## AI Workshop — Setup & Configuration Guide

---

# PART 1: N8N LOCAL SETUP

## Installation Options

### Option A: Docker (Recommended)
```bash
# Pull and run N8N
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Access at: http://localhost:5678
```

### Option B: NPM Global Install
```bash
# Install globally
npm install n8n -g

# Start N8N
n8n start

# Access at: http://localhost:5678
```

### Option C: Docker Compose (For Persistence)

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_password_here
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/
    volumes:
      - n8n_data:/home/node/.n8n
      
volumes:
  n8n_data:
```

Run:
```bash
docker-compose up -d
```

## Post-Installation

1. Open `http://localhost:5678`
2. Create owner account (email + password)
3. Skip the tour
4. You're ready to build workflows

---

# PART 2: N8N WORKFLOW CONFIGURATIONS

## Workflow 1: Job Finder Automation

### Complete Node Configuration:

**Node 1: Schedule Trigger**
```json
{
  "rule": {
    "interval": [{"field": "hours", "triggerAtHour": 8}]
  }
}
```
Settings: Runs daily at 8 AM

**Node 2: HTTP Request — RemoteOK API**
```json
{
  "method": "GET",
  "url": "https://remoteok.com/api",
  "options": {
    "response": {
      "response": {
        "fullResponse": false
      }
    }
  }
}
```

**Node 3: IF — Filter Jobs**
```json
{
  "conditions": {
    "string": [
      {
        "value1": "={{ $json.position.toLowerCase() }}",
        "operation": "contains",
        "value2": "react"
      }
    ]
  },
  "combineOperation": "any"
}
```

**Node 4: Set — Format Job Data**
```json
{
  "values": {
    "string": [
      {
        "name": "title",
        "value": "={{ $json.position }}"
      },
      {
        "name": "company", 
        "value": "={{ $json.company }}"
      },
      {
        "name": "url",
        "value": "={{ $json.url }}"
      },
      {
        "name": "salary",
        "value": "={{ $json.salary || 'Not specified' }}"
      }
    ]
  }
}
```

**Node 5: Gmail — Send Digest**
```json
{
  "resource": "message",
  "operation": "send",
  "toList": ["your-email@gmail.com"],
  "subject": "Daily Job Digest - {{ $now.format('MMMM D, YYYY') }}",
  "emailType": "html",
  "message": "<h2>Today's Job Matches</h2><ul>{{#each $input.all()}}<li><strong>{{this.json.title}}</strong> at {{this.json.company}}<br/>{{this.json.salary}}<br/><a href='{{this.json.url}}'>Apply</a></li>{{/each}}</ul>"
}
```

### Gmail Credentials Setup:
1. Go to Google Cloud Console
2. Create new project
3. Enable Gmail API
4. Create OAuth 2.0 credentials
5. In N8N: Add new credential → Google OAuth2
6. Paste Client ID and Client Secret
7. Authorize

---

## Workflow 2: Tech News Collector

**Node 1: Schedule Trigger**
```json
{
  "rule": {
    "interval": [{"field": "hours", "triggerAtHour": 7}]
  }
}
```

**Node 2a: RSS Feed — Hacker News**
```json
{
  "url": "https://hnrss.org/frontpage"
}
```

**Node 2b: RSS Feed — Dev.to**
```json
{
  "url": "https://dev.to/feed"
}
```

**Node 2c: RSS Feed — TechCrunch**
```json
{
  "url": "https://techcrunch.com/feed/"
}
```

**Node 3: Merge**
```json
{
  "mode": "append"
}
```
Connect all RSS nodes to this.

**Node 4: Limit**
```json
{
  "maxItems": 20
}
```

**Node 5: OpenAI — Summarize**
```json
{
  "resource": "chat",
  "operation": "message",
  "model": "gpt-3.5-turbo",
  "messages": {
    "values": [
      {
        "content": "You are a tech news curator. Given these headlines and snippets, create a brief morning digest. Highlight the top 5 most important stories with 1-sentence summaries each.\n\nHeadlines:\n{{#each $input.all()}}{{this.json.title}}: {{this.json.contentSnippet}}\n{{/each}}",
        "role": "user"
      }
    ]
  }
}
```

### OpenAI Credentials:
1. Get API key from platform.openai.com
2. In N8N: Credentials → New → OpenAI
3. Paste API key

**Node 6: Gmail — Send**
```json
{
  "toList": ["your-email@gmail.com"],
  "subject": "🌅 Tech Morning Digest - {{ $now.format('MMM D') }}",
  "emailType": "text",
  "message": "={{ $json.message.content }}"
}
```

---

## Workflow 3: GitHub Activity Digest

**Node 1: Schedule Trigger**
```json
{
  "rule": {
    "interval": [{"field": "weeks", "triggerAtDay": 1, "triggerAtHour": 9}]
  }
}
```
Runs every Monday at 9 AM.

**Node 2: GitHub — Get Commits**
```json
{
  "resource": "repository",
  "operation": "getCommits",
  "owner": "your-username",
  "repository": "your-repo",
  "additionalFields": {
    "since": "={{ $now.minus({days: 7}).toISO() }}"
  }
}
```

**Node 3: GitHub — Get Pull Requests**
```json
{
  "resource": "pullRequest",
  "operation": "getAll",
  "owner": "your-username", 
  "repository": "your-repo",
  "filters": {
    "state": "closed"
  },
  "additionalFields": {
    "since": "={{ $now.minus({days: 7}).toISO() }}"
  }
}
```

**Node 4: Merge**
```json
{
  "mode": "mergeByIndex"
}
```

**Node 5: OpenAI — Generate Summary**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": {
    "values": [
      {
        "content": "Create a weekly development summary from this GitHub activity:\n\nCommits:\n{{#each $json.commits}}{{this.commit.message}}\n{{/each}}\n\nMerged PRs:\n{{#each $json.pullRequests}}{{this.title}}\n{{/each}}\n\nFormat as: Key Accomplishments, Areas of Focus, Metrics (commits count, PRs merged)",
        "role": "user"
      }
    ]
  }
}
```

**Node 6: Slack — Post Message**
```json
{
  "channel": "#dev-updates",
  "text": "*📊 Weekly Dev Digest*\n\n{{ $json.message.content }}"
}
```

### Slack Credentials:
1. Go to api.slack.com/apps
2. Create new app → From scratch
3. OAuth & Permissions → Add scopes: `chat:write`, `channels:read`
4. Install to workspace
5. Copy Bot User OAuth Token
6. In N8N: Credentials → New → Slack
7. Paste token

### GitHub Credentials:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes: `repo`, `read:user`
4. In N8N: Credentials → New → GitHub
5. Paste token

---

## Workflow 4: Meeting Notes Processor

**Node 1: Webhook**
```json
{
  "path": "meeting-notes",
  "httpMethod": "POST",
  "responseMode": "onReceived"
}
```
Trigger URL: `http://localhost:5678/webhook/meeting-notes`

**Node 2: OpenAI — Process Notes**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": {
    "values": [
      {
        "content": "Process these meeting notes and extract:\n1. **Key Decisions Made** (bullet list)\n2. **Action Items** (format: [Owner] - Task - Due Date)\n3. **Open Questions** (things needing follow-up)\n4. **Brief Summary** (3-4 sentences)\n\nRaw notes:\n{{ $json.body.notes }}",
        "role": "user"
      }
    ]
  }
}
```

**Node 3: Google Docs — Create Document**
```json
{
  "resource": "document",
  "operation": "create",
  "title": "Meeting Notes - {{ $json.body.meetingTitle }} - {{ $now.format('YYYY-MM-DD') }}",
  "content": "={{ $json.message.content }}"
}
```

**Node 4: Slack — Notify**
```json
{
  "channel": "#team-general",
  "text": "📝 Meeting notes ready: *{{ $json.body.meetingTitle }}*\n\nAction items have been extracted. Check Google Docs for details."
}
```

### Test the Webhook:
```bash
curl -X POST http://localhost:5678/webhook/meeting-notes \
  -H "Content-Type: application/json" \
  -d '{
    "meetingTitle": "Sprint Planning",
    "notes": "Discussed Q1 roadmap. John will handle auth refactor by Jan 15. Need to decide on database migration approach. Sarah mentioned performance issues with search."
  }'
```

---

## Workflow 5: Social Media Content Scheduler

**Node 1: Schedule Trigger**
```json
{
  "rule": {
    "interval": [{"field": "hours", "triggerAtHour": 10}]
  }
}
```

**Node 2: Google Sheets — Get Today's Posts**
```json
{
  "operation": "readRows",
  "documentId": "your-sheet-id",
  "sheetName": "Content",
  "options": {
    "filter": "={{ $json.date === $now.format('YYYY-MM-DD') }}"
  }
}
```

**Google Sheet Structure:**
| date | platform | content | media_url | posted |
|------|----------|---------|-----------|--------|
| 2024-01-15 | twitter | Check out our new feature! | | FALSE |

**Node 3: IF — Check if Twitter**
```json
{
  "conditions": {
    "string": [
      {
        "value1": "={{ $json.platform }}",
        "operation": "equals",
        "value2": "twitter"
      }
    ]
  }
}
```

**Node 4a: Twitter — Post Tweet**
```json
{
  "operation": "create",
  "text": "={{ $json.content }}"
}
```

**Node 4b: LinkedIn — Post**
(Requires LinkedIn API setup — more complex)

**Node 5: Google Sheets — Mark as Posted**
```json
{
  "operation": "updateRow",
  "documentId": "your-sheet-id", 
  "sheetName": "Content",
  "rowNumber": "={{ $json.rowNumber }}",
  "values": {
    "posted": "TRUE"
  }
}
```

---

# PART 3: ALL MD FILE TEMPLATES

## Template 1: README.md
```markdown
# [Project Name]

[One-line description]

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Frontend | |
| Backend | |
| Database | |
| Testing | |
| CI/CD | |

## 🚀 Quick Start

### Prerequisites
- Node.js v18+
- npm or yarn
- [Any other requirements]

### Installation

```bash
# Clone repository
git clone [repo-url]
cd [project-name]

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your values

# Start development server
npm run dev
```

## 📜 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run test` | Run tests |
| `npm run lint` | Lint code |

## 🔐 Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `API_URL` | Backend API URL | Yes | - |
| `DEBUG` | Enable debug mode | No | false |

## 📁 Project Structure

```
src/
├── components/     # UI components
├── pages/          # Page components
├── hooks/          # Custom hooks
├── services/       # API services
├── utils/          # Utility functions
└── types/          # TypeScript types
```

## 🤝 Contributing

[Contributing guidelines or link]

## 📄 License

[License type]
```

---

## Template 2: PROJECT_CONTEXT.md
```markdown
# Project Context: [Project Name]

## 🎯 Problem Statement

[What problem does this solve? Who experiences this problem? Why is it important?]

## 👥 Target Users

### Primary Users
- **Role:** [e.g., Small business owners]
- **Goal:** [What they want to accomplish]
- **Pain Point:** [Current frustration]

### Secondary Users
- **Role:** [e.g., Accountants]
- **Goal:** [What they want to accomplish]

## 🔄 Core User Flows

### Flow 1: [Name, e.g., "User Registration"]
**Trigger:** [What starts this flow]
1. [Step 1]
2. [Step 2]
3. [Step 3]
**Outcome:** [End state]

### Flow 2: [Name]
**Trigger:** [What starts this flow]
1. [Step 1]
2. [Step 2]
**Outcome:** [End state]

## 📏 Business Rules

- **BR-001:** [Rule description, e.g., "Users must verify email before accessing dashboard"]
- **BR-002:** [Rule description]
- **BR-003:** [Rule description]

## 📖 Domain Glossary

| Term | Definition in This Project |
|------|---------------------------|
| [Term 1] | [What it means HERE] |
| [Term 2] | [What it means HERE] |

## ⛔ What This Project is NOT

- Not a [X] — we don't [do something]
- Not a [Y] — users should use [alternative] for that
- Not a [Z] — out of scope for v1

## 🚧 Current Limitations

- [Limitation 1 and why]
- [Limitation 2 and workaround if any]

## 🗺 Roadmap Context

**Current Version:** v[X.Y]
**Next Milestone:** [What's coming]
**Future Considerations:** [What might come later]
```

---

## Template 3: CODING_GUIDELINES.md
```markdown
# Coding Guidelines

## 📝 Naming Conventions

### Files & Folders
| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase + use | `useAuth.ts` |
| Utilities | camelCase | `formatDate.ts` |
| Constants | SCREAMING_SNAKE | `API_ENDPOINTS.ts` |
| Types/Interfaces | PascalCase | `UserTypes.ts` |

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
```

### Component Props
```typescript
// Interface above component, Props suffix
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  isEditable?: boolean;  // Optional props last
}

export const UserCard: React.FC<UserCardProps> = ({ 
  user, 
  onEdit, 
  isEditable = false  // Defaults in destructuring
}) => {
  // ...
};
```

## ✅ Patterns We Use

### State Management
- **Local UI state:** `useState`
- **Complex local state:** `useReducer`
- **Shared client state:** [Zustand/Redux/Context]
- **Server state:** [React Query/SWR]

### API Calls
```typescript
// ✅ All API calls through service layer
const users = await userService.getAll();

// ❌ Never call fetch directly in components
const users = await fetch('/api/users');
```

### Error Handling
```typescript
// Standard try-catch pattern
try {
  const result = await someAsyncOperation();
  return result;
} catch (error) {
  // User-friendly message to UI
  toast.error(getErrorMessage(error));
  // Technical details to console/logging
  console.error('[someAsyncOperation]:', error);
  throw error; // Re-throw if caller needs to handle
}
```

### Component Structure
```typescript
// 1. Imports (external, then internal)
// 2. Types/Interfaces
// 3. Constants
// 4. Component
// 5. Styles (if CSS-in-JS)

import { useState } from 'react';
import { Button } from '@/components/ui';

interface Props { /* ... */ }

const INITIAL_STATE = {};

export const MyComponent: React.FC<Props> = (props) => {
  // Hooks first
  const [state, setState] = useState(INITIAL_STATE);
  
  // Derived values
  const derivedValue = computeSomething(state);
  
  // Handlers
  const handleClick = () => {};
  
  // Effects (sparingly)
  
  // Render
  return <div>{/* ... */}</div>;
};
```

## ❌ Patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| `any` type | `unknown` or proper type |
| Nested ternaries | Early returns or switch |
| Magic numbers | Named constants |
| `console.log` in prod | Proper logging service |
| Commented code | Delete it (git has history) |
| 50+ line functions | Extract smaller functions |
| Prop drilling >2 levels | Context or state management |

## 📁 File Structure

```
src/
├── components/
│   ├── common/          # Button, Input, Modal
│   ├── features/        # UserCard, ProductList
│   └── layout/          # Header, Sidebar, Footer
├── hooks/               # useAuth, useDebounce
├── services/            # userService, apiClient
├── stores/              # authStore, uiStore
├── types/               # user.types.ts
├── utils/               # formatters, validators
├── constants/           # API_URLS, ROUTES
└── pages/               # Route-level components
```

## 🧪 Testing Standards

- Test file location: Same folder as source
- Naming: `[Component].test.tsx`
- Description format: `should [action] when [condition]`
- Minimum coverage: Happy path + 1 error case

```typescript
describe('UserCard', () => {
  it('should render user name when user prop is provided', () => {});
  it('should call onEdit when edit button is clicked', () => {});
  it('should show fallback when user is null', () => {});
});
```
```

---

## Template 4: ARCHITECTURE.md
```markdown
# Architecture Overview

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              React Application                       │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐       │   │
│  │  │   Pages   │  │Components │  │  Stores   │       │   │
│  │  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘       │   │
│  │        └──────────────┴──────────────┘              │   │
│  │                       │                              │   │
│  │               ┌───────┴───────┐                     │   │
│  │               │   Services    │                     │   │
│  │               └───────┬───────┘                     │   │
│  └───────────────────────┼─────────────────────────────┘   │
└──────────────────────────┼──────────────────────────────────┘
                           │ HTTP/REST
┌──────────────────────────┼──────────────────────────────────┐
│                          ▼                                   │
│                       SERVER                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              API Layer (Express/Fastify)             │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐       │   │
│  │  │  Routes   │→ │Controllers│→ │ Services  │       │   │
│  │  └───────────┘  └───────────┘  └─────┬─────┘       │   │
│  │                                       │              │   │
│  │                               ┌───────┴───────┐     │   │
│  │                               │  Repository   │     │   │
│  │                               └───────┬───────┘     │   │
│  └───────────────────────────────────────┼─────────────┘   │
│                                          │                  │
│                                   ┌──────┴──────┐          │
│                                   │  Database   │          │
│                                   │ (PostgreSQL)│          │
│                                   └─────────────┘          │
└──────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

### Read Operations
```
User Action → Component → Hook → Service → API → Database
     ↑                                              │
     └──────────── Response ◄───────────────────────┘
```

1. User triggers action (click, page load)
2. Component calls custom hook
3. Hook calls service method
4. Service makes HTTP request
5. API processes request
6. Database returns data
7. Data flows back up, updating state
8. Component re-renders

### Write Operations
```
User Input → Validation → Service → API → Database
     │                                      │
     └───────── Optimistic UI ◄─────────────┘
                    OR
            ◄── Error Handling ◄────────────┘
```

## 🔐 Authentication Flow

```
┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐
│ Login  │────▶│  API   │────▶│ Verify │────▶│ Issue  │
│  Form  │     │ Request│     │ Creds  │     │ Tokens │
└────────┘     └────────┘     └────────┘     └───┬────┘
                                                  │
┌────────┐     ┌────────┐     ┌────────────────────┘
│  Use   │◀────│ Store  │◀────│ Access Token (memory)
│  App   │     │ Tokens │     │ Refresh Token (httpOnly cookie)
└────────┘     └────────┘     
```

**Token Refresh:**
- Access token expires: 15 minutes
- Refresh token expires: 7 days
- Auto-refresh on 401 via axios interceptor

## 📦 Module Dependencies

```
Allowed Import Directions:

Pages ──────────┬──────────▶ Components
                │
                ├──────────▶ Hooks
                │
                └──────────▶ Constants

Components ─────┬──────────▶ Hooks
                │
                ├──────────▶ Utils
                │
                └──────────▶ Types

Hooks ──────────┬──────────▶ Services
                │
                ├──────────▶ Stores
                │
                └──────────▶ Types

Services ───────┬──────────▶ API Client
                │
                └──────────▶ Types

⛔ Circular dependencies are NOT allowed
⛔ Lower layers cannot import from higher layers
```

## 🔧 Key Technical Decisions

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| State Management | Redux, Zustand, Jotai | Zustand | Simpler API, less boilerplate |
| Styling | CSS Modules, Styled-Components, Tailwind | Tailwind | Rapid development, consistency |
| API Style | REST, GraphQL | REST | Team familiarity, simpler caching |
| Build Tool | CRA, Vite, Next.js | Vite | Fast HMR, simpler config |

## 🌍 Environment Configuration

| Environment | URL | Database | Features |
|-------------|-----|----------|----------|
| Development | localhost:3000 | Local Postgres | Debug tools, seed data |
| Staging | staging.app.com | Staging DB | Production-like, logging |
| Production | app.com | Prod DB | Error tracking, analytics |

## 🚨 Error Handling Strategy

```typescript
// API Errors → Caught by axios interceptor
// ├── 401 → Attempt token refresh
// ├── 403 → Redirect to unauthorized page
// ├── 404 → Show not found UI
// ├── 422 → Show validation errors
// └── 500 → Show generic error, log to Sentry

// Component Errors → Error boundaries
// └── Caught by nearest ErrorBoundary
//     └── Show fallback UI
//     └── Log to error service
```

## 📈 Performance Considerations

- **Code Splitting:** Route-based lazy loading
- **Caching:** React Query for server state
- **Memoization:** useMemo/useCallback for expensive operations
- **Bundle Size:** Track with bundlesize, max 250KB initial
```

---

# PART 4: PROMPT TEMPLATES BY USE CASE

## Code Generation Prompts

### New Component
```
ROLE: Senior React TypeScript developer

CONTEXT: 
- Project: [Project name/description]
- Tech stack: React 18, TypeScript, TailwindCSS
- State management: [Zustand/Redux/Context]
- Existing similar components: [Reference if any]

TASK: Create a [Component name] component that:
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

CONSTRAINTS:
- Follow our naming conventions (PascalCase for components)
- Use TypeScript with explicit prop types
- Include loading and error states
- Make it accessible (ARIA labels)

FORMAT:
- Full component code
- Props interface
- Brief usage example
```

### API Service
```
ROLE: Senior backend developer

CONTEXT:
- Framework: [Express/Fastify/NestJS]
- Database: [PostgreSQL/MongoDB]
- Auth: JWT Bearer tokens

TASK: Create a service for [Resource, e.g., "Users"] with:
- CRUD operations
- Input validation
- Error handling
- Proper TypeScript types

FORMAT:
- Service class/module
- DTOs for input/output
- Example usage in controller
```

### Database Query
```
ROLE: Database expert

CONTEXT:
- Database: [PostgreSQL/MySQL/MongoDB]
- Relevant tables/collections: [List them]
- Table schemas: [Brief description]

TASK: Write a query to [What you need]

CONSTRAINTS:
- Optimize for [read performance/write performance]
- [Any specific constraints]

FORMAT:
- The query with comments
- Explain the execution plan briefly
- Suggest index if needed
```

## Code Review Prompts

### Pre-PR Review
```
ROLE: Senior code reviewer — be critical but constructive

CONTEXT: This is a [feature/bugfix/refactor] for [brief description]

CODE TO REVIEW:
[Paste code]

REVIEW FOR:
1. Logic errors or bugs
2. Security vulnerabilities
3. Performance issues
4. Code clarity
5. Missing edge cases
6. Test coverage gaps

FORMAT:
🔴 Critical — must fix
🟡 Warning — should fix
🟢 Suggestion — nice to have
💡 Question — need clarification
```

### Architecture Review
```
ROLE: Senior software architect

CURRENT STATE:
[Describe current architecture or paste ARCHITECTURE.md]

PROPOSED CHANGE:
[Describe what you want to add/change]

EVALUATE:
1. Does this fit existing patterns?
2. Potential scaling issues?
3. Failure modes?
4. Migration complexity?
5. Simpler alternatives?

Be direct and critical.
```

## Documentation Prompts

### README Generation
```
ROLE: Technical writer

PROJECT INFO:
- Name: [Name]
- Purpose: [One sentence]
- Tech stack: [List]
- How to run: [Commands]

TASK: Generate a professional README with:
- Badges (build, license, version)
- Clear quick start section
- Environment variables table
- Available scripts
- Project structure overview

Keep it concise — no fluff.
```

### API Documentation
```
ROLE: API documentation specialist

ENDPOINT:
- Method: [GET/POST/etc]
- Path: [/api/users/:id]
- Purpose: [What it does]
- Controller code: [Paste code]

GENERATE:
- Description
- Request parameters (path, query, body)
- Response format (success and error)
- Example curl command
- Example response JSON

Format as OpenAPI/Swagger YAML.
```

## Debugging Prompts

### Bug Investigation
```
ROLE: Debugging expert with 20 years experience

BUG:
- Expected behavior: [What should happen]
- Actual behavior: [What's happening]
- Reproduction steps: [How to reproduce]

RELEVANT CODE:
[Paste code]

INVESTIGATE:
1. What are possible causes?
2. Walk through the code line by line
3. What would you add to debug this?
4. Most likely root cause?
5. Suggested fix
```

### Performance Issue
```
ROLE: Performance optimization specialist

PROBLEM:
[Describe the slow behavior]

CODE:
[Paste relevant code]

ENVIRONMENT:
- Data size: [rough numbers]
- Infrastructure: [relevant specs]

ANALYZE:
1. Identify bottlenecks
2. Big O analysis
3. Optimization suggestions
4. Trade-offs of each suggestion
```

---

# PART 5: GIT AUTOMATION SETUP

## Git Commit Message Generator

### Setup Script (Mac/Linux)
Create `~/scripts/ai-commit.sh`:
```bash
#!/bin/bash

# Check for staged changes
if [ -z "$(git diff --staged)" ]; then
  echo "No staged changes found. Stage some files first."
  exit 1
fi

# Get the diff
DIFF=$(git diff --staged)

# Create the prompt
PROMPT="Generate a git commit message for these changes. Follow conventional commits format (<type>(<scope>): <description>). Types: feat, fix, docs, style, refactor, test, chore. Be concise but descriptive.

Changes:
$DIFF"

# Copy to clipboard
echo "$PROMPT" | pbcopy

echo "Prompt copied to clipboard! Paste into ChatGPT."
echo ""
echo "Or use this command to commit after getting the message:"
echo "git commit -m \"<paste message here>\""
```

Make executable:
```bash
chmod +x ~/scripts/ai-commit.sh
```

### VS Code Task (Alternative)
Add to `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Commit Message",
      "type": "shell",
      "command": "git diff --staged | pbcopy && echo 'Diff copied to clipboard'",
      "problemMatcher": []
    }
  ]
}
```

---

# PART 6: TROUBLESHOOTING

## N8N Issues

### "Cannot connect to webhook"
```bash
# Check if N8N is running
docker ps | grep n8n

# Check logs
docker logs n8n

# Restart
docker restart n8n
```

### "Credentials not working"
1. Delete and recreate credentials
2. Check OAuth scopes
3. Verify API key hasn't expired
4. Check if service requires re-authorization

### "Workflow not triggering"
1. Check if workflow is activated (toggle in top-right)
2. Verify schedule trigger time
3. Check timezone settings in N8N
4. Look at Executions tab for errors

## API Issues

### OpenAI "Rate limit exceeded"
- Wait 60 seconds
- Consider caching responses
- Use GPT-3.5 for less important calls

### Gemini API Errors
```javascript
// Check API key
console.log(process.env.GEMINI_API_KEY?.substring(0, 10));

// Verify endpoint
const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
```

### GitHub API "401 Unauthorized"
- Token expired → Generate new one
- Wrong scopes → Check required scopes
- Rate limited → Wait or use authenticated requests

## General Debugging

### Check What N8N Receives
Add a "Set" node that just passes through data:
```json
{
  "debug": "={{ JSON.stringify($json) }}"
}
```

### Test Webhook Manually
```bash
curl -X POST http://localhost:5678/webhook/your-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```
