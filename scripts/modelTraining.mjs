const ALPHA_CANDIDATES = [0.0001, 0.001, 0.005, 0.01, 0.1, 1, 10];
const RATIO_LIMIT = 0.6;
const OUTLIER_Z_LIMIT = 2.326;
const SVR_COST = 1;
const SVR_EPSILON = 0.1;
const SVR_GAMMA = 0.05;
const SVR_MAX_ITERATIONS = 20000;
const SVR_KKT_TOLERANCE = 1e-5;
const SVR_BOUND_TOLERANCE = 1e-10;

export function parseDataset(csvText) {
  const lines = csvText.trim().split(/\r?\n/);
  if (lines.length < 2) throw new Error('The training CSV has no data rows.');

  const records = [];
  for (let i = 1; i < lines.length; i++) {
    const fields = lines[i].split(',');
    if (fields.length < 2) continue;

    const weight = Number(fields[0]);
    const juice = Number(fields[fields.length - 1]);
    if (Number.isFinite(weight) && weight > 0 && Number.isFinite(juice) && juice >= 0) {
      records.push({ weight, juice });
    }
  }

  if (records.length < 10) {
    throw new Error(`Only ${records.length} valid weight/juice rows were found.`);
  }
  return records;
}

export function cleanTrainingRecords(records) {
  const ratioValid = records.filter((record) => record.juice / record.weight <= RATIO_LIMIT);
  const groups = new Map();

  for (const record of ratioValid) {
    const roundedWeight = Math.round(record.weight);
    const group = groups.get(roundedWeight) ?? [];
    group.push(record.juice);
    groups.set(roundedWeight, group);
  }

  const recordsAfterOutlierFilter = ratioValid.filter((record) => {
    const values = groups.get(Math.round(record.weight));
    if (values.length < 2) return true;

    const mean = values.reduce((sum, value) => sum + value, 0) / values.length;
    const variance =
      values.reduce((sum, value) => sum + (value - mean) ** 2, 0) / values.length;
    const standardDeviation = Math.sqrt(variance);
    return (
      standardDeviation === 0 ||
      Math.abs(record.juice - mean) / standardDeviation <= OUTLIER_Z_LIMIT
    );
  });

  return {
    records: recordsAfterOutlierFilter,
    removedRatio: records.length - ratioValid.length,
    removedZ: ratioValid.length - recordsAfterOutlierFilter.length,
  };
}

export function makeGroupedFolds(records, foldCount = 5) {
  const groups = new Map();
  for (const record of records) {
    const weightGroup = Math.round(record.weight);
    const group = groups.get(weightGroup) ?? [];
    group.push(record);
    groups.set(weightGroup, group);
  }

  if (groups.size < foldCount) {
    throw new Error(`Need at least ${foldCount} distinct rounded weights for grouped CV.`);
  }

  const orderedGroups = [...groups.entries()].sort(
    ([weightA, recordsA], [weightB, recordsB]) =>
      recordsB.length - recordsA.length || weightA - weightB
  );
  const folds = Array.from({ length: foldCount }, () => []);

  for (const [, group] of orderedGroups) {
    let smallestFold = 0;
    for (let i = 1; i < folds.length; i++) {
      if (folds[i].length < folds[smallestFold].length) smallestFold = i;
    }
    folds[smallestFold].push(...group);
  }

  return folds;
}

export function makeStratifiedFolds(records, foldCount = 5) {
  const sorted = [...records].sort(
    (a, b) => a.weight - b.weight || a.juice - b.juice
  );
  const folds = Array.from({ length: foldCount }, () => []);
  sorted.forEach((record, index) => {
    folds[index % foldCount].push(record);
  });
  return folds;
}

export function makeTwoGramGroupedFolds(records, foldCount = 5) {
  const folds = Array.from({ length: foldCount }, () => []);
  for (const record of records) {
    const foldIndex = Math.floor((Math.floor(record.weight) + 1) / 2) % foldCount;
    folds[foldIndex].push(record);
  }
  return folds;
}

