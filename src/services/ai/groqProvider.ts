import type { AIProvider } from './types';
import type { AnalysisResult } from '../../types';
import { ANALYSIS_PROMPT } from '../../constants';

const getApiKey = () => import.meta.env.VITE_GROQ_API_KEY || '';

export const groqProvider: AIProvider = {
  name: 'Groq',

  isConfigured: () => Boolean(getApiKey()),

  analyze: async (resumeText: string, jobDescription: string): Promise<AnalysisResult> => {
    const apiKey = getApiKey();
    if (!apiKey) {
      throw new Error('Groq API key not configured');
    }

    const prompt = `${ANALYSIS_PROMPT}

---
RESUME:
${resumeText}

---
JOB DESCRIPTION:
${jobDescription}`;

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: [
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.3,
        max_tokens: 4096,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Groq API error: ${error}`);
    }

    const data = await response.json();
    const text = data.choices[0]?.message?.content || '';

    // Parse JSON from response (handle potential markdown code blocks)
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('Invalid response format from Groq');
    }

    const parsed = JSON.parse(jsonMatch[0]) as AnalysisResult;
    return parsed;
  },
};
