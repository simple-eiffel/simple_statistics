# REQUIREMENTS: simple_statistics

## Functional Requirements

### Tier 1 (Simple - Core Statistics)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T1-001 | Compute arithmetic mean of dataset | MUST | mean([1,2,3]) = 2.0 |
| FR-T1-002 | Compute median (middle value) | MUST | median([1,2,3,4,5]) = 3 |
| FR-T1-003 | Compute mode (most frequent value) | MUST | mode([1,1,2,3]) = 1 |
| FR-T1-004 | Compute variance (spread) | MUST | variance([1,2,3]) = 1.0 |
| FR-T1-005 | Compute standard deviation | MUST | std_dev([1,2,3]) ≈ 1.0 |
| FR-T1-006 | Compute quartiles (Q1, Q2, Q3) | MUST | quartiles([1..100]) returns 3 values |
| FR-T1-007 | Compute arbitrary percentiles | MUST | percentile([1..100], 75) ≈ 75 |
| FR-T1-008 | Compute min, max, range | MUST | min/max/range work for any ordered set |
| FR-T1-009 | Compute sum of dataset | MUST | sum([1,2,3]) = 6 |
| FR-T1-010 | Pearson correlation coefficient | MUST | correlation(x, y) in [-1, 1] |
| FR-T1-011 | Covariance between two variables | MUST | covariance(x, y) numeric |
| FR-T1-012 | Linear regression (OLS) | MUST | Fit line y = mx + b to points |
| FR-T1-013 | R² (coefficient of determination) | MUST | r_squared in [0, 1] |
| FR-T1-014 | One-sample t-test | MUST | Test if mean = μ₀; return t-statistic, p-value |
| FR-T1-015 | Two-sample t-test | MUST | Test if mean₁ = mean₂; return t, p-value |
| FR-T1-016 | Paired t-test | MUST | Test if mean(diff) = 0; return t, p-value |
| FR-T1-017 | Chi-square goodness-of-fit | MUST | Test categorical distribution; return χ², p-value |
| FR-T1-018 | ANOVA (Analysis of Variance) | MUST | Test if >2 groups have same mean; return F, p-value |
| FR-T1-019 | Handle missing data (NaN) | SHOULD | Skip NaN values; or use imputation |
| FR-T1-020 | Handle empty dataset | MUST | Raise exception with clear message |

---

### Tier 2 (Advanced - Robust & Distribution Testing)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T2-001 | Trimmed mean | SHOULD | Mean excluding top/bottom k% |
| FR-T2-002 | Median absolute deviation (MAD) | SHOULD | Robust spread measure |
| FR-T2-003 | Outlier detection (IQR method) | SHOULD | Identify points > Q3 + 1.5×IQR |
| FR-T2-004 | Outlier detection (Z-score) | SHOULD | Flag points where \|z\| > 3 |
| FR-T2-005 | Cohen's d (effect size) | SHOULD | Standardized mean difference |
| FR-T2-006 | Eta-squared (effect size) | SHOULD | Proportion of variance explained |
| FR-T2-007 | Cramér's V (association) | SHOULD | Strength of categorical association |
| FR-T2-008 | Shapiro-Wilk test (normality) | SHOULD | Test if data is normally distributed |
| FR-T2-009 | Anderson-Darling test | SHOULD | Alternative normality test |
| FR-T2-010 | Kolmogorov-Smirnov test | SHOULD | Test against reference distribution |
| FR-T2-011 | Mann-Whitney U test | SHOULD | Non-parametric alternative to t-test |
| FR-T2-012 | Wilcoxon signed-rank test | SHOULD | Non-parametric paired test |
| FR-T2-013 | Kruskal-Wallis test | SHOULD | Non-parametric ANOVA |
| FR-T2-014 | Weighted least squares | SHOULD | Regression with per-point weights |
| FR-T2-015 | Ridge regression | SHOULD | Regression with L2 regularization |
| FR-T2-016 | Lasso regression | SHOULD | Regression with L1 regularization |
| FR-T2-017 | Skewness | SHOULD | Measure asymmetry of distribution |
| FR-T2-018 | Kurtosis | SHOULD | Measure tail behavior |
| FR-T2-019 | Multiple testing correction | SHOULD | Bonferroni, FDR, Holm methods |

---

### Tier 3 (Expert - Custom & Advanced)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T3-001 | Compute p-value from t-statistic | COULD | Use t-distribution CDF from simple_probability |
| FR-T3-002 | Compute critical value | COULD | Inverse CDF for given significance level |
| FR-T3-003 | Custom hypothesis test framework | COULD | Test infrastructure for user-defined tests |
| FR-T3-004 | Bootstrap resampling | COULD | Generate confidence intervals via resampling |
| FR-T3-005 | Permutation testing | COULD | Non-parametric alternative to t-test |
| FR-T3-006 | Bayesian credible intervals | COULD | For future v1.2 release |