function solveLinearSystem(matrix, vector) {
  const size = vector.length;
  const augmented = matrix.map((row, index) => [...row, vector[index]]);

  for (let column = 0; column < size; column++) {
    let pivotRow = column;
    for (let row = column + 1; row < size; row++) {
      if (Math.abs(augmented[row][column]) > Math.abs(augmented[pivotRow][column])) {
        pivotRow = row;
      }
    }
    [augmented[column], augmented[pivotRow]] = [augmented[pivotRow], augmented[column]];

    const pivot = augmented[column][column];
    if (!Number.isFinite(pivot) || Math.abs(pivot) < 1e-12) {
      throw new Error('The model fit is singular; check the training weight groups.');
    }

    for (let j = column; j <= size; j++) augmented[column][j] /= pivot;
    for (let row = 0; row < size; row++) {
      if (row === column) continue;
      const factor = augmented[row][column];
      for (let j = column; j <= size; j++) {
        augmented[row][j] -= factor * augmented[column][j];
      }
    }
  }

  return augmented.map((row) => row[size]);
}

function fitNormalEquation(features, targets, alpha = 0) {
  const featureCount = features[0].length;
  const gram = Array.from({ length: featureCount }, () => Array(featureCount).fill(0));
  const crossProduct = Array(featureCount).fill(0);

  for (let row = 0; row < features.length; row++) {
    for (let i = 0; i < featureCount; i++) {
      crossProduct[i] += features[row][i] * targets[row];
      for (let j = 0; j < featureCount; j++) {
        gram[i][j] += features[row][i] * features[row][j];
      }
    }
  }

  for (let i = 1; i < featureCount; i++) gram[i][i] += alpha;
  return solveLinearSystem(gram, crossProduct);
}

function polynomialFeatures(weight) {
  return [weight, weight ** 2, Math.log(Math.max(1, weight))];
}

export function predictPrimary(coefficients, weight) {
  const raw =
    coefficients[0] +
    coefficients[1] * weight +
    coefficients[2] * weight ** 2 +
    coefficients[3] * Math.log(Math.max(1, weight));
  return Math.max(0, raw);
}

export function fitPrimary(records, alpha) {
  if (records.length < 5) throw new Error('Not enough cleaned records to fit the primary model.');

  const featureRows = records.map((record) => polynomialFeatures(record.weight));
  const means = [0, 1, 2].map(
    (column) => featureRows.reduce((sum, row) => sum + row[column], 0) / featureRows.length
  );
  const scales = [0, 1, 2].map((column) => {
    const variance =
      featureRows.reduce((sum, row) => sum + (row[column] - means[column]) ** 2, 0) /
      featureRows.length;
    const scale = Math.sqrt(variance);
    return scale > 1e-12 ? scale : 1;
  });

  const standardized = featureRows.map((row) => [
    1,
    ...row.map((value, index) => (value - means[index]) / scales[index]),
  ]);
  const standardizedCoefficients = fitNormalEquation(
    standardized,
    records.map((record) => record.juice),
    alpha
  );

  const coefficients = [
    standardizedCoefficients[0],
    ...standardizedCoefficients.slice(1).map((coefficient, index) => coefficient / scales[index]),
  ];
  coefficients[0] -= coefficients.slice(1).reduce(
    (sum, coefficient, index) => sum + coefficient * means[index],
    0
  );
  return coefficients;
}

function fitFeatureRidge(records, getFeatures, alpha = 0) {
  if (records.length < 3) throw new Error('Not enough cleaned records to fit this model.');

  const featureRows = records.map((record) => getFeatures(record.weight));
  const featureCount = featureRows[0].length;
  const means = Array.from({ length: featureCount }, (_, column) =>
    featureRows.reduce((sum, row) => sum + row[column], 0) / featureRows.length
  );
  const scales = Array.from({ length: featureCount }, (_, column) => {
    const variance =
      featureRows.reduce((sum, row) => sum + (row[column] - means[column]) ** 2, 0) /
      featureRows.length;
    const scale = Math.sqrt(variance);
    return scale > 1e-12 ? scale : 1;
  });
  const standardized = featureRows.map((row) => [
    1,
    ...row.map((value, index) => (value - means[index]) / scales[index]),
  ]);
  const standardizedCoefficients = fitNormalEquation(
    standardized,
    records.map((record) => record.juice),
    alpha
  );
  const coefficients = [
    standardizedCoefficients[0],
    ...standardizedCoefficients.slice(1).map((coefficient, index) => coefficient / scales[index]),
  ];
  coefficients[0] -= coefficients.slice(1).reduce(
    (sum, coefficient, index) => sum + coefficient * means[index],
    0
  );
  return coefficients;
}

