export const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
export const ACCEPTED_FILE_TYPES = ['application/pdf'];

export const AI_PROVIDERS = {
  GROQ: 'groq',
} as const;

export const DEFAULT_AI_PROVIDER = AI_PROVIDERS.GROQ;

export const MESSAGES = {
  FILE_TOO_LARGE: 'File size exceeds 5MB limit',
  INVALID_FILE_TYPE: 'Please upload a PDF file',
  NO_RESUME: 'Please upload your resume',
  NO_JOB_DESCRIPTION: 'Please enter the job description',
  ANALYZING: 'Analyzing your resume...',
  ERROR_ANALYZING: 'Failed to analyze resume. Please try again.',
  API_KEY_MISSING: 'API key not configured. Please add it to your .env file.',
};

export const ANALYSIS_PROMPT = `You are an expert resume analyzer. Analyze the resume against the job description.

IMPORTANT RULES FOR BULLET POINTS:
- Keep bullets SHORT (max 15-20 words)
- Start with strong action verbs
- Include metrics/numbers where possible
- Make them copy-paste ready for a resume

Provide your analysis in this JSON structure:
{
  "matchScore": number (0-100),
  "summary": {
    "current": "Brief 1-2 sentence summary of current resume positioning",
    "improved": "Brief 1-2 sentence improved summary tailored to job"
  },
  "gaps": ["skill1", "skill2", "keyword3"],
  "sections": [
    {
      "name": "Experience",
      "improvements": [
        {
          "original": "Original bullet from resume (or null if new)",
          "improved": "Improved/rewritten bullet point",
          "isNew": false
        }
      ]
    },
    {
      "name": "Skills",
      "improvements": [...]
    },
    {
      "name": "Projects",
      "improvements": [...]
    }
  ]
}

For each section:
- Include 2-3 improved versions of existing bullets (original + improved)
- Include 2-3 completely new bullets to add (original: null, isNew: true)

IMPORTANT: Return ONLY valid JSON, no markdown or extra text.`;
