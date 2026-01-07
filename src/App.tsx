import { useState } from 'react';
import type { AIProviderType, AnalysisResult as AnalysisResultType } from './types';
import { FileUpload } from './components/FileUpload';
import { JobDescriptionInput } from './components/JobDescriptionInput';
import { ProviderSelector } from './components/ProviderSelector';
import { AnalysisResult } from './components/AnalysisResult';
import { extractTextFromPdf } from './utils/pdfParser';
import { getProvider } from './services/ai';
import { DEFAULT_AI_PROVIDER, MESSAGES } from './constants';

function App() {
  const [resumeFile, setResumeFile] = useState<File | null>(null);
  const [jobDescription, setJobDescription] = useState('');
  const [selectedProvider, setSelectedProvider] = useState<AIProviderType>(DEFAULT_AI_PROVIDER);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [result, setResult] = useState<AnalysisResultType | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleAnalyze = async () => {
    if (!resumeFile) {
      setError(MESSAGES.NO_RESUME);
      return;
    }
    if (!jobDescription.trim()) {
      setError(MESSAGES.NO_JOB_DESCRIPTION);
      return;
    }

    const provider = getProvider(selectedProvider);
    if (!provider.isConfigured()) {
      setError(MESSAGES.API_KEY_MISSING);
      return;
    }

    setError(null);
    setIsAnalyzing(true);
    setResult(null);

    try {
      const resumeText = await extractTextFromPdf(resumeFile);
      const analysisResult = await provider.analyze(resumeText, jobDescription);
      setResult(analysisResult);
    } catch (err) {
      console.error('Analysis error:', err);
      setError(err instanceof Error ? err.message : MESSAGES.ERROR_ANALYZING);
    } finally {
      setIsAnalyzing(false);
    }
  };

  const handleReset = () => {
    setResumeFile(null);
    setJobDescription('');
    setResult(null);
    setError(null);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <header className="text-center mb-8 relative">
          <a
            href="/ai-workshop/index.html"
            target="_blank"
            rel="noopener noreferrer"
            className="absolute right-0 top-0 flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            AI Workshop Docs
          </a>
          <h1 className="text-3xl font-bold text-gray-900">Resume Analyzer</h1>
          <p className="text-gray-600 mt-2">
            Analyze your resume against job descriptions and get actionable improvement suggestions
          </p>
        </header>

        {/* Main Content */}
        <div className="space-y-6">
          {/* Input Section */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="grid md:grid-cols-2 gap-6">
              <FileUpload onFileSelect={setResumeFile} selectedFile={resumeFile} />
              <JobDescriptionInput value={jobDescription} onChange={setJobDescription} />
            </div>

            {/* Provider Selector */}
            <div className="mt-6">
              <ProviderSelector selected={selectedProvider} onChange={setSelectedProvider} />
            </div>

            {/* Error Message */}
            {error && (
              <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
                {error}
              </div>
            )}

            {/* Action Buttons */}
            <div className="mt-6 flex gap-4">
              <button
                onClick={handleAnalyze}
                disabled={isAnalyzing}
                className="flex-1 py-3 px-6 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {isAnalyzing ? (
                  <span className="flex items-center justify-center gap-2">
                    <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                        fill="none"
                      />
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                      />
                    </svg>
                    {MESSAGES.ANALYZING}
                  </span>
                ) : (
                  'Analyze Resume'
                )}
              </button>
              {(resumeFile || jobDescription || result) && (
                <button
                  onClick={handleReset}
                  className="py-3 px-6 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Reset
                </button>
              )}
            </div>
          </div>

          {/* Results Section */}
          {result && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
              <AnalysisResult result={result} />
            </div>
          )}
        </div>

        {/* Footer */}
        <footer className="mt-8 text-center text-sm text-gray-500">
          <p>
            Using {getProvider(selectedProvider).name} for analysis
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;