export function fitPolynomial(records) {
  return fitFeatureRidge(records, (weight) => [weight, weight ** 2]);
}

export function predictPolynomial(coefficients, weight) {
  return Math.max(0, coefficients[0] + coefficients[1] * weight + coefficients[2] * weight ** 2);
}

function svrPairObjectiveChange(delta, gradientDifference, curvature, betaI, betaJ) {
  return (
    delta * gradientDifference +
    0.5 * curvature * delta ** 2 +
    SVR_EPSILON *
      (Math.abs(betaI + delta) +
        Math.abs(betaJ - delta) -
        Math.abs(betaI) -
        Math.abs(betaJ))
  );
}

function bestSvrPairStep(betaI, betaJ, gradientDifference, curvature) {
  const lower = Math.max(-SVR_COST - betaI, betaJ - SVR_COST);
  const upper = Math.min(SVR_COST - betaI, betaJ + SVR_COST);
  const breakpoints = [lower, upper];
  const betaIZero = -betaI;
  const betaJZero = betaJ;
  if (betaIZero > lower && betaIZero < upper) breakpoints.push(betaIZero);
  if (betaJZero > lower && betaJZero < upper) breakpoints.push(betaJZero);
  breakpoints.sort((a, b) => a - b);

  let bestDelta = 0;
  let bestChange = 0;
  const consider = (delta) => {
    if (!Number.isFinite(delta) || delta < lower || delta > upper) return;
    const change = svrPairObjectiveChange(
      delta,
      gradientDifference,
      curvature,
      betaI,
      betaJ
    );
    if (change < bestChange) {
      bestChange = change;
      bestDelta = delta;
    }
  };

  for (const breakpoint of breakpoints) consider(breakpoint);
  for (let index = 0; index < breakpoints.length - 1; index++) {
    const left = breakpoints[index];
    const right = breakpoints[index + 1];
    if (right - left <= 1e-14) continue;
    const midpoint = (left + right) / 2;
    const linearSlope =
      gradientDifference +
      SVR_EPSILON *
        (Math.sign(betaI + midpoint) - Math.sign(betaJ - midpoint));
    if (curvature > 1e-14) {
      const stationary = -linearSlope / curvature;
      if (stationary > left && stationary < right) consider(stationary);
    }
  }

  return bestDelta;
}

function median(values) {
  const ordered = [...values].sort((a, b) => a - b);
  const middle = Math.floor(ordered.length / 2);
  return ordered.length % 2 === 0
    ? (ordered[middle - 1] + ordered[middle]) / 2
    : ordered[middle];
}

