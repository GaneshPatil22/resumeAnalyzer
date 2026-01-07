export type AIProviderType = 'groq';

export interface SummaryComparison {
  current: string;
  improved: string;
}

export interface Improvement {
  original: string | null;
  improved: string;
  isNew: boolean;
}

export interface Section {
  name: string;
  improvements: Improvement[];
}

export interface AnalysisResult {
  matchScore: number;
  summary: SummaryComparison;
  gaps: string[];
  sections: Section[];
}

export interface AIProvider {
  name: string;
  analyze: (resumeText: string, jobDescription: string) => Promise<AnalysisResult>;
}

export interface AppState {
  resumeFile: File | null;
  resumeText: string;
  jobDescription: string;
  selectedProvider: AIProviderType;
  isAnalyzing: boolean;
  result: AnalysisResult | null;
  error: string | null;
}
