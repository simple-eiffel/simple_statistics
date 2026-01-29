# SPECIFICATION: simple_statistics

## Library Overview

**Name:** simple_statistics

**Purpose:** Type-safe, contract-based statistical library for the Simple Eiffel ecosystem. Fills the gap left by no existing Eiffel statistical library while providing differentiators (Design by Contract, typed results, SCOOP-ready) that Python's SciPy and R cannot match.

**Version:** 1.0 (Tier 1 + Tier 2)

**Target Users:**
- Data scientists analyzing mid-size datasets (n < 100,000)
- Researchers needing rigorous statistical testing with type safety
- Quality assurance engineers validating processes with statistics
- Financial analysts computing risk metrics
- Eiffel developers requiring statistical capabilities

**Ecosystem Role:** Composition with simple_probability (distributions), simple_linalg (matrix operations), simple_calculus (integration).

---

## Core Classes

### SIMPLE_STATISTICS (Tier 1 Facade)

```eiffel
note
    description: "Core statistical operations for descriptive analysis, correlation, regression, and hypothesis testing."
    author: "Simple Eiffel Team"
    license: "MIT"

class SIMPLE_STATISTICS

create
    make

feature -- Initialization
    make
        -- Create instance. Stateless; no configuration needed.
        do
        ensure
            instance_created: True
        end

feature -- Descriptive Statistics (11 features)
    mean (data: ARRAY [REAL_64]): REAL_64
        -- Arithmetic mean using numerically stable summation.
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
            data_has_no_infinity: data.for_all (agent (x) do Result := not x.is_infinite end)
        ensure
            result_finite: Result.is_finite
        end

    median (data: ARRAY [REAL_64]): REAL_64
        -- Middle value (50th percentile).
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
        ensure
            result_in_range: Result >= data.min and Result <= data.max
        end

    mode (data: ARRAY [REAL_64]): REAL_64
        -- Most frequent value (may not be unique for multimodal data).
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
        ensure
            result_in_data: data.has (Result)
        end

    variance (data: ARRAY [REAL_64]): REAL_64
        -- Population variance using Welford's algorithm (numerically stable).
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
        ensure
            result_non_negative: Result >= 0.0
        end

    std_dev (data: ARRAY [REAL_64]): REAL_64
        -- Standard deviation = sqrt(variance).
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
        ensure
            result_non_negative: Result >= 0.0
        end

    percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
        -- p-th percentile where p ∈ [0, 100].
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
            percentile_valid: p >= 0.0 and p <= 100.0
        ensure
            result_in_range: Result >= data.min and Result <= data.max
        end

    quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
        -- Q1, Q2 (median), Q3 as array of 3 values.
        require
            data_not_empty: not data.is_empty
            data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
            sufficient_data: data.count >= 4
        ensure
            result_size: Result.count = 3
            ordered: Result [1] <= Result [2] and Result [2] <= Result [3]
        end

    min_value, max_value, range, sum
        -- Other descriptive statistics (details in feature list above).

feature -- Correlation & Covariance (2 features)
    correlation (x, y: ARRAY [REAL_64]): REAL_64
        -- Pearson correlation coefficient ∈ [-1, 1].
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty
            sufficient_data: x.count >= 2
        ensure
            result_in_range: Result >= -1.0 - 1e-10 and Result <= 1.0 + 1e-10
        end

    covariance (x, y: ARRAY [REAL_64]): REAL_64
        -- Covariance between x and y.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty
            sufficient_data: x.count >= 2
        ensure
            result_finite: Result.is_finite
        end

feature -- Regression (1 feature)
    linear_regression (x, y: ARRAY [REAL_64]): REGRESSION_RESULT
        -- Ordinary least squares regression using QR decomposition (numerically stable).
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty
            sufficient_data: x.count >= 3
        ensure
            result_valid: Result /= Void
            r2_valid: Result.r_squared >= 0.0 and Result.r_squared <= 1.0
        end

feature -- Hypothesis Testing (5 features)
    t_test_one_sample (data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT
        -- One-sample t-test: H₀: μ = mu_0.
        require
            data_valid: not data.is_empty
            sufficient_data: data.count >= 2
            mu_0_valid: not mu_0.is_nan and not mu_0.is_infinite
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
            dof_correct: Result.degrees_of_freedom = data.count - 1
        end

    t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
        -- Two-sample t-test: H₀: μ₁ = μ₂.
        require
            data_valid: not x.is_empty and not y.is_empty
            sufficient_data: x.count >= 2 and y.count >= 2
        ensure
            result_valid: Result /= Void
            dof_correct: Result.degrees_of_freedom = x.count + y.count - 2
        end

    t_test_paired (x, y: ARRAY [REAL_64]): TEST_RESULT
        -- Paired t-test: H₀: μ_diff = 0.
        require
            same_length: x.count = y.count
            data_valid: not x.is_empty and not y.is_empty
            sufficient_data: x.count >= 2
        ensure
            result_valid: Result /= Void
            dof_correct: Result.degrees_of_freedom = x.count - 1
        end

    chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
        -- Chi-square goodness-of-fit test.
        require
            same_length: observed.count = expected.count
            data_valid: not observed.is_empty
            all_positive: expected.for_all (agent (x) do Result := x > 0.0 end)
        ensure
            result_valid: Result /= Void
            dof_correct: Result.degrees_of_freedom = observed.count - 1
        end

    anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
        -- One-way ANOVA: H₀: all group means equal.
        require
            sufficient_groups: groups.count >= 3
            all_non_empty: groups.for_all (agent (g) do Result := not g.is_empty end)
        ensure
            result_valid: Result /= Void
            p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
        end

invariant
    -- Stateless: no invariant on object state
    instance_valid: True

end
```