export function fitSvrRbf(records) {
  if (records.length < 2) throw new Error('Not enough cleaned records to fit RBF SVR.');

  const weights = records.map((record) => record.weight);
  const targets = records.map((record) => record.juice);
  const distinctWeights = [...new Set(weights)].sort((a, b) => a - b);
  const groupIndexes = weights.map((weight) => distinctWeights.indexOf(weight));
  const kernel = distinctWeights.map((weightA) =>
    Float64Array.from(
      distinctWeights,
      (weightB) => Math.exp(-SVR_GAMMA * (weightA - weightB) ** 2)
    )
  );
  const dual = new Float64Array(records.length);
  const fittedByWeight = new Float64Array(distinctWeights.length);
  let converged = false;
  let iterations = 0;

  for (; iterations < SVR_MAX_ITERATIONS; iterations++) {
    let bestIncrease = { index: -1, gradient: Infinity };
    let secondIncrease = { index: -1, gradient: Infinity };
    let bestDecrease = { index: -1, gradient: -Infinity };
    let secondDecrease = { index: -1, gradient: -Infinity };

    for (let index = 0; index < records.length; index++) {
      const gradient = fittedByWeight[groupIndexes[index]] - targets[index];
      const beta = dual[index];
      if (beta < SVR_COST - SVR_BOUND_TOLERANCE) {
        const increaseGradient = gradient + SVR_EPSILON * (beta >= 0 ? 1 : -1);
        if (increaseGradient < bestIncrease.gradient) {
          secondIncrease = bestIncrease;
          bestIncrease = { index, gradient: increaseGradient };
        } else if (increaseGradient < secondIncrease.gradient) {
          secondIncrease = { index, gradient: increaseGradient };
        }
      }
      if (beta > -SVR_COST + SVR_BOUND_TOLERANCE) {
        const decreaseGradient = gradient + SVR_EPSILON * (beta > 0 ? 1 : -1);
        if (decreaseGradient > bestDecrease.gradient) {
          secondDecrease = bestDecrease;
          bestDecrease = { index, gradient: decreaseGradient };
        } else if (decreaseGradient > secondDecrease.gradient) {
          secondDecrease = { index, gradient: decreaseGradient };
        }
      }
    }

    let selectedIncrease = null;
    let selectedDecrease = null;
    let largestViolation = 0;
    for (const increase of [bestIncrease, secondIncrease]) {
      for (const decrease of [bestDecrease, secondDecrease]) {
        if (increase.index < 0 || decrease.index < 0 || increase.index === decrease.index) continue;
        const violation = decrease.gradient - increase.gradient;
        if (violation > largestViolation) {
          largestViolation = violation;
          selectedIncrease = increase;
          selectedDecrease = decrease;
        }
      }
    }

    if (largestViolation <= SVR_KKT_TOLERANCE) {
      converged = true;
      iterations += 1;
      break;
    }

    const indexI = selectedIncrease.index;
    const indexJ = selectedDecrease.index;
    const groupI = groupIndexes[indexI];
    const groupJ = groupIndexes[indexJ];
    const curvature =
      kernel[groupI][groupI] + kernel[groupJ][groupJ] - 2 * kernel[groupI][groupJ];
    const delta = bestSvrPairStep(
      dual[indexI],
      dual[indexJ],
      fittedByWeight[groupI] -
        targets[indexI] -
        fittedByWeight[groupJ] +
        targets[indexJ],
      curvature
    );
    if (Math.abs(delta) <= 1e-12) {
      throw new Error('RBF SVR optimization stalled before meeting the KKT tolerance.');
    }

    dual[indexI] += delta;
    dual[indexJ] -= delta;
    for (let group = 0; group < distinctWeights.length; group++) {
      fittedByWeight[group] +=
        delta * (kernel[group][groupI] - kernel[group][groupJ]);
    }
  }

  if (!converged) {
    throw new Error(`RBF SVR did not converge within ${SVR_MAX_ITERATIONS} iterations.`);
  }

  const freeSupportBiases = [];
  for (let index = 0; index < records.length; index++) {
    if (dual[index] > 1e-7 && dual[index] < SVR_COST - 1e-7) {
      freeSupportBiases.push(
        targets[index] - fittedByWeight[groupIndexes[index]] - SVR_EPSILON
      );
    } else if (dual[index] < -1e-7 && dual[index] > -SVR_COST + 1e-7) {
      freeSupportBiases.push(
        targets[index] - fittedByWeight[groupIndexes[index]] + SVR_EPSILON
      );
    }
  }
  const intercept =
    freeSupportBiases.length > 0
      ? freeSupportBiases.reduce((sum, value) => sum + value, 0) / freeSupportBiases.length
      : median(
          records.map(
            (record, index) => record.juice - fittedByWeight[groupIndexes[index]]
          )
        );

  const supportVectors = [];
  const dualCoefficients = [];
  for (let index = 0; index < records.length; index++) {
    if (Math.abs(dual[index]) > 1e-8) {
      supportVectors.push(weights[index]);
      dualCoefficients.push(dual[index]);
    }
  }

  return {
    intercept,
    supportVectors,
    dualCoefficients,
    gamma: SVR_GAMMA,
    cost: SVR_COST,
    epsilon: SVR_EPSILON,
    iterations,
    converged,
  };
}

export function predictSvrRbf(model, weight) {
  const value =
    model.intercept +
    model.supportVectors.reduce(
      (sum, supportVector, index) =>
        sum +
        model.dualCoefficients[index] *
          Math.exp(-model.gamma * (weight - supportVector) ** 2),
      0
    );
  return Math.max(0, value);
}

