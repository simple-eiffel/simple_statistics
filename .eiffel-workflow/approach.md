# Implementation Approach: simple_statistics

## Phase 4 Implementation Strategy

### 1. Descriptive Statistics Implementation

#### 1.1 Sum (Foundation)
- **Feature:** `sum(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Kahan summation (compensated summation for numerical stability)
- **Why:** Sum is the foundation for mean, variance, covariance
- **Implementation:**
  ```eiffel
  local
      running_sum: REAL_64
      compensation: REAL_64
      temp: REAL_64
  do
      running_sum := 0.0
      compensation := 0.0
      across data as ic loop
          temp := ic.item - compensation
          running_sum := running_sum + temp
          compensation := (running_sum - ic.item) - temp
      end
      Result := running_sum
  end
  ```

#### 1.2 Mean (Stable Average)
- **Feature:** `mean(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Welford's online mean (one pass, numerically stable)
- **Relies on:** Nothing
- **Implementation:**
  ```eiffel
  local
      mean_val: REAL_64
      count: INTEGER
  do
      mean_val := 0.0
      count := 0
      across data as ic loop
          count := count + 1
          mean_val := mean_val + (ic.item - mean_val) / count
      end
      Result := mean_val
  end
  ```

#### 1.3 Variance (Stable Dispersion)
- **Feature:** `variance(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Welford's two-pass variance (population variance, numerically stable)
- **Relies on:** mean
- **Implementation:** Two pass - compute mean first, then sum of squared deviations

#### 1.4 Std_dev (Square Root of Variance)
- **Feature:** `std_dev(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** `sqrt(variance(data))`
- **Relies on:** variance

#### 1.5 Min_value, Max_value, Range (Comparisons)
- **Features:** `min_value`, `max_value`, `range`
- **Algorithm:** Single pass, track running min/max
- **Relies on:** Nothing

#### 1.6 Median (Sorted Statistics)
- **Feature:** `median(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:**
  1. Copy and sort array (using Eiffel's built-in quicksort)
  2. Return middle element (odd count) or average of two middle elements (even count)
- **Relies on:** Nothing

#### 1.7 Mode (Frequency Counting)
- **Feature:** `mode(data: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Hash table frequency counting
- **Relies on:** Nothing
- **Note:** May not be unique for multimodal data - return first found with highest frequency

#### 1.8 Percentile (Sorted + Interpolation)
- **Feature:** `percentile(data: ARRAY [REAL_64]; p: REAL_64): REAL_64`
- **Algorithm:** Linear interpolation method (NIST R-7)
  1. Sort array
  2. Compute h = (p/100) * (n - 1)
  3. If h is integer, return sorted[h]
  4. Otherwise interpolate between floor(h) and ceil(h)
- **Relies on:** Nothing

#### 1.9 Quartiles (Three Percentiles)
- **Feature:** `quartiles(data: ARRAY [REAL_64]): ARRAY [REAL_64]`
- **Algorithm:** Return array with [Q1 (25th), Q2 (median), Q3 (75th percentile)]
- **Relies on:** percentile

### 2. Correlation & Covariance

#### 2.1 Covariance (Joint Dispersion)
- **Feature:** `covariance(x, y: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Welford's two-pass covariance
- **Relies on:** mean
- **Implementation:** Compute mean_x, mean_y, then sum of (x[i]-mean_x)*(y[i]-mean_y) / n

#### 2.2 Correlation (Normalized Covariance)
- **Feature:** `correlation(x, y: ARRAY [REAL_64]): REAL_64`
- **Algorithm:** Pearson correlation = cov(x,y) / (std_dev(x) * std_dev(y))
- **Relies on:** covariance, std_dev
- **Post-condition:** Result ∈ [-1, 1] (enforced in contract)

### 3. Regression

#### 3.1 Linear Regression (Least Squares via QR)
- **Feature:** `linear_regression(x, y: ARRAY [REAL_64]): REGRESSION_RESULT`
- **Algorithm:** QR decomposition for numerical stability
  1. Build design matrix [1, x[i]] for each point
  2. Compute QR decomposition
  3. Solve R*β = Q^T*y
  4. Extract slope and intercept from β
  5. Compute residuals, R², condition number
- **Relies on:** simple_linalg (or inline QR if simple_linalg not ready)
- **Returns:** REGRESSION_RESULT with slope, intercept, r_squared, residuals, condition_number

### 4. Hypothesis Testing

#### 4.1 One-Sample t-test
- **Feature:** `t_test_one_sample(data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT`
- **Algorithm:**
  1. Compute t = (mean - mu_0) / (std_dev / sqrt(n))
  2. dof = n - 1
  3. Compute p-value from t-distribution with dof degrees of freedom
  4. Create assumption checks for normality (Shapiro-Wilk or Q-Q plot)
- **Relies on:** mean, std_dev, t-distribution quantile function
- **Returns:** TEST_RESULT with statistic, p_value, degrees_of_freedom, assumption_checks

#### 4.2 Two-Sample t-test
- **Feature:** `t_test_two_sample(x, y: ARRAY [REAL_64]): TEST_RESULT`
- **Algorithm:** Welch's t-test (unequal variances)
  1. Compute t = (mean_x - mean_y) / sqrt(var_x/n_x + var_y/n_y)
  2. dof = Welch-Satterthwaite formula
  3. Compute p-value
- **Relies on:** mean, variance
- **Returns:** TEST_RESULT

#### 4.3 Paired t-test
- **Feature:** `t_test_paired(x, y: ARRAY [REAL_64]): TEST_RESULT`
- **Algorithm:**
  1. Compute differences: d[i] = y[i] - x[i]
  2. Apply one-sample t-test on differences
- **Relies on:** t_test_one_sample
- **Returns:** TEST_RESULT

#### 4.4 Chi-Square Goodness-of-Fit
- **Feature:** `chi_square_test(observed, expected: ARRAY [REAL_64]): TEST_RESULT`
- **Algorithm:**
  1. χ² = Σ((observed[i] - expected[i])² / expected[i])
  2. dof = count - 1
  3. Compute p-value from chi-square distribution
- **Relies on:** chi-square quantile function
- **Returns:** TEST_RESULT

#### 4.5 One-Way ANOVA
- **Feature:** `anova(groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT`
- **Algorithm:**
  1. Compute grand mean across all groups
  2. Compute between-group SS and within-group SS
  3. Compute F = (between-SS / (k-1)) / (within-SS / (n-k))
  4. dof_between = k-1, dof_within = n-k
  5. Compute p-value from F-distribution
- **Relies on:** mean, variance
- **Returns:** TEST_RESULT

### 5. Data Cleaning Utility

#### 5.1 CLEANED_STATISTICS
- **Methods:** remove_nan, remove_infinite, clean (both)
- **Algorithm:** Single pass filter creating new array
- **Relies on:** Nothing

### Implementation Order (Dependencies)

**Week 1 (Foundation):**
1. ✓ sum (Kahan summation)
2. ✓ min_value, max_value, range
3. ✓ mean (Welford's)
4. variance (Welford's two-pass)

**Week 2 (Descriptive Stats):**
5. std_dev
6. median (sort + extract)
7. percentile (linear interpolation)
8. quartiles
9. mode (frequency counting)

**Week 3 (Bivariate):**
10. covariance (Welford's two-pass)
11. correlation
12. linear_regression (QR decomposition)

**Week 4 (Hypothesis Testing - Tests):**
13. t_test_one_sample
14. t_test_two_sample
15. t_test_paired
16. chi_square_test
17. anova

**Week 5 (Distribution Functions):**
18. t-distribution CDF/quantile (use built-in or simple_probability)
19. chi-square distribution CDF/quantile
20. F-distribution CDF/quantile

**Week 6 (Utilities + Polish):**
21. CLEANED_STATISTICS methods
22. Assumption checking (Shapiro-Wilk, normality tests)
23. Test polishing, edge cases

## Contract Verification Strategy

### Already Covered by Phase 1 Contracts

✓ **Preconditions (Data Validation):**
- Non-empty arrays
- Same length for paired comparisons
- Sufficient data (n >= 2, n >= 3 for regression)
- Valid parameter ranges (p ∈ [0,100], alpha ∈ (0,1))

✓ **Postconditions (Result Correctness):**
- Return values are finite/valid
- Specific constraints (mean, variance non-negative; correlation ∈ [-1,1]; p-value ∈ [0,1])
- Degrees of freedom match expected formula
- Regression results are reasonable (R² ∈ [0,1])

✓ **Invariants (Object Consistency):**
- TEST_RESULT: p_value ∈ [0,1], dof >= 1
- REGRESSION_RESULT: R² ∈ [0,1], condition_number >= 1.0
- ASSUMPTION_CHECK: name not empty, detail consistency

### MML Readiness

**Not required for Phase 4** because STATISTICS is stateless facade (no collections as attributes).

**For Phase 5+ (if collection-based statistics added):**
- HISTOGRAM class with `values_model: MML_SEQUENCE [INTEGER]`
- DISTRIBUTION class with `samples_model: MML_SEQUENCE [REAL_64]`

## Testing Strategy (Phase 5)

### Unit Tests (TEST_STATISTICS - to flesh out)
- **Descriptive Stats:** Check against known values (mean=3.0 for [1,2,3,4,5])
- **Correlation:** Check known correlation = 1.0 for perfectly correlated data
- **Regression:** Check perfect fit on y=2x data (slope=2, intercept=0)
- **Hypothesis Tests:** Check against statistical tables (SAS output, R output)

### Edge Case Tests
- Single element arrays (should fail precondition)
- Two-element arrays (minimum for correlation)
- All identical values (variance=0, correlation undefined)
- Large datasets (1,000,000+ elements) for numerical stability
- NaN/infinite inputs (should fail precondition or be handled by CLEANED_STATISTICS)

### Numerical Stability Tests
- Compare Kahan vs naive summation on ill-conditioned data
- Compare Welford vs naive variance on large variance ranges
- QR regression vs normal equations on ill-conditioned design matrices

## Configuration & Deployment

### ECF (Already Set Up - Phase 1)
✓ simple_statistics.ecf with targets for library and tests

### Dependencies
✓ simple_math (for mathematical operations - ready)
✓ simple_mml (for MML - ready for future)
- simple_probability (for distribution CDF/quantile - defer to Phase 5)
- simple_linalg (for QR decomposition - use if available, otherwise inline)

### Distribution
- Phase 6: Adversarial tests (edge cases, large data, numerical instability)
- Phase 7: Documentation, examples, GitHub release

## Known Limitations & Assumptions

1. **Arrays only** (no streaming data) - use ARRAY [REAL_64] as primary container
2. **Population statistics** (not sample) - variance is divided by n, not n-1
   - Can add sample_variance, sample_std_dev later if needed
3. **Assumes data are numeric** (REAL_64) - no categorical support
4. **No missing value handling** - CLEANED_STATISTICS provides filtering
5. **Single-threaded** - SCOOP support deferred to Phase 7

## Success Criteria

- [ ] All 20+ features fully implemented
- [ ] All contracts satisfied (zero postcondition violations)
- [ ] Numerical stability tests pass (Kahan vs naive, etc.)
- [ ] 100+ unit tests with coverage > 90%
- [ ] No external library calls except simple_math
- [ ] Performance: mean, variance, correlation on 1M elements < 100ms
