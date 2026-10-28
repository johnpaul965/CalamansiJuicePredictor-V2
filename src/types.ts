export type UserRole = 'user' | 'admin';
export type UserStatus = 'Active' | 'Suspended';

export interface AppUser {
  id: string;
  username: string;
  password?: string;
  role: UserRole;
  status: UserStatus;
  joined: string;
}

export interface PredictionResult {
  count: number;
  repWeight: number;
  isSingleFruit?: boolean;
  slrTotalMl: number;
  polyTotalMl: number;
  rbfTotalMl: number;
  primaryTotalMl: number;
  bottles330: number;
  bottles500: number;
  bottles1000: number;
  extractionRatioPercent: number;
}

export interface PredictionLog {
  id: string;
  date: string;
  user: string;
  weightG: number;
  weight: string;
  count: number;
  slr: string;
  primary: string;
  slrMl?: number;
  polyMl?: number;
  rbf?: string;
  rbfMl?: number;
  primaryMl?: number;
  // Older browser histories used these fields before the primary-model update.
  poly?: string;
  cbPoly?: string;
  cbPolyMl?: number;
}

export interface ModelBenchmark {
  name: string;
  shortName: string;
  role: string;
  r2Percent: number;
  maeMl: number;
  rmseMl: number;
  mapePercent: number;
  formula: string;
  badge: string;
  isChampion?: boolean;
  alpha?: number;
}

export interface ResearchMetadata {
  institution: string;
  study: string;
  total_samples: number;
  clean_samples: number;
  overall_mean_fruit_weight_g: number;
  overall_mean_fruit_juice_ml: number;
}

export interface AblationMetric {
  name: string;
  dirtyR2: number;
  cleanR2: number;
  r2Gain: number;
  dirtyMae: number;
  cleanMae: number;
  maeReduction: number;
}