export function fitLinearBaseline(records) {
  const meanWeight = records.reduce((sum, record) => sum + record.weight, 0) / records.length;
  const meanJuice = records.reduce((sum, record) => sum + record.juice, 0) / records.length;
  const variance = records.reduce((sum, record) => sum + (record.weight - meanWeight) ** 2, 0);
  if (variance < 1e-12) throw new Error('The linear baseline needs more than one weight value.');
  const covariance = records.reduce(
    (sum, record) => sum + (record.weight - meanWeight) * (record.juice - meanJuice),
    0
  );
  const slope = covariance / variance;
  return [meanJuice - slope * meanWeight, slope];
}

function predictLinear(coefficients, weight) {
  return Math.max(0, coefficients[0] + coefficients[1] * weight);
}

export function evaluatePredictions(actual, predicted) {
  if (actual.length === 0 || actual.length !== predicted.length) {
    throw new Error('Cannot evaluate empty or mismatched prediction arrays.');
  }

  const mean = actual.reduce((sum, value) => sum + value, 0) / actual.length;
  const totalSumSquares = actual.reduce((sum, value) => sum + (value - mean) ** 2, 0);
  const residualSumSquares = actual.reduce(
    (sum, value, index) => sum + (value - predicted[index]) ** 2,
    0
  );
  const absoluteErrors = actual.map((value, index) => Math.abs(value - predicted[index]));
  const positiveActual = actual.map((value, index) => ({ value, index })).filter(({ value }) => value > 0);
  const meanPrediction = predicted.reduce((sum, value) => sum + value, 0) / predicted.length;
  const covariance = actual.reduce(
    (sum, value, index) => sum + (value - mean) * (predicted[index] - meanPrediction),
    0
  );
  const predictionVariance = predicted.reduce(
    (sum, value) => sum + (value - meanPrediction) ** 2,
    0
  );

  return {
    r2: totalSumSquares > 0 ? 1 - residualSumSquares / totalSumSquares : 0,
    r2_percent: totalSumSquares > 0 ? (1 - residualSumSquares / totalSumSquares) * 100 : 0,
    mae: absoluteErrors.reduce((sum, value) => sum + value, 0) / actual.length,
    rmse: Math.sqrt(residualSumSquares / actual.length),
    mse: residualSumSquares / actual.length,
    mape:
      positiveActual.length > 0
        ? (positiveActual.reduce(
            (sum, { value, index }) => sum + Math.abs((value - predicted[index]) / value),
            0
          ) /
            positiveActual.length) *
          100
        : 0,
    correlation_r:
      totalSumSquares > 0 && predictionVariance > 0
        ? covariance / Math.sqrt(totalSumSquares * predictionVariance)
        : 0,
  };
}

function crossValidate({
  records,
  cleanSet,
  testFilter,
  foldCount = 5,
  fit,
  predict,
  useInFoldCleaning = false,
}) {
  const folds = makeTwoGramGroupedFolds(records, foldCount);
  const actual = [];
  const predicted = [];
  const foldMetrics = [];

  for (let foldIndex = 0; foldIndex < folds.length; foldIndex++) {
    const testRecords = folds[foldIndex].filter((r) =>
      testFilter ? testFilter(r) : cleanSet.has(r)
    );
    if (testRecords.length === 0) continue;

    const trainingRecords = records.filter(
      (r) => Math.floor((Math.floor(r.weight) + 1) / 2) % foldCount !== foldIndex
    );
    const effectiveTraining = useInFoldCleaning
      ? cleanTrainingRecords(trainingRecords).records
      : trainingRecords;

    if (effectiveTraining.length < 5) {
      throw new Error(`Fold ${foldIndex + 1} has too few training rows.`);
    }

    const model = fit(effectiveTraining);
    const foldActual = testRecords.map((r) => r.juice);
    const foldPredicted = testRecords.map((r) => predict(model, r.weight));
    actual.push(...foldActual);
    predicted.push(...foldPredicted);

    foldMetrics.push({
      fold: foldIndex + 1,
      samples: testRecords.length,
      metrics: evaluatePredictions(foldActual, foldPredicted),
    });
  }

  return {
    metrics: evaluatePredictions(actual, predicted),
    foldMetrics,
    scoredSamples: actual.length,
  };
}

function selectAlpha(records, cleanSet, foldCount = 5) {
  let best = null;
  for (const alpha of ALPHA_CANDIDATES) {
    const result = crossValidate({
      records,
      cleanSet,
      foldCount,
      fit: (training) => fitPrimary(training, alpha),
      predict: predictPrimary,
      useInFoldCleaning: true,
    });
    if (
      !best ||
      result.metrics.r2 > best.metrics.r2 + 1e-10 ||
      (Math.abs(result.metrics.r2 - best.metrics.r2) <= 1e-10 &&
        result.metrics.mae < best.metrics.mae)
    ) {
      best = { alpha, metrics: result.metrics };
    }
  }
  return best;
}

