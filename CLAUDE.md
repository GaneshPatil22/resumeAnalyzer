# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Resume Analyzer** - Analyze resume against job description, provide match score and actionable improvement suggestions.

### Inputs
- PDF resume (max 5MB)
- Job description (text paste)

### Outputs
- **Match Score**: Percentage (0-100%)
- **Gap Analysis**: Missing skills/keywords/experience
- **Suggestions**: Editable bullet points with figures (copy-paste ready)

### Not Included
- Authentication, data persistence, export, multiple files

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 19 + TypeScript + Vite 7 + SWC |
| Styling | Tailwind CSS |
| PDF Parsing | pdf.js (client-side) |
| AI/LLM | Google Gemini API (free tier) |
| Backend | Vercel Serverless Functions |

## Commands

- `npm run dev` - Start Vite dev server with HMR
- `npm run build` - TypeScript compile + Vite build
- `npm run lint` - Run ESLint
- `npm run preview` - Preview production build

## Project Structure (Planned)

```
src/
├── constants/
│   └── index.ts          # All constants (messages, limits, config)
├── types/
│   └── index.ts          # TypeScript interfaces/types
├── components/           # Reusable UI components
├── services/             # API calls, external integrations
├── utils/                # Helper/utility functions
├── hooks/                # Custom React hooks (if needed)
├── App.tsx
└── main.tsx
api/
└── analyze.ts            # Vercel serverless function
```

## Coding Standards

### Core Principles
- **Simplicity** - Keep it simple, don't over-engineer
- **DRY** - Don't Repeat Yourself, reuse code
- **Modular** - Small, focused components with single responsibility
- **No Hardcoding** - All values in constants file

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `FileUpload.tsx` |
| Functions | camelCase | `parseResume()` |
| Constants | UPPER_SNAKE_CASE | `MAX_FILE_SIZE` |
| Types/Interfaces | PascalCase | `AnalysisResult` |
| Files (non-component) | camelCase | `pdfParser.ts` |

### Code Practices
- Early returns over deep nesting
- Descriptive names over comments
- Small functions - each does one thing
- Props destructuring for cleaner signatures
- Consistent error handling with user feedback

### What to Avoid
- Over-abstraction for one-time use
- Premature optimization
- Magic numbers/strings (use constants)
- Large components (split if >150 lines)
- Unnecessary state
- `any` type in TypeScript
