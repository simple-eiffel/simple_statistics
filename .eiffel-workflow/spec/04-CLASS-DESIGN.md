# CLASS DESIGN: simple_statistics

## Class Inventory

### Tier 1 Classes (v1.0)

| Class | Role | Single Responsibility |
|-------|------|----------------------|
| SIMPLE_STATISTICS | Facade | Coordinate all Tier 1 statistical operations |
| TEST_RESULT | Data | Immutable result of hypothesis test |
| REGRESSION_RESULT | Data | Immutable result of linear regression |
| ASSUMPTION_CHECK | Data | Document single assumption validation |

### Tier 2 Classes (v1.0)

| Class | Role | Single Responsibility |
|-------|------|----------------------|
| ROBUST_STATISTICS | Facade | Robust statistical operations (trimmed mean, MAD, outliers) |
| EFFECT_SIZES | Facade | Compute effect size measures (Cohen's d, eta², V) |
| DISTRIBUTION_TESTS | Facade | Test distribution assumptions (Shapiro-Wilk, AD, KS) |
| NONPARAMETRIC_TESTS | Facade | Non-parametric alternatives (Mann-Whitney U, Wilcoxon, KW) |
| ADVANCED_REGRESSION | Facade | Advanced regression methods (weighted, ridge, lasso) |

### Utility Classes (v1.0)

| Class | Role | Single Responsibility |
|-------|------|----------------------|
| CLEANED_STATISTICS | Utility | Remove NaN from arrays before analysis |

---

## Facade Design: SIMPLE_STATISTICS

**Purpose:** Single entry point for core statistical operations
**Responsibility:** Coordinate descriptive statistics, correlation, regression, and basic hypothesis testing
**Design Pattern:** Facade (simplifies interface to complex subsystem)

### Class Structure

```eiffel
class SIMPLE_STATISTICS

create
    make

feature -- Initialization

    make
            -- Create instance.
        do
        ensure
            instance_created: True
        end

feature -- Descriptive Statistics

    mean (data: ARRAY [REAL_64]): REAL_64
            -- Arithmetic mean of `data`.
            -- Uses numerically stable summation.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_finite: Result.is_finite
        end

    median (data: ARRAY [REAL_64]): REAL_64
            -- Middle value (50th percentile) of `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_in_range: Result >= data.min and Result <= data.max
        end

    mode (data: ARRAY [REAL_64]): REAL_64
            -- Most frequent value in `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_in_data: data.has (Result)
        end

    variance (data: ARRAY [REAL_64]): REAL_64
            -- Population variance (sum of squared deviations / n).
            -- Uses Welford's algorithm for numerical stability.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_non_negative: Result >= 0.0
        end

    std_dev (data: ARRAY [REAL_64]): REAL_64
            -- Standard deviation (sqrt of variance).
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_non_negative: Result >= 0.0
        end

    percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
            -- `p`-th percentile of `data` (p in [0, 100]).
        require
            data_valid: not data.is_empty and data_has_no_nan
            percentile_valid: p >= 0.0 and p <= 100.0
        ensure
            result_in_range: Result >= data.min and Result <= data.max
        end

    quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
            -- Q1, Q2 (median), Q3 as 3-element array.
        require
            data_valid: not data.is_empty and data_has_no_nan
            sufficient_data: data.count >= 4  -- Need at least 4 points for quartiles
        ensure
            result_size: Result.count = 3
            q1_q2_q3_sorted: Result [1] <= Result [2] and Result [2] <= Result [3]
        end

    min_value (data: ARRAY [REAL_64]): REAL_64
            -- Minimum value in `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            is_minimum: data.for_all (agent (x) do Result := x >= Result end)
        end

    max_value (data: ARRAY [REAL_64]): REAL_64
            -- Maximum value in `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            is_maximum: data.for_all (agent (x) do Result := x <= Result end)
        end

    range (data: ARRAY [REAL_64]): REAL_64
            -- max - min of `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_non_negative: Result >= 0.0
        end

    sum (data: ARRAY [REAL_64]): REAL_64
            -- Sum of all values in `data`.
        require
            data_valid: not data.is_empty and data_has_no_nan
        ensure
            result_finite: Result.is_finite
        end

feature -- Correlation & Covariance

    correlation (x, y: ARRAY [REAL_64]): REAL_64
            -- Pearson correlation coefficient (Pearson's r).
            -- Result in [-1, 1]; -1 perfect negative, 0 no relationship, 1 perfect positive.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty and x_has_no_nan and y_has_no_nan
            sufficient_data: x.count >= 2
        ensure
            result_in_range: Result >= -1.0 - 1e-10 and Result <= 1.0 + 1e-10  -- Allow floating-point tolerance
        end

    covariance (x, y: ARRAY [REAL_64]): REAL_64
            -- Covariance between `x` and `y`.
            -- Positive: positive relationship; negative: negative relationship.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty and x_has_no_nan and y_has_no_nan
            sufficient_data: x.count >= 2
        ensure
            result_finite: Result.is_finite
        end

feature -- Regression

    linear_regression (x, y: ARRAY [REAL_64]): REGRESSION_RESULT
            -- Fit linear model y = slope*x + intercept using OLS.
            -- Uses QR decomposition for numerical stability.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty and x_has_no_nan and y_has_no_nan
            sufficient_data: x.count >= 2
        ensure
            result_valid: Result /= Void
        end

feature -- Hypothesis Testing

    t_test_one_sample (data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT
            -- One-sample t-test: H₀: μ = mu_0.
            -- Tests if sample mean is significantly different from mu_0.
        require
            data_valid: not data.is_empty and data_has_no_nan
            sufficient_data: data.count >= 2
            mu_0_valid: not mu_0.is_nan and not mu_0.is_infinite
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_valid: Result.degrees_of_freedom = data.count - 1
        end

    t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Two-sample t-test: H₀: μ₁ = μ₂.
            -- Tests if two groups have significantly different means.
            -- Assumes equal variances.
        require
            data_valid: not x.is_empty and not y.is_empty and x_has_no_nan and y_has_no_nan
            sufficient_data: x.count >= 2 and y.count >= 2
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_valid: Result.degrees_of_freedom = x.count + y.count - 2
        end

    t_test_paired (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Paired t-test: H₀: μ_diff = 0.
            -- Tests if paired differences have mean significantly different from 0.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty and x_has_no_nan and y_has_no_nan
            sufficient_data: x.count >= 2
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_valid: Result.degrees_of_freedom = x.count - 1
        end

    chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
            -- Chi-square goodness-of-fit test: H₀: data follows expected distribution.
            -- Tests if observed frequencies match expected.
        require
            same_length: observed.count = expected.count
            data_valid: not observed.is_empty and not expected.is_empty
            no_nan: observed_has_no_nan and expected_has_no_nan
            all_non_negative: observed.for_all (agent (x) do Result := x >= 0.0 end)
                and expected.for_all (agent (x) do Result := x > 0.0 end)
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_valid: Result.degrees_of_freedom = observed.count - 1
        end

    anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
            -- One-way ANOVA: H₀: all group means are equal.
            -- Tests if ≥3 groups have significantly different means.
        require
            sufficient_groups: groups.count >= 3
            all_non_empty: groups.for_all (agent (g) do Result := not g.is_empty end)
            all_valid: groups.for_all (agent (g) do Result := g_has_no_nan (g) end)
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_valid: Result.degrees_of_freedom >= 1
        end

feature {NONE} -- Implementation Helper Contracts

    data_has_no_nan (arr: ARRAY [REAL_64]): BOOLEAN
            -- True if array contains no NaN values.
        do
            Result := arr.for_all (agent (x) do Result := not x.is_nan end)
        end

    x_has_no_nan: BOOLEAN
            -- True if external x contains no NaN.
        do
            Result := True  -- Overridden in implementation
        end

    y_has_no_nan: BOOLEAN
            -- True if external y contains no NaN.
        do
            Result := True  -- Overridden in implementation
        end

    observed_has_no_nan: BOOLEAN
            -- True if external observed contains no NaN.
        do
            Result := True  -- Overridden in implementation
        end

    expected_has_no_nan: BOOLEAN
            -- True if external expected contains no NaN.
        do
            Result := True  -- Overridden in implementation
        end

    g_has_no_nan (g: ARRAY [REAL_64]): BOOLEAN
            -- True if group g contains no NaN.
        do
            Result := g.for_all (agent (x) do Result := not x.is_nan end)
        end

invariant
    -- Class has no mutable state; all operations are pure
    instance_valid: True

end
```

---

## Result Classes

### TEST_RESULT (Immutable)

```eiffel
class TEST_RESULT

create
    make

feature -- Access

    statistic: REAL_64
            -- Test statistic value (t, F, χ², U, etc.).

    p_value: REAL_64
            -- p-value: probability of observing statistic under H₀.

    degrees_of_freedom: INTEGER
            -- Degrees of freedom for the test.

    assumption_checks: ARRAY [ASSUMPTION_CHECK]
            -- Validation of test assumptions.

feature -- Queries

    conclusion (alpha: REAL_64): BOOLEAN
            -- Is null hypothesis rejected at significance level `alpha`?
            -- True means reject H₀ (result is significant).
        require
            alpha_valid: alpha > 0.0 and alpha < 1.0
        ensure
            result_defined: Result = (p_value < alpha)
        end

    is_significant (alpha: REAL_64 := 0.05): BOOLEAN
            -- Alias for conclusion.
        require
            alpha_valid: alpha > 0.0 and alpha < 1.0
        ensure
            result_defined: Result = conclusion (alpha)
        end

    format_for_publication (test_name: STRING): STRING
            -- Format result for academic publication (e.g., "t(98)=2.34, p=.022").
        require
            test_name_valid: not test_name.is_empty
        ensure
            result_valid: not Result.is_empty
        end

feature {NONE} -- Creation

    make (a_stat: REAL_64; a_p: REAL_64; a_dof: INTEGER; a_checks: ARRAY [ASSUMPTION_CHECK])
            -- Create test result.
        require
            p_valid: a_p >= 0.0 and a_p <= 1.0
            dof_valid: a_dof >= 1
            stat_finite: a_stat.is_finite
        do
            statistic := a_stat
            p_value := a_p
            degrees_of_freedom := a_dof
            assumption_checks := a_checks
        ensure
            statistic_set: statistic = a_stat
            p_value_set: p_value = a_p
            dof_set: degrees_of_freedom = a_dof
        end

invariant
    p_value_valid: p_value >= 0.0 and p_value <= 1.0
    dof_valid: degrees_of_freedom >= 1
    statistic_finite: statistic.is_finite

end
```

### REGRESSION_RESULT (Immutable)

```eiffel
class REGRESSION_RESULT

create
    make

feature -- Access

    slope: REAL_64
            -- Regression coefficient for predictor variable.

    intercept: REAL_64
            -- Regression intercept (y-value when x=0).

    r_squared: REAL_64
            -- Coefficient of determination; proportion of variance explained.

    residuals: ARRAY [REAL_64]
            -- Differences between observed and predicted y values.

    condition_number: REAL_64
            -- Condition number of design matrix; measure of numerical stability.
            -- Values > 1e12 indicate ill-conditioned problem.

feature -- Queries

    predict (x: REAL_64): REAL_64
            -- Predicted y value for given x using fitted model.
        require
            x_valid: not x.is_nan and not x.is_infinite
        ensure
            result_finite: Result.is_finite
        end

    is_numerically_stable: BOOLEAN
            -- Is condition number acceptable (< 1e12)?
        do
            Result := condition_number < 1e12
        ensure
            result_defined: Result = (condition_number < 1e12)
        end

feature {NONE} -- Creation

    make (a_slope: REAL_64; a_intercept: REAL_64; a_r2: REAL_64;
          a_residuals: ARRAY [REAL_64]; a_condition: REAL_64)
            -- Create regression result.
        require
            r2_valid: a_r2 >= 0.0 and a_r2 <= 1.0
            slopes_finite: a_slope.is_finite and a_intercept.is_finite
            condition_non_negative: a_condition >= 1.0
        do
            slope := a_slope
            intercept := a_intercept
            r_squared := a_r2
            residuals := a_residuals
            condition_number := a_condition
        ensure
            slope_set: slope = a_slope
            intercept_set: intercept = a_intercept
            r2_set: r_squared = a_r2
        end

invariant
    r_squared_valid: r_squared >= 0.0 and r_squared <= 1.0
    slopes_finite: slope.is_finite and intercept.is_finite
    condition_positive: condition_number >= 1.0

end
```

### ASSUMPTION_CHECK (Immutable)

```eiffel
class ASSUMPTION_CHECK

create
    make

feature -- Access

    name: STRING
            -- Name of assumption (e.g., "normality", "equal_variance").

    passed: BOOLEAN
            -- Was assumption satisfied?

    detail: STRING
            -- Explanation if assumption failed; empty if passed.

feature {NONE} -- Creation

    make (a_name: STRING; a_passed: BOOLEAN; a_detail: STRING)
        require
            name_valid: not a_name.is_empty
        do
            name := a_name
            passed := a_passed
            detail := a_detail
        ensure
            name_set: name = a_name
            passed_set: passed = a_passed
        end

invariant
    name_valid: not name.is_empty
    detail_consistency: (not passed) implies (not detail.is_empty)

end
```

---

## Facade Designs: Tier 2 Classes

### ROBUST_STATISTICS

```eiffel
class ROBUST_STATISTICS

create
    make

feature -- Robust Measures

    trimmed_mean (data: ARRAY [REAL_64]; trim_fraction: REAL_64): REAL_64
            -- Mean excluding top and bottom `trim_fraction` of values.
            -- `trim_fraction` in [0, 0.5]; 0.1 = exclude top/bottom 10%.

    mad (data: ARRAY [REAL_64]): REAL_64
            -- Median Absolute Deviation: robust measure of spread.

    outliers_by_iqr (data: ARRAY [REAL_64]; multiplier: REAL_64 := 1.5): ARRAY [INTEGER]
            -- Indices of outliers using IQR method.
            -- Outlier if value > Q3 + multiplier×IQR.

    outliers_by_zscore (data: ARRAY [REAL_64]; threshold: REAL_64 := 3.0): ARRAY [INTEGER]
            -- Indices of outliers using Z-score method.
            -- Outlier if |z| > threshold.

end
```

### EFFECT_SIZES

```eiffel
class EFFECT_SIZES

create
    make

feature -- Effect Size Measures

    cohens_d (group1, group2: ARRAY [REAL_64]): REAL_64
            -- Cohen's d: standardized mean difference.

    eta_squared (groups: ARRAY [ARRAY [REAL_64]]): REAL_64
            -- Eta-squared: proportion of variance explained by groups.

    cramers_v (contingency_table: ARRAY [ARRAY [INTEGER]]): REAL_64
            -- Cramér's V: association strength in contingency table.

end
```

### DISTRIBUTION_TESTS

```eiffel
class DISTRIBUTION_TESTS

create
    make

feature -- Distribution Tests

    shapiro_wilk (data: ARRAY [REAL_64]): TEST_RESULT
            -- Shapiro-Wilk test for normality.

    anderson_darling (data: ARRAY [REAL_64]): TEST_RESULT
            -- Anderson-Darling test for normality.

    ks_test (data: ARRAY [REAL_64]; reference_mean, reference_std: REAL_64): TEST_RESULT
            -- Kolmogorov-Smirnov test vs normal distribution.

end
```

### NONPARAMETRIC_TESTS

```eiffel
class NONPARAMETRIC_TESTS

create
    make

feature -- Non-Parametric Tests

    mann_whitney_u (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Mann-Whitney U test: non-parametric alternative to t-test.

    wilcoxon_signed_rank (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Wilcoxon signed-rank test: non-parametric paired test.

    kruskal_wallis (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
            -- Kruskal-Wallis test: non-parametric alternative to ANOVA.

end
```

### ADVANCED_REGRESSION

```eiffel
class ADVANCED_REGRESSION

create
    make

feature -- Advanced Regression

    weighted_least_squares (x, y, weights: ARRAY [REAL_64]): REGRESSION_RESULT
            -- Weighted OLS regression with per-point weights.

    ridge_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
            -- Ridge regression with L2 regularization parameter lambda.

    lasso_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
            -- Lasso regression with L1 regularization parameter lambda.

end
```

---

## Utility Class

### CLEANED_STATISTICS

```eiffel
class CLEANED_STATISTICS

feature -- Data Cleaning

    remove_nan (data: ARRAY [REAL_64]): ARRAY [REAL_64]
            -- Return array with all NaN values removed.
        require
            input_valid: not data.is_empty
        ensure
            result_valid: not result_has_nan (Result)
            result_size: Result.count <= data.count
        end

    remove_infinite (data: ARRAY [REAL_64]): ARRAY [REAL_64]
            -- Return array with all infinite values removed.

    clean (data: ARRAY [REAL_64]): ARRAY [REAL_64]
            -- Remove all NaN and infinite values.

feature {NONE} -- Helper

    result_has_nan (arr: ARRAY [REAL_64]): BOOLEAN
        do
            Result := arr.for_all (agent (x) do Result := not x.is_nan end)
        end

end
```

---

## Inheritance Hierarchy

SIMPLE_STATISTICS, ROBUST_STATISTICS, EFFECT_SIZES, DISTRIBUTION_TESTS, NONPARAMETRIC_TESTS, ADVANCED_REGRESSION: All are standalone facades with no inheritance. No IS-A relationships needed for v1.0.

TEST_RESULT, REGRESSION_RESULT, ASSUMPTION_CHECK: All are data classes with no inheritance.

**Rationale:** Favor composition and facade pattern over inheritance. Each class has single responsibility with no IS-A relationships.

---

## Class Diagram

```
┌──────────────────────────────────────┐
│      SIMPLE_STATISTICS               │
│      (Facade)                        │
├──────────────────────────────────────┤
│ + mean(data): REAL_64                │
│ + median(data): REAL_64              │
│ + variance(data): REAL_64            │
│ + std_dev(data): REAL_64             │
│ + percentile(data, p): REAL_64       │
│ + correlation(x, y): REAL_64         │
│ + linear_regression(x,y): REG_RESULT │
│ + t_test_one_sample(): TEST_RESULT   │
│ + t_test_two_sample(): TEST_RESULT   │
│ + anova(groups): TEST_RESULT         │
└────────────┬────────────────────────┘
             │ produces
             ├──────────────────────┬───────────────────────┐
             ▼                      ▼                       ▼
    ┌─────────────────┐   ┌──────────────────┐   ┌─────────────────┐
    │  TEST_RESULT    │   │ REGRESSION_RESULT│   │ ASSUMPTION_CHECK│
    ├─────────────────┤   ├──────────────────┤   ├─────────────────┤
    │ + statistic     │   │ + slope          │   │ + name          │
    │ + p_value       │   │ + intercept      │   │ + passed        │
    │ + degrees_of_f  │   │ + r_squared      │   │ + detail        │
    │ + assumption_.. │   │ + residuals      │   └─────────────────┘
    │ + conclusion(α) │   │ + predict(x)     │
    │ + is_significant│   │ + is_num_stable  │
    └─────────────────┘   └──────────────────┘

Tier 2 Facades:
  ROBUST_STATISTICS
  EFFECT_SIZES
  DISTRIBUTION_TESTS
  NONPARAMETRIC_TESTS
  ADVANCED_REGRESSION

Utility:
  CLEANED_STATISTICS
```

---

**Status:** CLASS DESIGN COMPLETE