### TEST_RESULT (Immutable Data Class)

```eiffel
note
    description: "Immutable result of hypothesis test with significance testing and formatting."

class TEST_RESULT

create
    make

feature -- Access
    statistic: REAL_64
        -- Test statistic (t, F, χ², U, etc.).

    p_value: REAL_64
        -- p-value: P(test statistic | H₀ true).

    degrees_of_freedom: INTEGER
        -- Degrees of freedom for test.

    assumption_checks: ARRAY [ASSUMPTION_CHECK]
        -- Documentation of test assumptions.

feature -- Interpretation
    conclusion (alpha: REAL_64): BOOLEAN
        -- Is H₀ rejected at significance level alpha?
        -- True = significant; reject H₀
        -- False = not significant; fail to reject H₀
        require
            alpha_valid: alpha > 0.0 and alpha < 1.0
        ensure
            result_defined: Result = (p_value < alpha)
        end

    is_significant (alpha: REAL_64 := 0.05): BOOLEAN
        -- Alias for conclusion (alpha).
        require
            alpha_valid: alpha > 0.0 and alpha < 1.0
        ensure
            result_defined: Result = conclusion (alpha)
        end

feature -- Formatting
    format_for_publication (test_name: STRING): STRING
        -- Format as "name(df) = stat, p = .xxx" for academic publication.
        require
            test_name_valid: not test_name.is_empty
        ensure
            result_valid: not Result.is_empty
        end

feature {NONE} -- Creation
    make (a_stat: REAL_64; a_p: REAL_64; a_dof: INTEGER; a_checks: ARRAY [ASSUMPTION_CHECK])
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

### REGRESSION_RESULT (Immutable Data Class)

```eiffel
note
    description: "Immutable result of regression analysis with diagnostics and prediction."

class REGRESSION_RESULT

create
    make

feature -- Model Parameters
    slope: REAL_64
        -- Regression coefficient (change in y per unit change in x).

    intercept: REAL_64
        -- y-intercept (predicted y when x = 0).

    r_squared: REAL_64
        -- Coefficient of determination: proportion of variance explained.

feature -- Diagnostics
    residuals: ARRAY [REAL_64]
        -- Differences: observed_y - predicted_y.

    condition_number: REAL_64
        -- Condition number of design matrix; measure of numerical stability.
        -- κ < 10: excellent; κ < 1e12: acceptable; κ > 1e12: ill-conditioned.

feature -- Prediction & Validation
    predict (x: REAL_64): REAL_64
        -- Predict y for given x using fitted model.
        require
            x_valid: not x.is_nan and not x.is_infinite
        ensure
            result_finite: Result.is_finite
        end

    is_numerically_stable: BOOLEAN
        -- Is condition number < 1e12 (acceptable)?
        do
            Result := condition_number < 1e12
        end

feature {NONE} -- Creation
    make (a_slope: REAL_64; a_intercept: REAL_64; a_r2: REAL_64;
          a_residuals: ARRAY [REAL_64]; a_condition: REAL_64)
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
    r_squared_valid: r_squared >= 0.0 and r_squared <= 1.0 + 1e-10
    slopes_finite: slope.is_finite and intercept.is_finite
    condition_positive: condition_number >= 1.0

end
```

### ASSUMPTION_CHECK (Immutable Data Class)

```eiffel
note
    description: "Document single assumption validation for hypothesis test."

class ASSUMPTION_CHECK

create
    make

feature -- Access
    name: STRING
        -- Assumption name (e.g., "normality", "equal_variance").

    passed: BOOLEAN
        -- Was assumption satisfied?

    detail: STRING
        -- Explanation if failed; empty if passed.

feature {NONE} -- Creation
    make (a_name: STRING; a_passed: BOOLEAN; a_detail: STRING)
        do
            name := a_name
            passed := a_passed
            detail := a_detail
        ensure
            name_set: name = a_name
            passed_set: passed = a_passed
        end

invariant
    name_non_empty: not name.is_empty
    detail_consistency: (not passed) implies (not detail.is_empty)

