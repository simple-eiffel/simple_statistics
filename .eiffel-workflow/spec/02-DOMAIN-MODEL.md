# DOMAIN MODEL: simple_statistics

## Domain Concepts

### Concept: Dataset
**Definition:** An ordered collection of numeric values (ARRAY [REAL_64]) representing observations
**Attributes:**
- values: ARRAY [REAL_64]
- count: INTEGER (length of array)
- is_empty: BOOLEAN
- contains_nan: BOOLEAN
**Behaviors:**
- Validate (no NaN, non-empty)
- Iterate over values
- Sort values
- Index into values
**Related to:** Descriptive Statistics, Hypothesis Test
**Will become:** Input validation logic in preconditions; no separate class needed

### Concept: Descriptive Statistic
**Definition:** A single numeric summary of a dataset (e.g., mean, variance, percentile)
**Attributes:**
- value: REAL_64
- name: STRING (e.g., "mean", "median")
- degrees_of_freedom: INTEGER (if applicable)
**Behaviors:**
- Compute from dataset
- Return numeric result
- Validate result is in expected range
**Related to:** Dataset
**Will become:** Methods on SIMPLE_STATISTICS class (not separate classes)

### Concept: Correlation & Covariance
**Definition:** Relationship strength between two datasets
**Attributes:**
- coefficient: REAL_64 (correlation ∈ [-1, 1]; covariance can be any value)
- variable_1_name: STRING
- variable_2_name: STRING
**Behaviors:**
- Compute from two datasets
- Validate same length
- Validate correlation in [-1, 1]
**Related to:** Dataset (2 of them)
**Will become:** Methods on SIMPLE_STATISTICS class

### Concept: Regression Model
**Definition:** Linear relationship fit to paired datasets (y = mx + b)
**Attributes:**
- slope: REAL_64
- intercept: REAL_64
- r_squared: REAL_64 (proportion of variance explained)
- residuals: ARRAY [REAL_64] (differences between observed and predicted)
- prediction_std_error: REAL_64
**Behaviors:**
- Fit model to (x, y) data
- Validate input data (same length, no NaN, n ≥ 2)
- Predict y for new x
- Validate R² ∈ [0, 1]
**Related to:** Dataset (x and y)
**Will become:** REGRESSION_RESULT class with predict(x) method

### Concept: Hypothesis Test
**Definition:** Statistical test comparing sample data to null hypothesis
**Attributes:**
- test_statistic: REAL_64 (t, F, χ², U, etc.)
- p_value: REAL_64 (probability of observing data under null hypothesis)
- degrees_of_freedom: INTEGER
- assumptions: ARRAY [ASSUMPTION_CHECK]
**Behaviors:**
- Compute test statistic and p-value from dataset(s)
- Validate p_value ∈ [0, 1]
- Validate d.o.f ≥ 1
- Determine if null hypothesis is rejected (conclusion method)
- Check test assumptions
**Related to:** Dataset (1 or more), Test Assumptions
**Will become:** TEST_RESULT class with conclusion(α) and assumption_checks()

### Concept: Test Assumption
**Definition:** Condition that must be true for test to be valid
**Attributes:**
- name: STRING (e.g., "normality", "equal_variance")
- satisfied: BOOLEAN
- details: STRING (explanation if not satisfied)
**Behaviors:**
- Store assumption check result
- Report violation clearly
- Suggest alternatives if violated
**Related to:** Hypothesis Test
**Will become:** ASSUMPTION_CHECK class within TEST_RESULT

### Concept: Effect Size
**Definition:** Magnitude of difference between groups (standardized)
**Attributes:**
- value: REAL_64 (Cohen's d, eta-squared, Cramér's V, etc.)
- measure_name: STRING
- interpretation: STRING (e.g., "small", "medium", "large")
**Behaviors:**
- Compute from group data
- Validate in expected range
- Classify magnitude (small/medium/large)
**Related to:** Dataset (multiple groups)
**Will become:** Methods on EFFECT_SIZES class

