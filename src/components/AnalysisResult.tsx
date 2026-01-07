import { useState } from 'react';
import type { AnalysisResult as AnalysisResultType } from '../types';

interface AnalysisResultProps {
  result: AnalysisResultType;
}

function CopyButton({ text, className = '' }: { text: string; className?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      onClick={handleCopy}
      className={`p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors ${className}`}
      title="Copy to clipboard"
    >
      {copied ? (
        <svg className="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
        </svg>
      ) : (
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
        </svg>
      )}
    </button>
  );
}

export function AnalysisResult({ result }: AnalysisResultProps) {
  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getScoreBg = (score: number) => {
    if (score >= 80) return 'bg-green-500';
    if (score >= 60) return 'bg-yellow-500';
    return 'bg-red-500';
  };

  return (
    <div className="space-y-6">
      {/* Match Score */}
      <div className="flex items-center gap-6 p-4 bg-gray-50 rounded-lg">
        <div className="text-center">
          <span className={`text-4xl font-bold ${getScoreColor(result.matchScore)}`}>
            {result.matchScore}%
          </span>
          <p className="text-sm text-gray-500">Match Score</p>
        </div>
        <div className="flex-1">
          <div className="h-3 bg-gray-200 rounded-full overflow-hidden">
            <div
              className={`h-full transition-all duration-500 ${getScoreBg(result.matchScore)}`}
              style={{ width: `${result.matchScore}%` }}
            />
          </div>
        </div>
      </div>

      {/* Summary Section */}
      <div className="border border-gray-200 rounded-lg overflow-hidden">
        <div className="bg-gray-100 px-4 py-2 border-b border-gray-200">
          <h3 className="font-semibold text-gray-800">Summary</h3>
        </div>
        <div className="grid md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-gray-200">
          <div className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <span className="px-2 py-0.5 bg-gray-200 text-gray-600 text-xs font-medium rounded">CURRENT</span>
            </div>
            <p className="text-gray-700 text-sm">{result.summary.current}</p>
          </div>
          <div className="p-4 bg-green-50">
            <div className="flex items-center justify-between mb-2">
              <span className="px-2 py-0.5 bg-green-200 text-green-700 text-xs font-medium rounded">IMPROVED</span>
              <CopyButton text={result.summary.improved} />
            </div>
            <p className="text-gray-700 text-sm">{result.summary.improved}</p>
          </div>
        </div>
      </div>

      {/* Missing Skills/Keywords */}
      <div className="border border-gray-200 rounded-lg overflow-hidden">
        <div className="bg-gray-100 px-4 py-2 border-b border-gray-200">
          <h3 className="font-semibold text-gray-800">Missing Keywords & Skills</h3>
        </div>
        <div className="p-4">
          <div className="flex flex-wrap gap-2">
            {result.gaps.map((gap, idx) => (
              <span
                key={idx}
                className="px-3 py-1 bg-red-50 text-red-700 border border-red-200 rounded-full text-sm"
              >
                {gap}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Sections */}
      {result.sections.map((section, sectionIdx) => {
        const updates = section.improvements.filter((i) => !i.isNew);
        const newItems = section.improvements.filter((i) => i.isNew);

        return (
          <div key={sectionIdx} className="border border-gray-200 rounded-lg overflow-hidden">
            <div className="bg-gray-100 px-4 py-2 border-b border-gray-200">
              <h3 className="font-semibold text-gray-800">{section.name}</h3>
            </div>

            {/* Updated Bullets */}
            {updates.length > 0 && (
              <div className="border-b border-gray-200">
                <div className="px-4 py-2 bg-blue-50 border-b border-gray-200">
                  <span className="text-sm font-medium text-blue-700">Update Existing</span>
                </div>
                <div className="divide-y divide-gray-100">
                  {updates.map((item, idx) => (
                    <div key={idx} className="p-4">
                      <div className="grid md:grid-cols-2 gap-4">
                        <div>
                          <span className="text-xs text-gray-400 uppercase tracking-wide">Original</span>
                          <p className="text-gray-500 text-sm mt-1 line-through">{item.original}</p>
                        </div>
                        <div className="bg-green-50 rounded p-3 -m-1">
                          <div className="flex items-start justify-between gap-2">
                            <div>
                              <span className="text-xs text-green-600 uppercase tracking-wide">Improved</span>
                              <p className="text-gray-800 text-sm mt-1">{item.improved}</p>
                            </div>
                            <CopyButton text={item.improved} />
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* New Bullets */}
            {newItems.length > 0 && (
              <div>
                <div className="px-4 py-2 bg-emerald-50 border-b border-gray-200">
                  <span className="text-sm font-medium text-emerald-700">Add New</span>
                </div>
                <div className="divide-y divide-gray-100">
                  {newItems.map((item, idx) => (
                    <div key={idx} className="p-4 flex items-start justify-between gap-4">
                      <div className="flex items-start gap-3">
                        <span className="text-emerald-500 mt-0.5">
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                          </svg>
                        </span>
                        <p className="text-gray-800 text-sm">{item.improved}</p>
                      </div>
                      <CopyButton text={item.improved} />
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