end
```

---

## Tier 2 Classes (v1.0)

### ROBUST_STATISTICS
```eiffel
class ROBUST_STATISTICS
create make
feature
    trimmed_mean (data: ARRAY [REAL_64]; trim_fraction: REAL_64): REAL_64
    mad (data: ARRAY [REAL_64]): REAL_64
    outliers_by_iqr (data: ARRAY [REAL_64]; multiplier: REAL_64): ARRAY [INTEGER]
    outliers_by_zscore (data: ARRAY [REAL_64]; threshold: REAL_64): ARRAY [INTEGER]
end
```

### EFFECT_SIZES
```eiffel
class EFFECT_SIZES
create make
feature
    cohens_d (group1, group2: ARRAY [REAL_64]): REAL_64
    eta_squared (groups: ARRAY [ARRAY [REAL_64]]): REAL_64
    cramers_v (contingency_table: ARRAY [ARRAY [INTEGER]]): REAL_64
end
```

### DISTRIBUTION_TESTS
```eiffel
class DISTRIBUTION_TESTS
create make
feature
    shapiro_wilk (data: ARRAY [REAL_64]): TEST_RESULT
    anderson_darling (data: ARRAY [REAL_64]): TEST_RESULT
    ks_test (data: ARRAY [REAL_64]; mean, std: REAL_64): TEST_RESULT
end
```

### NONPARAMETRIC_TESTS
```eiffel
class NONPARAMETRIC_TESTS
create make
feature
    mann_whitney_u (x, y: ARRAY [REAL_64]): TEST_RESULT
    wilcoxon_signed_rank (x, y: ARRAY [REAL_64]): TEST_RESULT
    kruskal_wallis (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
end
```

### ADVANCED_REGRESSION
```eiffel
class ADVANCED_REGRESSION
create make
feature
    weighted_least_squares (x, y, weights: ARRAY [REAL_64]): REGRESSION_RESULT
    ridge_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
    lasso_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
end
```

### CLEANED_STATISTICS (Utility)
```eiffel
class CLEANED_STATISTICS
create make
feature
    remove_nan (data: ARRAY [REAL_64]): ARRAY [REAL_64]
    remove_infinite (data: ARRAY [REAL_64]): ARRAY [REAL_64]
    clean (data: ARRAY [REAL_64]): ARRAY [REAL_64]
end
```

---

## Dependencies

| Library | Purpose | Version | Usage |
|---------|---------|---------|-------|
| simple_math | Basic math functions (min, max, sort) | 1.0+ | Tier 1: sorting for percentiles |
| simple_probability | Distribution functions (CDF, quantile) | 1.0+ | Tier 3 only; p-value computation |
| simple_linalg | Matrix operations for regression | 1.0+ | Tier 1: QR decomposition for regression |
| simple_calculus | Numerical integration | 1.0+ | Future: distribution moment computation |
| EiffelStudio Base | Eiffel standard library | 25.02+ | Arrays, sorting, agents |

---

## File Structure

```
simple_statistics.ecf              -- Eiffel Configuration File
├── src/
│   ├── simple_statistics.e         -- Tier 1 Facade
│   ├── test_result.e               -- Test result object
│   ├── regression_result.e         -- Regression result object
│   ├── assumption_check.e          -- Assumption documentation
│   ├── robust_statistics.e         -- Tier 2: Robust measures
│   ├── effect_sizes.e              -- Tier 2: Effect sizes
│   ├── distribution_tests.e        -- Tier 2: Distribution testing
│   ├── nonparametric_tests.e       -- Tier 2: Non-parametric tests
│   ├── advanced_regression.e       -- Tier 2: Advanced regression
│   └── cleaned_statistics.e        -- Utility: NaN cleaning
├── test/
│   ├── test_app.e                  -- Test runner
│   ├── test_simple_statistics.e    -- Tier 1 unit tests
│   ├── test_results.e              -- Result class tests
│   ├── test_robust_statistics.e    -- Tier 2 unit tests
│   └── ... (150+ additional test files)
└── docs/
    ├── index.md                    -- Documentation landing page
    ├── getting_started.md          -- Tutorial for Tier 1
    ├── api_reference.md            -- Full API documentation
    ├── algorithms.md               -- Algorithm explanations
    ├── tier_2_guide.md             -- Advanced features guide
    └── examples/                   -- 20+ working examples
        ├── descriptive_statistics.e
        ├── t_test_example.e
        └── ...
```

---

## Key Design Features Implemented

✓ **Design by Contract:** Full preconditions, postconditions, invariants on all public features
✓ **Type Safety:** void_safety="all"; ARRAY [REAL_64] input; typed result objects
✓ **Numerical Stability:** Welford's algorithm for variance; QR for regression; condition checking
✓ **SCOOP Ready:** Immutable result objects; no shared mutable state
✓ **Tier-Based API:** SIMPLE_STATISTICS for 80% of users; Tier 2 classes for advanced users
✓ **Ecosystem Integration:** Composition with simple_probability, simple_linalg, simple_calculus
✓ **Educational Value:** Built-in assumption documentation; when/how to use guidance
✓ **Strict Data Validation:** NaN/infinity rejection; CLEANED_STATISTICS utility for convenience

---

**Status:** SPECIFICATION SYNTHESIZED COMPLETE
