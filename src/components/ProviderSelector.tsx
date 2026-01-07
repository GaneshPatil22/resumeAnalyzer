import type { AIProviderType } from '../types';
import { getAllProviders } from '../services/ai';

interface ProviderSelectorProps {
  selected: AIProviderType;
  onChange: (provider: AIProviderType) => void;
}

export function ProviderSelector({ selected, onChange }: ProviderSelectorProps) {
  const providers = getAllProviders();

  return (
    <div className="w-full">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        AI Provider
      </label>
      <div className="flex gap-2">
        {providers.map(({ type, provider }) => (
          <button
            key={type}
            onClick={() => onChange(type)}
            className={`flex-1 py-2 px-4 rounded-lg border transition-colors ${
              selected === type
                ? 'border-blue-500 bg-blue-50 text-blue-700'
                : 'border-gray-300 hover:border-gray-400'
            } ${!provider.isConfigured() ? 'opacity-50' : ''}`}
          >
            <span className="font-medium">{provider.name}</span>
            {!provider.isConfigured() && (
              <span className="block text-xs text-red-500">Not configured</span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}
