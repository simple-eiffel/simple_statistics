# INTERFACE DESIGN: simple_statistics

## Design Principles

1. **Uniform Access:** Attributes and queries look the same (Eiffel idiom)
2. **Command-Query Separation:** Commands modify state; queries return data without side effects
3. **Fluent Interface:** Methods return `like Current` for chaining
4. **Explicit Over Implicit:** Clear names; no magic behaviors
5. **Composition Over Inheritance:** Facade pattern; no deep class hierarchies

---

## Tier 1 Public API: SIMPLE_STATISTICS

### Creation Interface

```eiffel
create
    make
        -- Create instance ready for use.
        -- No configuration needed; all operations are stateless.

        example:
            stats := create {SIMPLE_STATISTICS}.make
```

**Rationale:** Stateless object; make is simplest creation. No builder pattern needed for v1.0.

### Descriptive Statistics Query Interface

All descriptive statistics are **queries** that take data and return results.

```eiffel
feature -- Descriptive Statistics (Queries)

    mean (data: ARRAY [REAL_64]): REAL_64
            -- Arithmetic mean.

    median (data: ARRAY [REAL_64]): REAL_64
            -- Median (50th percentile).

    mode (data: ARRAY [REAL_64]): REAL_64
            -- Most frequent value.

    variance (data: ARRAY [REAL_64]): REAL_64
            -- Population variance.

    std_dev (data: ARRAY [REAL_64]): REAL_64
            -- Population standard deviation = sqrt(variance).

    percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
            -- p-th percentile (p in [0, 100]).

    quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
            -- Q1, Q2, Q3 as 3-element array.

    min_value (data: ARRAY [REAL_64]): REAL_64
            -- Minimum value.

    max_value (data: ARRAY [REAL_64]): REAL_64
            -- Maximum value.

    range (data: ARRAY [REAL_64]): REAL_64
            -- max - min (spread).

    sum (data: ARRAY [REAL_64]): REAL_64
            -- Sum of all values.

-- Typical usage pattern:
    data := {ARRAY [REAL_64]} <<1.0, 2.0, 3.0, 4.0, 5.0>>
    m := stats.mean (data)
    sd := stats.std_dev (data)
    print ("Mean: " + m.out + ", Std Dev: " + sd.out)
```

**Rationale:**
- All are **queries** (no mutable state; data not modified)
- Take data as parameter (explicit input; no implicit context)
- Return simple REAL_64 or ARRAY [REAL_64] (easy to work with)
- No configuration needed (no builder pattern)

### Relationship Queries

```eiffel
feature -- Correlation & Covariance (Queries)

    correlation (x, y: ARRAY [REAL_64]): REAL_64
            -- Pearson correlation coefficient, r ∈ [-1, 1].
            --
            -- INTERPRETATION:
            -- r = 1: perfect positive relationship
            -- r = 0: no linear relationship
            -- r = -1: perfect negative relationship

    covariance (x, y: ARRAY [REAL_64]): REAL_64
            -- Covariance between x and y.
            --
            -- Related to correlation: cov(x,y) = r * sd(x) * sd(y)

-- Typical usage:
    r := stats.correlation (age_data, income_data)
    if r > 0.7 then
        print ("Strong positive relationship")
    end
```