---

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | Language version | TECHNICAL | EiffelStudio version | 25.02+ |
| NFR-002 | Type safety | TECHNICAL | void_safety setting | void_safety="all" |
| NFR-003 | Design by Contract | TECHNICAL | Assertion coverage | 100% public features |
| NFR-004 | SCOOP compatibility | CONCURRENCY | Immutable results | All return types immutable |
| NFR-005 | Numerical stability | ACCURACY | Condition number | Check and warn if > 1e12 |
| NFR-006 | Performance (descriptive) | SPEED | Time complexity | O(n) for mean, variance |
| NFR-007 | Performance (percentiles) | SPEED | Time complexity | O(n log n) via sorting |
| NFR-008 | Performance (regression) | SPEED | Time complexity | O(n²) for OLS with n < 100k |
| NFR-009 | Test coverage | TESTING | Code coverage | > 95% for v1.0 |
| NFR-010 | Test count | TESTING | Unit tests | 300+ for comprehensive coverage |
| NFR-011 | Documentation | DOCUMENTATION | User guide | 50+ pages with examples |
| NFR-012 | Examples | DOCUMENTATION | Code examples | 20+ runnable examples |
| NFR-013 | Algorithm explanation | DOCUMENTATION | Theory reference | Each algorithm documented with formula |
| NFR-014 | API stability | COMPATIBILITY | Semantic versioning | Follow SEMVER |
| NFR-015 | Backward compatibility | COMPATIBILITY | v1.0+ | API frozen; deprecate gracefully |
| NFR-016 | Dependency stability | ECOSYSTEM | Upgrade frequency | Coordinate with simple_* maintainers |

---

## Constraints (Non-Negotiable)

| ID | Constraint | Type | Immutable? | Rationale |
|----|-----------|------|-----------|-----------|
| C-001 | Must be SCOOP-compatible | TECHNICAL | YES | Eiffel concurrency standard |
| C-002 | Must use void_safety="all" | TECHNICAL | YES | Type safety requirement |
| C-003 | Must have Design by Contract | TECHNICAL | YES | Eiffel ecosystem standard |
| C-004 | Must prefer simple_* over ISE | ECOSYSTEM | YES | Align with Simple Eiffel philosophy |
| C-005 | Must handle NaN/Inf gracefully | TECHNICAL | YES | IEEE 754 standard |
| C-006 | Must not depend on external libraries | TECHNICAL | MOSTLY | Exception: simple_probability, simple_linalg, simple_calculus |
| C-007 | Must maintain REAL_64 precision | TECHNICAL | YES | Double precision standard |
| C-008 | Must be open source (MIT or GPL) | LEGAL | YES | Simple Eiffel ecosystem standard |

---

## API Architecture (Tier-Based)

### Tier 1: Simple Statistics (SIMPLE_STATISTICS class)

```eiffel
class SIMPLE_STATISTICS

feature -- Tier 1: Descriptive Statistics
  mean (data: ARRAY [REAL_64]): REAL_64
  median (data: ARRAY [REAL_64]): REAL_64
  variance (data: ARRAY [REAL_64]): REAL_64
  std_dev (data: ARRAY [REAL_64]): REAL_64
  percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64

feature -- Tier 1: Correlation & Regression
  correlation (x, y: ARRAY [REAL_64]): REAL_64
  covariance (x, y: ARRAY [REAL_64]): REAL_64
  linear_regression (x, y: ARRAY [REAL_64]): REGRESSION_RESULT

feature -- Tier 1: Hypothesis Testing
  t_test_one_sample (data: ARRAY [REAL_64]; μ0: REAL_64): TEST_RESULT
  t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
  chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
  anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT

end
```

### Tier 2: Advanced Statistics (Separate classes)

```eiffel
class ROBUST_STATISTICS
  trimmed_mean (data: ARRAY [REAL_64]; trim_fraction: REAL_64): REAL_64
  mad (data: ARRAY [REAL_64]): REAL_64
  outliers_iqr (data: ARRAY [REAL_64]): ARRAY [INTEGER]

class EFFECT_SIZES
  cohens_d (x, y: ARRAY [REAL_64]): REAL_64
  eta_squared (groups: ARRAY [ARRAY [REAL_64]]): REAL_64
  cramers_v (contingency_table: ARRAY [ARRAY [INTEGER]]): REAL_64

class DISTRIBUTION_TESTS
  shapiro_wilk (data: ARRAY [REAL_64]): TEST_RESULT
  anderson_darling (data: ARRAY [REAL_64]): TEST_RESULT
  ks_test (data: ARRAY [REAL_64]; dist: DISTRIBUTION): TEST_RESULT

class NONPARAMETRIC_TESTS
  mann_whitney_u (x, y: ARRAY [REAL_64]): TEST_RESULT
  wilcoxon_signed_rank (x, y: ARRAY [REAL_64]): TEST_RESULT
  kruskal_wallis (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT

class ADVANCED_REGRESSION
  weighted_ls (x, y, weights: ARRAY [REAL_64]): REGRESSION_RESULT
  ridge_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
  lasso_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
```

### Result Types (Type-Safe, Immutable)

```eiffel
class REGRESSION_RESULT
  slope: REAL_64
  intercept: REAL_64
  r_squared: REAL_64
  residuals: ARRAY [REAL_64]
  predict (x: REAL_64): REAL_64

class TEST_RESULT
  statistic: REAL_64
  p_value: REAL_64
  degrees_of_freedom: INTEGER
  conclusion (α: REAL_64): BOOLEAN  -- true if reject null hypothesis
  assumption_checks: ARRAY [ASSUMPTION_CHECK]

class ASSUMPTION_CHECK
  name: STRING
  passed: BOOLEAN
  detail: STRING
```

---

## Data Input/Output

**Input:** ARRAY [REAL_64] (standard Eiffel array type)

**Output:** Typed result objects (not tuples or untyped returns)

**Null Handling:**
- NaN values: Skip with warning, or raise exception (configurable)
- Empty arrays: Raise precondition violation with EMPTY_DATASET exception
- Missing data: Document requirement for complete data

---

**Status:** REQUIREMENTS COMPLETE - Ready for DECISIONS research