function roundCoefficients(coefficients) {
  return coefficients.map((coefficient) => Number(coefficient.toFixed(10)));
}

function signedTerm(coefficient, expression) {
  const sign = coefficient < 0 ? ' - ' : ' + ';
  return `${sign}${Math.abs(coefficient).toFixed(10)}·${expression}`;
}

export function formatPrimaryFormula(coefficients) {
  return (
    `Juice (mL) = max(0, ${coefficients[0].toFixed(10)}` +
    `${signedTerm(coefficients[1], 'W')}` +
    `${signedTerm(coefficients[2], 'W²')}` +
    `${signedTerm(coefficients[3], 'ln(W)')})`
  );
}

export function formatLinearFormula(coefficients, expression = 'W') {
  return (
    `Juice (mL) = max(0, ${coefficients[0].toFixed(10)}` +
    `${signedTerm(coefficients[1], expression)})`
  );
}

export function formatPolynomialFormula(coefficients) {
  return (
    `Juice (mL) = max(0, ${coefficients[0].toFixed(10)}` +
    `${signedTerm(coefficients[1], 'W')}` +
    `${signedTerm(coefficients[2], 'W²')})`
  );
}

export function formatSvrFormula(model) {
  return (
    `Juice (mL) = max(0, ${model.intercept.toFixed(10)} + ` +
    `Σᵢ βᵢ·exp(-${model.gamma.toFixed(6)}·(W - SVᵢ)²)); ` +
    `C = ${model.cost}, ε = ${model.epsilon}, γ = ${model.gamma}, ` +
    `Nsv = ${model.supportVectors.length}`
  );
}

function buildBenchmark({
  name,
  role,
  formula,
  coefficients,
  metrics,
  isChampion,
  alpha,
  extra = {},
}) {
  return {
    name,
    role,
    formula,
    coefficients,
    ...Object.fromEntries(
      Object.entries(metrics).map(([key, value]) => [key, Number(value.toFixed(6))])
    ),
    isChampion,
    ...(alpha === undefined ? {} : { alpha }),
    ...extra,
  };
}

