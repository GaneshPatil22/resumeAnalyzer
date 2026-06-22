# Resume Analyzer

A small web tool that compares a resume against a job description and returns gap analysis with suggested re-phrasings.

Built for personal use during a job hunt. Reads a candidate's resume plus a target JD, finds which JD requirements are covered, which are missing, and which are loosely related enough to stretch into.

## What it does

- Paste resume text + job description text
- Returns a structured analysis:
  - Skills covered (with strength signal)
  - Skills missing (with learnability hint)
  - Suggested resume bullet re-phrasings tied to the JD's keyword cluster

## Stack

- React + TypeScript + Vite
- xAI Grok API for the analysis pipeline
- Prompt-engineered structured JSON output, validated client-side

## Why it exists

Tailoring a resume per JD takes 30+ minutes when done well. This tool cuts that time roughly in half and surfaces things humans miss (specific keyword variants the JD uses, weak claims that need quantifying).

Dogfooded across an active job hunt.

## Run locally

```bash
cp .env.example .env  # add your xAI API key
npm install
npm run dev
```

## Status

Personal use. Not productized.
