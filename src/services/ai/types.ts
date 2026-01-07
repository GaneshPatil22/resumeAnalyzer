import type { AnalysisResult } from '../../types';

export interface AIProvider {
  name: string;
  analyze: (resumeText: string, jobDescription: string) => Promise<AnalysisResult>;
  isConfigured: () => boolean;
}