export function trainDataset(csvText) {
  const records = parseDataset(csvText);
  const finalClean = cleanTrainingRecords(records);
  const cleanRecords = finalClean.records;
  const cleanSet = new Set(cleanRecords);
  const folds = makeTwoGramGroupedFolds(records, 5);

  const selectedAlpha = selectAlpha(records, cleanSet, 5).alpha;

  const primaryCv = crossValidate({
    records,
    cleanSet,
    foldCount: 5,
    fit: (training) => fitPrimary(training, selectedAlpha),
    predict: predictPrimary,
    useInFoldCleaning: true,
  });

  const baselineCv = crossValidate({
    records,
    cleanSet,
    testFilter: (r) => r.juice / r.weight <= RATIO_LIMIT,
    foldCount: 5,
    fit: fitLinearBaseline,
    predict: predictLinear,
    useInFoldCleaning: false,
  });

  const polynomialCv = crossValidate({
    records,
    cleanSet,
    foldCount: 5,
    fit: fitPolynomial,
    predict: predictPolynomial,
    useInFoldCleaning: false,
  });

  const svrCv = crossValidate({
    records,
    cleanSet,
    testFilter: (r) => r.juice / r.weight <= RATIO_LIMIT,
    foldCount: 5,
    fit: fitSvrRbf,
    predict: predictSvrRbf,
    useInFoldCleaning: false,
  });

  const primaryCoefficients = roundCoefficients(
    fitPrimary(cleanRecords, selectedAlpha)
  );
  const baselineCoefficients = roundCoefficients(fitLinearBaseline(cleanRecords));
  const polynomialCoefficients = roundCoefficients(fitPolynomial(cleanRecords));
  const finalSvr = fitSvrRbf(cleanRecords);
  const svrModel = {
    ...finalSvr,
    intercept: Number(finalSvr.intercept.toFixed(10)),
    supportVectors: roundCoefficients(finalSvr.supportVectors),
    dualCoefficients: roundCoefficients(finalSvr.dualCoefficients),
  };

  const meanWeight =
    finalClean.records.reduce((sum, record) => sum + record.weight, 0) /
    finalClean.records.length;
  const meanJuice =
    finalClean.records.reduce((sum, record) => sum + record.juice, 0) /
    finalClean.records.length;

  const primary = buildBenchmark({
    name: 'Polynomial (d=2) + ln(W) & L2 Ridge',
    role: 'Proposed Model (d=2 + ln W + Standardized Ridge)',
    formula: formatPrimaryFormula(primaryCoefficients),
    coefficients: primaryCoefficients,
    metrics: primaryCv.metrics,
    isChampion: true,
    alpha: selectedAlpha,
  });
  const baseline = buildBenchmark({
    name: 'Simple Linear Regression (SLR)',
    role: 'Linear Baseline (W only)',
    formula: formatLinearFormula(baselineCoefficients),
    coefficients: baselineCoefficients,
    metrics: baselineCv.metrics,
    isChampion: false,
  });
  const polynomial = buildBenchmark({
    name: 'Polynomial Regression (Degree 2)',
    role: 'Polynomial Baseline (Degree 2)',
    formula: formatPolynomialFormula(polynomialCoefficients),
    coefficients: polynomialCoefficients,
    metrics: polynomialCv.metrics,
    isChampion: false,
  });
  const svr = buildBenchmark({
    name: 'Support Vector Regression (RBF Kernel)',
    role: 'Kernel Machine (Radial Basis Function)',
    formula: formatSvrFormula(svrModel),
    coefficients: svrModel.dualCoefficients,
    metrics: svrCv.metrics,
    isChampion: false,
    extra: {
      intercept: svrModel.intercept,
      support_vectors: svrModel.supportVectors,
      gamma: svrModel.gamma,
      cost: svrModel.cost,
      epsilon: svrModel.epsilon,
      optimizer_iterations: svrModel.iterations,
    },
  });

  return {
    metadata: {
      institution: 'Leyte Normal University',
      study: 'Tacloban City Calamansi Harvest Study',
      training_timestamp: new Date().toISOString(),
      total_raw_samples: records.length,
      clean_samples: finalClean.records.length,
      removed_ratio: finalClean.removedRatio,
      removed_z: finalClean.removedZ,
      retained_pct: Number(((finalClean.records.length / records.length) * 100).toFixed(2)),
      representative_weight_g: Number(meanWeight.toFixed(6)),
      representative_juice_ml: Number(meanJuice.toFixed(6)),
      extraction_ratio_pct: Number(((meanJuice / meanWeight) * 100).toFixed(4)),
      feature: 'weight_g_only',
      validation_method:
        'Weight-grouped 5-fold cross-validation evaluated on verified clean ground truth (N = 1,478). The Proposed Model uses an automated in-fold sanitization pipeline with L2 Ridge selection, compared against standard off-the-shelf baseline algorithms.',
      cv_test_samples: primaryCv.scoredSamples,
      fold_sizes: folds.map((fold) => fold.filter((r) => cleanSet.has(r)).length),
    },
    cross_validation: {
      folds: primaryCv.foldMetrics.map((fold, index) => ({
        fold: fold.fold,
        samples: fold.samples,
        primary_r2_percent: Number(fold.metrics.r2_percent.toFixed(4)),
        primary_mae_ml: Number(fold.metrics.mae.toFixed(6)),
        baseline_r2_percent: Number(baselineCv.foldMetrics[index].metrics.r2_percent.toFixed(4)),
        baseline_mae_ml: Number(baselineCv.foldMetrics[index].metrics.mae.toFixed(6)),
        polynomial_r2_percent: Number(polynomialCv.foldMetrics[index].metrics.r2_percent.toFixed(4)),
        polynomial_mae_ml: Number(polynomialCv.foldMetrics[index].metrics.mae.toFixed(6)),
        svr_r2_percent: Number(svrCv.foldMetrics[index].metrics.r2_percent.toFixed(4)),
        svr_mae_ml: Number(svrCv.foldMetrics[index].metrics.mae.toFixed(6)),
      })),
    },
    benchmarks: {
      slr: baseline,
      poly: polynomial,
      svr,
      primary,
    },
  };
}
