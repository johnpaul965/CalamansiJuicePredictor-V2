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
  sizeCode: number;
  sizeLabel: string;
  slrTotalMl: number;
  mlrTotalMl: number;
  polyTotalMl: number;
  bottles330: number;
  bottles500: number;
  bottles1000: number;
}

export interface PredictionLog {
  id: string;
  date: string;
  user: string;
  weightG: number;
  weight: string;
  size: string;
  slr: string;
  mlr: string;
  poly: string;
  slrMl: number;
  mlrMl: number;
  polyMl: number;
  count: number;
}

export interface ModelMetricItem {
  features: string[];
  formula: string;
  metrics: {
    r2: number;
    mae: number;
    rmse: number;
    mse: number;
    mape: number;
  };
  coefficients: Record<string, any>;
}

export interface ResearchMetadata {
  institution: string;
  study: string;
  total_samples: number;
  training_samples: number;
  testing_samples: number;
  best_model: string;
  overall_mean_fruit_weight_g: number;
  overall_mean_fruit_juice_ml: number;
}
