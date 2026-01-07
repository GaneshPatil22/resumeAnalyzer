import type { AIProvider } from './types';
import type { AIProviderType } from '../../types';
import { groqProvider } from './groqProvider';

// Registry of all available AI providers
const providers: Record<AIProviderType, AIProvider> = {
  groq: groqProvider,
};

// Get a specific provider
export const getProvider = (type: AIProviderType): AIProvider => {
  const provider = providers[type];
  if (!provider) {
    throw new Error(`Unknown AI provider: ${type}`);
  }
  return provider;
};

// Get all available providers
export const getAllProviders = (): { type: AIProviderType; provider: AIProvider }[] => {
  return Object.entries(providers).map(([type, provider]) => ({
    type: type as AIProviderType,
    provider,
  }));
};

// Check which providers are configured
export const getConfiguredProviders = (): AIProviderType[] => {
  return Object.entries(providers)
    .filter(([, provider]) => provider.isConfigured())
    .map(([type]) => type as AIProviderType);
};

export type { AIProvider };
