# CONTRACT DESIGN: simple_statistics

## Contract Philosophy

**Goal:** Make contracts executable specifications that:
1. Document what's guaranteed to work (preconditions)
2. Document what will be true after execution (postconditions)
3. Document invariants (always true for the object)
4. Enable automated verification and testing

**Principle:** Contracts are not just error-checking; they're part of the API specification.

---

## Precondition Contracts (REQUIRE)

### Data Validity Contracts

All functions operating on data have these preconditions:

```eiffel
require
    data_not_empty: not data.is_empty
        -- Cannot compute statistics on empty dataset
    data_has_no_nan: data.for_all (agent (x) do Result := not x.is_nan end)
        -- All values must be valid numbers (not NaN)
    data_has_no_infinity: data.for_all (agent (x) do Result := not x.is_infinite end)
        -- All values must be finite (not ±∞)
```

### Two-Variable Function Contracts

Functions like correlation(x, y) require:

```eiffel
require
    same_length: x.count = y.count
        -- Both arrays must have same number of observations
    x_valid: not x.is_empty and x_has_no_nan and x_has_no_infinity
        -- x must be valid data
    y_valid: not y.is_empty and y_has_no_nan and y_has_no_infinity
        -- y must be valid data
    minimum_observations: x.count >= 2
        -- Need at least 2 paired observations for correlation
```

### Parameter Validation Contracts

```eiffel
require
    percentile_valid: percentile >= 0.0 and percentile <= 100.0
        -- Percentile must be between 0 and 100

    alpha_valid: alpha > 0.0 and alpha < 1.0
        -- Significance level must be between 0 and 1

    trim_fraction_valid: trim_fraction >= 0.0 and trim_fraction < 0.5
        -- Can't trim more than 50% (must have data left)

    lambda_non_negative: lambda >= 0.0
        -- Regularization parameter must be non-negative
```

### Sufficient Data Contracts

```eiffel
require
    sufficient_data: data.count >= 2
        -- Need at least 2 observations for descriptive statistics

    sufficient_for_variance: data.count >= 1
        -- Variance can be computed with 1 observation (result = 0)

    sufficient_for_regression: x.count >= 3
        -- Need at least 3 points to fit regression (2 determine line, 1 for testing)

    sufficient_for_anova: groups.count >= 3
        -- ANOVA requires at least 3 groups

    sufficient_for_confidence: observed.count >= 2
        -- Chi-square needs at least 2 categories
```

---

## Postcondition Contracts (ENSURE)

### Range Contracts

```eiffel
ensure
    correlation_in_range: Result >= -1.0 - 1e-10 and Result <= 1.0 + 1e-10
        -- Correlation must be between -1 and 1 (with floating-point tolerance)

    r_squared_in_range: Result.r_squared >= 0.0 and Result.r_squared <= 1.0 + 1e-10
        -- R² is between 0 and 1

    p_value_in_range: Result.p_value >= 0.0 and Result.p_value <= 1.0
        -- p-value is between 0 and 1

    variance_non_negative: Result >= 0.0
        -- Variance is always non-negative

    std_dev_non_negative: Result >= 0.0
        -- Standard deviation is always non-negative
```

### Finitude Contracts

```eiffel
ensure
    result_finite: Result.is_finite
        -- Result is a valid number (not NaN or ±∞)

    all_results_finite: Result.for_all (agent (x) do Result := x.is_finite end)
        -- All elements of result array are valid numbers

    slope_finite: Result.slope.is_finite
    intercept_finite: Result.intercept.is_finite
    residuals_finite: Result.residuals.for_all (agent (x) do Result := x.is_finite end)
        -- All regression components are finite
```

### Degrees of Freedom Contracts

```eiffel
ensure
    dof_correct_one_sample: Result.degrees_of_freedom = data.count - 1
        -- One-sample t-test: d.o.f. = n - 1

    dof_correct_two_sample: Result.degrees_of_freedom = x.count + y.count - 2
        -- Two-sample t-test: d.o.f. = n₁ + n₂ - 2

    dof_correct_chi_square: Result.degrees_of_freedom = observed.count - 1
        -- Chi-square: d.o.f. = k - 1 (k categories)

    dof_at_least_one: Result.degrees_of_freedom >= 1
        -- d.o.f. must be at least 1
```

### Logical Contracts

