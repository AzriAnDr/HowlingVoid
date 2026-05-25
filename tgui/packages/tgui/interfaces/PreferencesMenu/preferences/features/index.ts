// Unlike species and others, feature files export arrays of features
// rather than individual ones. This is because a lot of features are
// extremely small, and so it's easier for everyone to just combine them
// together.
// This still helps to prevent the server from needing to send client UI data
import type { Feature } from './base';

// while also preventing downstreams from needing to mutate existing files.
export const features: Record<string, Feature<unknown>> = {};

let requireFeature: __WebpackModuleApi.RequireContext | null = null;

try {
  requireFeature = require.context(
    './',
    true,
    /^(?!\.\/(?:base|dropdowns|dropdowns_nova)\.tsx$).*\.tsx$/,
  );
} catch {
  // Bun's test runner does not implement webpack/rspack contexts.
}

if (requireFeature) {
  for (const key of requireFeature.keys()) {
    for (const [featureKey, feature] of Object.entries(requireFeature(key))) {
      if (
        typeof feature === 'object' &&
        feature !== null &&
        'name' in feature &&
        'component' in feature
      ) {
        features[featureKey] = feature as Feature<unknown>;
      }
    }
  }
}