**Rationale:**
- Both are pure queries (same input → same output)
- Symmetric (order doesn't matter for correlation)
- Return scalar results (simple to use)

### Regression Query

```eiffel
feature -- Regression (Query returning result object)

    linear_regression (x, y: ARRAY [REAL_64]): REGRESSION_RESULT
            -- Ordinary least squares regression fit.
            -- Returns model with slope, intercept, R², residuals, diagnostics.
            --
            -- INTERPRETATION:
            -- slope: change in y per unit change in x
            -- intercept: predicted y when x = 0
            -- r_squared: proportion of variance explained [0, 1]
            -- condition_number: numerical stability (< 1e12 is good)

-- Typical usage:
    model := stats.linear_regression (height, weight)
    print ("Weight = " + model.slope.out + " * Height + " + model.intercept.out)
    print ("R² = " + model.r_squared.out)  -- 0.72 = 72% variance explained
    predicted_weight := model.predict (new_height)
```

**Rationale:**
- Returns **rich result object** (not tuple)
- Result is **immutable** (SCOOP-safe)
- Result has **methods** (predict, is_numerically_stable)
- Result is **self-documenting** (fields have clear names)

### Hypothesis Testing Queries

```eiffel
feature -- Hypothesis Testing (Queries returning TEST_RESULT)

    t_test_one_sample (data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT
            -- One-sample t-test: H₀: μ = mu_0.
            --
            -- USE WHEN: Testing if sample mean differs from theoretical value.
            --
            -- EXAMPLE:
            -- H₀: "This machine is calibrated to 100mL"
            -- H₁: "Actual mean ≠ 100mL"
            -- result := t_test_one_sample (measurements, 100.0)
            -- if result.is_significant (0.05) then
            --     print ("Machine is out of calibration")
            -- end

    t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Two-sample t-test: H₀: μ₁ = μ₂.
            --
            -- USE WHEN: Comparing means of two independent groups.
            --
            -- EXAMPLE:
            -- before_treatment := {ARRAY [REAL_64]} <<values>>
            -- after_treatment := {ARRAY [REAL_64]} <<values>>
            -- result := t_test_two_sample (before_treatment, after_treatment)
            -- if result.conclusion (0.05) then
            --     print ("Treatment is significant")
            -- end

    t_test_paired (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Paired t-test: H₀: μ_diff = 0.
            --
            -- USE WHEN: Comparing two measurements on same subjects.

    chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
            -- Chi-square goodness-of-fit: H₀: data follows expected distribution.
            --
            -- USE WHEN: Testing categorical data against expected frequencies.

    anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
            -- One-way ANOVA: H₀: all group means are equal.
            --
            -- USE WHEN: Comparing 3+ groups simultaneously.

-- Typical usage pattern:
    result := stats.t_test_two_sample (group1, group2)

    -- Automatic interpretation
    if result.is_significant (0.05) then
        print ("Reject null hypothesis: groups differ significantly")
    else
        print ("Fail to reject null hypothesis: groups don't differ")
    end

    -- Manual interpretation with p-value
    print ("t-statistic: " + result.statistic.out)
    print ("p-value: " + result.p_value.out)
    print ("d.o.f.: " + result.degrees_of_freedom.out)

    -- Publication format
    print (result.format_for_publication ("t-test"))
    -- Output: "t(48) = 2.45, p = .018"
```

**Rationale:**
- All are **queries** (compute result; no state change)
- Return **TEST_RESULT** (not tuple; not bare p-value)
- TEST_RESULT has:
  - **Accessor methods:** statistic, p_value, degrees_of_freedom
  - **Interpretation methods:** conclusion(α), is_significant(α)
  - **Formatting methods:** format_for_publication()
  - **Assumption checks:** assumption_checks.for_all(...)
- Enables readable code (result.is_significant vs result[1] < 0.05)

---

## Tier 2 Public API

### ROBUST_STATISTICS Interface

```eiffel
class ROBUST_STATISTICS

create
    make

feature -- Robust Measures

    trimmed_mean (data: ARRAY [REAL_64]; trim_fraction: REAL_64): REAL_64
            -- Mean excluding top and bottom trim_fraction of values.
            --
            -- WHEN TO USE: Data has outliers but you want central tendency.
            -- EXAMPLE: trim_fraction = 0.1 → exclude top/bottom 10%
            --
            -- ADVANTAGES: Resistant to outliers (vs mean).

    mad (data: ARRAY [REAL_64]): REAL_64
            -- Median Absolute Deviation: robust measure of spread.
            --
            -- WHEN TO USE: Data has outliers but you want spread measure.
            --
            -- ADVANTAGES: Resistant to outliers (vs std_dev).

    outliers_by_iqr (data: ARRAY [REAL_64]; multiplier: REAL_64 := 1.5): ARRAY [INTEGER]
            -- Indices of outliers using Interquartile Range method.
            -- Outlier if value > Q3 + multiplier * IQR or < Q1 - multiplier * IQR.
            --
            -- DEFAULT: multiplier = 1.5 (Tukey's boxplot definition).
            -- CONSERVATIVE: multiplier = 3.0 (stricter outlier definition).

    outliers_by_zscore (data: ARRAY [REAL_64]; threshold: REAL_64 := 3.0): ARRAY [INTEGER]
            -- Indices of outliers using Z-score method.
            -- Outlier if |z| > threshold.
            --
            -- TYPICAL: threshold = 2.0 (95% under normal curve)
            --          threshold = 3.0 (99.7% under normal curve)

-- Typical usage:
    outlier_indices := robust.outliers_by_iqr (data)
    print ("Found " + outlier_indices.count.out + " outliers")
    across outlier_indices as idx loop
        print ("  Value at index " + idx + " is outlier")
    end
```

### EFFECT_SIZES Interface

```eiffel
class EFFECT_SIZES

create
    make

feature -- Effect Size Measures

    cohens_d (group1, group2: ARRAY [REAL_64]): REAL_64
            -- Cohen's d: standardized mean difference.
            -- d = (mean₁ - mean₂) / pooled_std
            --
            -- INTERPRETATION:
            -- |d| < 0.2: negligible
            -- |d| < 0.5: small
            -- |d| < 0.8: medium
            -- |d| ≥ 0.8: large

    eta_squared (groups: ARRAY [ARRAY [REAL_64]]): REAL_64
            -- Eta-squared: proportion of variance explained by group membership.
            -- η² ∈ [0, 1]
            --
            -- INTERPRETATION:
            -- η² = 0.01: small effect
            -- η² = 0.06: medium effect
            -- η² = 0.14: large effect

    cramers_v (contingency_table: ARRAY [ARRAY [INTEGER]]): REAL_64
            -- Cramér's V: association strength in contingency table.
            -- V ∈ [0, 1]
            --
            -- INTERPRETATION:
            -- V < 0.1: weak association
            -- V < 0.3: moderate association
            -- V ≥ 0.3: strong association
```

### DISTRIBUTION_TESTS Interface

```eiffel
class DISTRIBUTION_TESTS

create
    make

feature -- Distribution Tests

    shapiro_wilk (data: ARRAY [REAL_64]): TEST_RESULT
            -- Shapiro-Wilk test for normality.
            --
            -- H₀: Data is normally distributed.
            -- TYPICAL USE: Check if data satisfies t-test assumption.
            --
            -- POWER: Good at detecting departures from normality.
            -- LIMITATION: Very sensitive with large n (might reject true normality).

    anderson_darling (data: ARRAY [REAL_64]): TEST_RESULT
            -- Anderson-Darling test for normality (alternative to Shapiro-Wilk).

    ks_test (data: ARRAY [REAL_64]; reference_mean, reference_std: REAL_64): TEST_RESULT
            -- Kolmogorov-Smirnov test vs normal distribution.
            --
            -- H₀: Data follows normal distribution with given mean/std.
```

### NONPARAMETRIC_TESTS Interface

```eiffel
class NONPARAMETRIC_TESTS

create
    make

feature -- Non-Parametric Tests

    mann_whitney_u (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Mann-Whitney U test: non-parametric alternative to two-sample t-test.
            --
            -- H₀: Two groups have same distribution (not necessarily same mean).
            -- USE WHEN: t-test assumptions violated (non-normal data, outliers).
            -- POWER: Slightly lower than t-test if data is normal.
            -- ROBUSTNESS: Better with non-normal data, outliers.

    wilcoxon_signed_rank (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Wilcoxon signed-rank test: non-parametric paired test.
            --
            -- H₀: Paired differences have median = 0.
            -- USE WHEN: Paired data is non-normal.
            -- ALTERNATIVE TO: Paired t-test.

    kruskal_wallis (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
            -- Kruskal-Wallis test: non-parametric alternative to ANOVA.
            --
            -- H₀: All groups have same distribution.
            -- USE WHEN: ANOVA assumptions violated (non-normal, unequal variance).
            -- ADVANTAGE: Works with ordinal data (e.g., rankings, Likert scales).
```

### ADVANCED_REGRESSION Interface

```eiffel
class ADVANCED_REGRESSION

create
    make

feature -- Advanced Regression Methods

    weighted_least_squares (x, y, weights: ARRAY [REAL_64]): REGRESSION_RESULT
            -- Weighted OLS regression: each point has different weight.
            --
            -- USE WHEN: Some observations are more reliable than others.
            -- EXAMPLE: weights = 1/measurement_error for each point.

    ridge_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
            -- Ridge regression: OLS with L2 regularization.
            --
            -- lambda: regularization strength (0 = OLS, ∞ = all slopes → 0).
            -- USE WHEN: Multicollinearity present (X'X ill-conditioned).

    lasso_regression (x, y: ARRAY [REAL_64]; lambda: REAL_64): REGRESSION_RESULT
            -- Lasso regression: OLS with L1 regularization.
            --
            -- lambda: regularization strength.
            -- ADVANTAGE: Shrinks some slopes exactly to 0 (feature selection).
```

---

## Error Handling Interface

### Precondition Violations

When preconditions are violated, Eiffel raises **DBC exceptions**:

```eiffel
-- This violates precondition (empty array)
stats.mean ({ARRAY [REAL_64]} <<>>)
-- Raises: PRECONDITION_VIOLATED
-- Message: "data_not_empty: not data.is_empty"

-- This violates precondition (contains NaN)
stats.mean ({ARRAY [REAL_64]} <<1.0, (0.0/0.0)>>)  -- NaN
-- Raises: PRECONDITION_VIOLATED
-- Message: "data_has_no_nan: data.for_all(...)"
```

**User Experience:**
- Clear error message (shows which precondition failed)
- Stack trace points to user's code (where invalid data was passed)
- Forces data validation BEFORE calling library functions

### Suggested Handling Pattern

```eiffel
-- BAD: Will crash with precondition violation
result := stats.mean (user_data)

-- BETTER: Validate first
if not user_data.is_empty and user_data_has_no_nan then
    result := stats.mean (user_data)
else
    print ("Invalid data: empty or contains NaN")
end

-- BEST: Use CLEANED_STATISTICS utility
cleaned_stats := create {CLEANED_STATISTICS}.make
clean_data := cleaned_stats.remove_nan (user_data)
if not clean_data.is_empty then
    result := stats.mean (clean_data)
end
```

---

## Command-Query Separation

| Feature | Type | Modifies State? | Returns? |
|---------|------|-----------------|----------|
| mean() | Query | NO | REAL_64 |
| correlation() | Query | NO | REAL_64 |
| linear_regression() | Query | NO | REGRESSION_RESULT |
| t_test_one_sample() | Query | NO | TEST_RESULT |
| make | Command | YES (creates object) | self |

**Principle:** All statistical operations are **queries** (pure functions). No hidden state changes.

---

## Fluent API (Chaining) - Future Enhancement

v1.0 doesn't use fluent API, but design preserves it for future:

```eiffel
-- v1.1 potential: fluent filter pattern (not in v1.0)
clean_stats := cleaned_stats
    .remove_nan (data)
    .remove_outliers_by_iqr

-- v1.0 approach: explicit steps
clean_data := cleaned_stats.remove_nan (data)
stats.mean (clean_data)
```

---

## Result Object Interface

### TEST_RESULT Usage Patterns

```eiffel
result := stats.t_test_two_sample (before, after)

-- Pattern 1: Simple significance check
if result.is_significant (0.05) then
    -- Reject null hypothesis
end

-- Pattern 2: Manual interpretation
if result.p_value < 0.05 then
    -- Significant at 5% level
end

-- Pattern 3: Report with effect size
print (result.format_for_publication ("t-test"))
-- Output: "t(98) = 2.45, p = .018"

-- Pattern 4: Check assumptions
across result.assumption_checks as check loop
    if not check.passed then
        print ("Warning: " + check.name + " failed - " + check.detail)
    end
end

-- Pattern 5: Access raw values
print ("Test statistic: " + result.statistic.out)
print ("p-value: " + result.p_value.out)
print ("degrees of freedom: " + result.degrees_of_freedom.out)
```

### REGRESSION_RESULT Usage Patterns

```eiffel
model := stats.linear_regression (predictors, response)

-- Pattern 1: Access model parameters
print ("Equation: y = " + model.slope.out + "*x + " + model.intercept.out)

-- Pattern 2: Check model fit
print ("R²: " + model.r_squared.out)  -- Proportion of variance explained
if model.r_squared < 0.5 then
    print ("Warning: Model explains < 50% of variance")
end

-- Pattern 3: Check numerical stability
if not model.is_numerically_stable then
    print ("Warning: Condition number = " + model.condition_number.out)
    print ("Results may be unreliable")
end

-- Pattern 4: Make predictions
new_x := 25.0
predicted_y := model.predict (new_x)
print ("When x = " + new_x.out + ", predicted y = " + predicted_y.out)

-- Pattern 5: Analyze residuals
across model.residuals as residual loop
    if residual.abs > 2.0 then
        print ("Large residual: " + residual.out)
    end
end
```

---

**Status:** INTERFACE DESIGN COMPLETE