```eiffel
ensure
    conclusion_matches_p_value: Result.conclusion (0.05) = (Result.p_value < 0.05)
        -- conclusion(α) must match p-value < α

    is_significant_default: Result.is_significant = Result.conclusion (0.05)
        -- is_significant uses default α = 0.05

    prediction_uses_model: Result.predict (0.0) = Result.intercept
        -- At x=0, prediction should equal intercept
```

### Frame Conditions (What Didn't Change)

```eiffel
ensure
    input_unchanged: x.deep_equal (old x.twin)
        -- Input array was not modified

    only_result_changed: -- Internal state doesn't leak to caller
        -- Function is pure; no side effects on global state
```

### Relationship Contracts

```eiffel
ensure
    median_in_range: Result >= data.min and Result <= data.max
        -- Median must be between min and max

    percentile_in_data_range: Result >= data.min and Result <= data.max
        -- Percentile must be between min and max

    q1_le_q2_le_q3: Result [1] <= Result [2] and Result [2] <= Result [3]
        -- Quartiles must be ordered: Q1 ≤ Q2 ≤ Q3

    mode_in_data: data.has (Result)
        -- Mode must actually be in the data
```

---

## Invariant Contracts (INVARIANT)

### TEST_RESULT Invariants

```eiffel
invariant
    p_value_valid: p_value >= 0.0 and p_value <= 1.0
        -- p-value is always valid probability

    degrees_of_freedom_valid: degrees_of_freedom >= 1
        -- d.o.f. must be at least 1

    statistic_finite: statistic.is_finite
        -- Test statistic is always a valid number

    assumption_checks_valid: assumption_checks /= Void
        -- Assumption checks are always present

    all_checks_valid: assumption_checks.for_all (
        agent (check) do
            Result := not check.name.is_empty
        end
    )
        -- All checks have names
```

### REGRESSION_RESULT Invariants

```eiffel
invariant
    r_squared_valid: r_squared >= 0.0 and r_squared <= 1.0
        -- R² is between 0 and 1

    slopes_finite: slope.is_finite and intercept.is_finite
        -- Slope and intercept are valid numbers

    residuals_valid: residuals /= Void and not residuals.is_empty
        -- Residuals are always present and non-empty

    residuals_finite: residuals.for_all (agent (x) do Result := x.is_finite end)
        -- All residuals are valid numbers

    condition_positive: condition_number >= 1.0
        -- Condition number is always ≥ 1 (perfect conditioning = 1)

    residual_count_matches: residuals.count = -- original x.count
        -- Number of residuals matches number of observations
```

### ASSUMPTION_CHECK Invariants

```eiffel
invariant
    name_non_empty: not name.is_empty
        -- Assumption must have a name

    detail_consistency: (not passed) implies (not detail.is_empty)
        -- If assumption failed, must have explanation

    immutable: -- No setter methods exist
        -- Once created, cannot be modified
```

---

## Numerical Stability Contracts

### Condition Number Contracts

For regression operations:

```eiffel
ensure
    condition_number_computed: Result.condition_number >= 1.0
        -- Condition number always ≥ 1

    well_conditioned: Result.condition_number < 1e4
        -- Good conditioning for typical problems

    warning_if_ill_conditioned: Result.condition_number > 1e12
        -- Very ill-conditioned; results may be unstable

    condition_interpretation:
        -- κ < 10: excellent
        -- κ < 100: good
        -- κ < 1000: fair
        -- κ < 1e12: acceptable
        -- κ > 1e12: problematic; consider data scaling
```

### Variance Contracts (Welford's Algorithm)

```eiffel
ensure
    variance_numerically_stable:
        -- Welford's algorithm used; stable even with large deviations
        -- No catastrophic cancellation from E[X²] - E[X]²

    variance_matches_definition:
        -- Result = Σ(xᵢ - mean)² / n (population variance)

    variance_non_negative: Result >= 0.0
        -- Variance always non-negative by definition
```

### Regression Contracts (QR Decomposition)

```eiffel
ensure
    regression_numerically_stable:
        -- QR decomposition used; stable even with ill-conditioned X'X
        -- No normal equations; no explicit matrix inversion

    condition_number_reflects_stability: Result.condition_number =
        -- κ(X) where X is design matrix

    predictions_consistent:
        -- predict(x) matches y_fitted for original x values
```

---

## Educational Contracts (Assumption Documentation)

### Assumption Check Contracts