### Concept: Robust Statistic
**Definition:** Statistic resistant to outliers (trimmed mean, MAD, etc.)
**Attributes:**
- value: REAL_64
- method_name: STRING
- outliers_removed_count: INTEGER
**Behaviors:**
- Compute from dataset
- Handle outliers explicitly
- Validate value is reasonable
**Related to:** Dataset
**Will become:** Methods on ROBUST_STATISTICS class

### Concept: Distribution Test
**Definition:** Test whether data follows a theoretical distribution
**Attributes:**
- test_statistic: REAL_64
- p_value: REAL_64
- reference_distribution: STRING (normal, uniform, etc.)
**Behaviors:**
- Test normality (Shapiro-Wilk, Anderson-Darling, KS)
- Compute p-value for goodness-of-fit
- Validate assumptions
**Related to:** Hypothesis Test, Dataset
**Will become:** Methods on DISTRIBUTION_TESTS class

### Concept: Non-Parametric Test
**Definition:** Hypothesis test without distribution assumptions
**Attributes:**
- test_statistic: REAL_64 (U, W, H, etc.)
- p_value: REAL_64
- ranks_or_counts: ARRAY [INTEGER]
**Behaviors:**
- Compute test statistic from ranks or counts
- Alternative when parametric assumptions fail
- Often more robust to outliers
**Related to:** Hypothesis Test
**Will become:** Methods on NONPARAMETRIC_TESTS class

## Concept Relationships

```
┌──────────────────────────────────────────────────────────────┐
│                       SIMPLE_STATISTICS                      │
│                      (Facade/Coordinator)                    │
└──────────────────────────────────────────────────────────────┘
           ↓                      ↓                       ↓
   ┌─────────────┐    ┌──────────────────┐    ┌──────────────┐
   │  Descriptive │    │  Correlation &   │    │ Regression & │
   │ Statistics   │    │   Covariance     │    │   Prediction │
   └─────────────┘    └──────────────────┘    └──────────────┘
           ↓
   ┌────────────────────────────────────────────────────────────┐
   │          Hypothesis Testing Infrastructure                │
   ├────────────────────────────────────────────────────────────┤
   │  ┌─────────────────┬────────────────┬──────────────────┐  │
   │  │ Parametric Tests│ Distribution   │ Non-Parametric  │  │
   │  │ (t, F, χ²)      │ Tests (SW, AD) │ (U, W, H)        │  │
   │  └─────────────────┴────────────────┴──────────────────┘  │
   │         ↓              ↓                  ↓                │
   │    TEST_RESULT with ASSUMPTION_CHECKs & conclusion(α)    │
   └────────────────────────────────────────────────────────────┘

Tier 2 Extensions:
   ┌──────────────┐  ┌─────────────┐  ┌──────────────────┐
   │   Robust     │  │  Effect     │  │    Advanced      │
   │ Statistics   │  │  Sizes      │  │   Regression     │
   └──────────────┘  └─────────────┘  └──────────────────┘
```

## Domain Rules

| Rule ID | Description | Enforcement | Design Location |
|---------|-------------|-------------|-----------------|
| DR-001 | All datasets must be non-empty | Precondition on all functions | Contracts on public methods |
| DR-002 | All datasets must not contain NaN | Precondition on all functions | Contracts on public methods |
| DR-003 | Correlation must be in [-1, 1] | Postcondition, invariant | TEST_RESULT/correlation result validation |
| DR-004 | p-value must be in [0, 1] | Postcondition, invariant | TEST_RESULT invariant |
| DR-005 | R² must be in [0, 1] | Postcondition, invariant | REGRESSION_RESULT invariant |
| DR-006 | Degrees of freedom ≥ 1 | Postcondition | TEST_RESULT invariant |
| DR-007 | Test statistics must be finite | Postcondition | TEST_RESULT invariant |
| DR-008 | Standard deviation ≥ 0 | Postcondition | Descriptive stat validation |
| DR-009 | Variance ≥ 0 | Postcondition | Descriptive stat validation |
| DR-010 | Two-dataset functions require same length | Precondition | Correlation, covariance, paired tests |
| DR-011 | Regression requires n ≥ 2 | Precondition | linear_regression precondition |
| DR-012 | Paired t-test requires n ≥ 2 | Precondition | t_test_paired precondition |
| DR-013 | ANOVA requires ≥ 3 groups | Precondition | anova precondition |
| DR-014 | Chi-square requires observed/expected same length | Precondition | chi_square_test precondition |
| DR-015 | Result objects are immutable | Invariant (no setters) | CLASS definitions (no feature assignments) |
| DR-016 | Outlier detection thresholds are documented | Documentation | Inline comments in implementations |
| DR-017 | Condition number > 1e12 triggers warning | Postcondition | regression_result.condition_number_warning |
| DR-018 | Algorithms documented with rationale | Documentation | Feature comments explain Welford, QR, etc. |

