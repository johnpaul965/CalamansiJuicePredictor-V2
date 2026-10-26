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
  slrTotalMl: number;
  polyTotalMl: number;
  svrTotalMl: number;
  xgbTotalMl: number;
  catboostTotalMl: number;
  rfTotalMl: number;
  cbPolyTotalMl: number;
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
  poly: string;
  cbPoly: string;
  slrMl: number;
  polyMl: number;
  cbPolyMl: number;
}

export interface ModelBenchmark {
  name: string;
  shortName: string;
  role: string;
  correlationR: number;
  r2Percent: number;
  maeMl: number;
  rmseMl: number;
  mapePercent: number;
  formula: string;
  badge: string;
  isChampion?: boolean;
}

export interface ResearchMetadata {
  institution: string;
  study: string;
  total_samples: number;
  clean_samples: number;
  training_samples: number;
  testing_samples: number;
  overall_mean_fruit_weight_g: number;
  overall_mean_fruit_juice_ml: number;
}