```eiffel
ensure
    assumption_normality_checked:
        -- For t-tests: result includes check for approximate normality

    assumption_independence_documented:
        -- Feature comment states: "Assumes independent observations"

    assumption_equal_variance_checked:
        -- For two-sample t-test: result includes check for variance equality

    alternatives_documented:
        -- Feature comment lists alternatives if assumptions fail
        -- E.g., "Use Mann-Whitney U if normality fails"
```

### When-to-Use Contracts

Every test function includes documentation:

```eiffel
    t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
            -- Two-sample t-test: H₀: μ₁ = μ₂.
            --
            -- WHEN TO USE:
            -- - Comparing means of two independent groups
            -- - Continuous outcome variable
            -- - Approximate normality (or large n)
            --
            -- ASSUMPTIONS:
            -- - Independent observations
            -- - Approximately normal distributions
            -- - Equal variances (Welch variant if unequal)
            --
            -- IF ASSUMPTIONS FAIL:
            -- - Use Mann-Whitney U (nonparametric alternative)
            -- - Use Welch's t-test (for unequal variances)
            -- - Check for outliers (may violate normality)
```

---

## Contract Checking Levels

### DEBUG Level (Comprehensive Checking)

```
require              -- Checked in DEBUG
    all preconditions enforced

ensure               -- Checked in DEBUG
    all postconditions verified

invariant            -- Checked in DEBUG
    all invariants maintained
```

### RELEASE Level (Selective Checking)

```
require              -- Checked in RELEASE (preconditions)
    critical preconditions (data validity, NaN checks)

ensure               -- NOT checked in RELEASE
    expensive postconditions disabled for performance

invariant            -- Checked in RELEASE (class invariants)
    critical invariants only
```

**Rationale:** Preconditions catch user errors; postconditions verify implementation correctness. In RELEASE, we assume implementation is correct but still validate user input.

---

## Contract Completeness Checklist

For each public feature, verify:

- [ ] **Precondition(s):** What must be true to call?
  - Data validity (non-empty, no NaN, finite)
  - Sufficient data (n ≥ minimum)
  - Parameter validity (ranges, relationships)

- [ ] **Postcondition(s):** What's guaranteed true after?
  - Result range (valid values)
  - Result finiteness (not NaN or ∞)
  - Result correctness (matches definition)
  - Relationships to inputs

- [ ] **Invariant(s):** What's always true?
  - For result objects: range validity, consistency
  - For data: no shared mutable state

- [ ] **Side Effects:** What didn't change?
  - Inputs are not modified
  - No global state changes
  - Function is deterministic (same input → same output)

- [ ] **Algorithm Documentation:** How is it computed?
  - Welford for variance (numerically stable)
  - QR for regression (numerically stable)
  - Ranking for percentiles
  - Comments explain WHY this algorithm, not just WHAT it does

---

## Contract Testing Strategy

### Property-Based Testing

```eiffel
-- For every function, generate random valid inputs and verify:
test_variance_non_negative (data: ARRAY [REAL_64]) is
    require
        data_valid: not data.is_empty and data_has_no_nan
    local
        v: REAL_64
    do
        v := variance (data)
        assert ("variance non-negative", v >= 0.0)
        assert ("variance finite", v.is_finite)
    end

-- For correlation, verify range
test_correlation_in_range (x, y: ARRAY [REAL_64]) is
    require
        data_valid: x.count = y.count and not x.is_empty
    local
        r: REAL_64
    do
        r := correlation (x, y)
        assert ("correlation in [-1, 1]", r >= -1.0 - 1e-10 and r <= 1.0 + 1e-10)
    end
```

### Edge Case Testing

```eiffel
-- Minimum size arrays
test_mean_single_element:
    assert (mean ({ARRAY [REAL_64]} <<1.0>>) = 1.0)

test_t_test_two_minimum:
    local x, y: ARRAY [REAL_64]
    do
        x := {ARRAY [REAL_64]} <<1.0, 2.0>>
        y := {ARRAY [REAL_64]} <<3.0, 4.0>>
        assert (t_test_two_sample (x, y) /= Void)
    end

-- Extreme values
test_variance_large_numbers:
    local data: ARRAY [REAL_64]
    do
        data := {ARRAY [REAL_64]} <<1e15, 1e15 + 1.0>>
        assert (variance (data) >= 0.0)  -- Not destroyed by catastrophic cancellation
    end
```

---

**Status:** CONTRACT DESIGN COMPLETE