## Glossary

| Term | Definition |
|------|------------|
| **Precondition** | What must be true before a function executes |
| **Postcondition** | What is guaranteed true after a function completes |
| **Invariant** | What is always true while an object exists |
| **Design by Contract** | Formal agreements between client and provider (Eiffel core) |
| **Degrees of freedom** | Number of independent values in a calculation (n-1 for t-test) |
| **p-value** | Probability of observing test statistic under null hypothesis |
| **Effect size** | Magnitude of difference between groups (standardized) |
| **Assumption check** | Validation that test prerequisites are met |
| **Robust statistic** | Statistic resistant to outliers (median, MAD, trimmed mean) |
| **Non-parametric test** | Hypothesis test without distribution assumptions |
| **Numerical stability** | Algorithm produces correct results even with edge-case data |
| **Condition number** | Measure of sensitivity to input perturbation (regression health) |
| **Immutable** | Object cannot be modified after creation |
| **Welford's algorithm** | Numerically stable method for computing variance |
| **QR decomposition** | Numerically stable matrix factorization for regression |
| **SCOOP** | Eiffel's concurrency mechanism (Simple Concurrent Object-Oriented Programming) |

## Concept Hierarchy Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIER 1: SIMPLE_STATISTICS                    │
│              (Entry point for 80% of users)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Descriptive Stats        Correlation & Covariance             │
│  ├─ mean                  ├─ correlation(x, y)                │
│  ├─ median                └─ covariance(x, y)                 │
│  ├─ mode                                                       │
│  ├─ variance              Linear Regression                    │
│  ├─ std_dev               └─ linear_regression(x, y)          │
│  ├─ percentile               → REGRESSION_RESULT              │
│  ├─ quartiles                                                  │
│  └─ range, min, max       Hypothesis Testing                  │
│                           ├─ t_test_one_sample()              │
│                           ├─ t_test_two_sample()              │
│                           ├─ t_test_paired()                  │
│                           ├─ chi_square_test()                │
│                           ├─ anova()                          │
│                           └─ → TEST_RESULT                    │
│                                                                 │
│  Result Types:                                                  │
│  ├─ TEST_RESULT (immutable): statistic, p_value, d.o.f        │
│  │  └─ conclusion(α): BOOLEAN                                 │
│  └─ REGRESSION_RESULT (immutable): slope, intercept, r²       │
│     └─ predict(x): REAL_64                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────────┐
│          TIER 2: Advanced Classes (15% of users)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ROBUST_STATISTICS        EFFECT_SIZES                         │
│  ├─ trimmed_mean          ├─ cohens_d                         │
│  ├─ mad                    ├─ eta_squared                      │
│  └─ outliers_iqr/zscore   └─ cramers_v                        │
│                                                                 │
│  DISTRIBUTION_TESTS       NONPARAMETRIC_TESTS                 │
│  ├─ shapiro_wilk          ├─ mann_whitney_u                   │
│  ├─ anderson_darling      ├─ wilcoxon_signed_rank             │
│  └─ ks_test               └─ kruskal_wallis                   │
│                                                                 │
│  ADVANCED_REGRESSION                                           │
│  ├─ weighted_ls                                                │
│  ├─ ridge_regression                                           │
│  └─ lasso_regression                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────────┐
│      TIER 3: Expert Features (5% of users, v1.1+)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Custom Hypothesis Tests   Bootstrap Resampling                │
│  Custom test framework     Confidence intervals                │
│  p-value computation       Permutation testing                 │
│                                                                 │
│  Bayesian Inference (v1.2+)                                    │
│  Credible intervals                                             │
│  Posterior inference                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

**Status:** DOMAIN MODEL COMPLETE
