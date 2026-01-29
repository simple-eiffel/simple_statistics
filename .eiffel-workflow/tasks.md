# Implementation Tasks: simple_statistics v1.0

**Total Tasks:** 23
**Dependency Groups:** 5 sequential phases
**Estimated Effort:** 5 weeks (one feature per day + distribution CDF work)

---

## PHASE 1: Foundation (Tasks 1-3)

### Task 1: Min/Max/Range (Tier 1 - No Dependencies)
**Priority:** CRITICAL (foundation for other features)
**Files:** `src/statistics.e`
**Features to implement:**
- `min_value(data: ARRAY [REAL_64]): REAL_64`
- `max_value(data: ARRAY [REAL_64]): REAL_64`
- `range(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:**
```eiffel
-- Single pass, track running min/max
local min_val, max_val: REAL_64
do
    min_val := data[1]
    max_val := data[1]
    across data as ic loop
        if ic.item < min_val then min_val := ic.item end
        if ic.item > max_val then max_val := ic.item end
    end
    Result := ... (min for min_value, max for max_value, max-min for range)
end
```

**Acceptance Criteria:**
- [ ] `min_value` returns element with `result_in_data: data.has(Result)` satisfied
- [ ] `max_value` returns element with `result_in_data: data.has(Result)` satisfied
- [ ] `range` returns non-negative difference
- [ ] All three compile with zero postcondition violations
- [ ] Unit tests pass: `test_min_max_range_basic`, `test_min_max_single_element`

**Tests Affected:**
- (None yet - foundation only)

**Dependencies:** None

---

### Task 2: Mean (Tier 1 - Foundation for Variance)
**Priority:** CRITICAL
**Files:** `src/statistics.e`
**Features to implement:**
- `mean(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Welford's online mean (numerically stable, one pass)
```eiffel
local mean_val: REAL_64; count: INTEGER
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

**Acceptance Criteria:**
- [ ] Postcondition `result_is_average: True` satisfied (documented)
- [ ] Numerically stable (works with large/small magnitudes)
- [ ] Unit tests pass: `test_mean_single_value`, `test_mean_multiple_values`, `test_mean_negative_values`
- [ ] Compiles clean

**Tests Affected:**
- `test_mean_single_value` (1.0) - must pass
- `test_mean_multiple_values` ([1,2,3,4,5] = 3.0) - must pass
- `test_mean_negative_values` ([-1,-2,-3] = -2.0) - must pass

**Dependencies:** None

---

### Task 3: Sum (Tier 1 - Optional, used by mean alternatives)
**Priority:** MEDIUM (alternative to Welford's mean)
**Files:** `src/statistics.e`
**Features to implement:**
- `sum(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Kahan summation (compensated addition for precision)
```eiffel
local running_sum, compensation, temp: REAL_64
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

**Acceptance Criteria:**
- [ ] Postcondition `result_is_sum: True` satisfied (documented)
- [ ] More accurate than naive summation for ill-conditioned data
- [ ] Compiles clean

**Tests Affected:** (None - sum is helper only)

**Dependencies:** None

---

## PHASE 2: Descriptive Statistics (Tasks 4-9)

### Task 4: Variance (Tier 1 - Depends on Mean)
**Priority:** HIGH
**Files:** `src/statistics.e`
**Features to implement:**
- `variance(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Welford's two-pass variance (population variance)
```eiffel
local mean_val, sum_sq_dev: REAL_64
do
    mean_val := mean(data)  -- Use implemented mean feature
    sum_sq_dev := 0.0
    across data as ic loop
        sum_sq_dev := sum_sq_dev + (ic.item - mean_val) * (ic.item - mean_val)
    end
    Result := sum_sq_dev / data.count
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_non_negative: Result >= 0.0` satisfied
- [ ] Calls `mean(data)` internally (reuses Task 2)
- [ ] Unit tests pass: `test_variance_simple`, `test_variance_non_negative`
- [ ] Compiles clean

**Tests Affected:**
- `test_variance_non_negative` - must pass

**Dependencies:** Task 2 (mean)

---

### Task 5: Standard Deviation (Tier 1 - Depends on Variance)
**Priority:** HIGH
**Files:** `src/statistics.e`
**Features to implement:**
- `std_dev(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Square root of variance
```eiffel
do
    Result := (variance(data)).sqrt
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_non_negative: Result >= 0.0` satisfied
- [ ] Calls `variance(data)` internally
- [ ] Unit tests pass: `test_std_dev_non_negative`
- [ ] Compiles clean

**Tests Affected:**
- `test_std_dev_non_negative` - must pass

**Dependencies:** Task 4 (variance)

---

### Task 6: Median (Tier 1 - Independent)
**Priority:** HIGH
**Files:** `src/statistics.e`
**Features to implement:**
- `median(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Sort and extract middle value
```eiffel
local sorted: ARRAY [REAL_64]; mid: INTEGER
do
    sorted := data.twin
    sorted.sort  -- Use Eiffel's built-in sort
    mid := sorted.count // 2
    if sorted.count \\ 2 = 1 then
        Result := sorted[mid + 1]
    else
        Result := (sorted[mid] + sorted[mid + 1]) / 2.0
    end
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_is_median: True` satisfied (documented)
- [ ] Odd-length arrays: returns middle element
- [ ] Even-length arrays: returns average of two middle elements
- [ ] Unit tests pass (when added in Phase 5)
- [ ] Compiles clean

**Tests Affected:** None yet (tests in Phase 5)

**Dependencies:** None

---

### Task 7: Percentile (Tier 1 - Independent)
**Priority:** MEDIUM
**Files:** `src/statistics.e`
**Features to implement:**
- `percentile(data: ARRAY [REAL_64]; p: REAL_64): REAL_64`

**Algorithm:** Linear interpolation (NIST R-7 method)
```eiffel
local sorted: ARRAY [REAL_64]; h: REAL_64; h_floor, h_ceil: INTEGER
do
    sorted := data.twin
    sorted.sort
    h := (p / 100.0) * (data.count - 1)
    h_floor := h.floor
    h_ceil := h.ceil
    if h_floor = h_ceil then
        Result := sorted[h_floor + 1]
    else
        Result := sorted[h_floor + 1] +
                  (h - h_floor) * (sorted[h_ceil + 1] - sorted[h_floor + 1])
    end
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_is_percentile: True` satisfied (documented)
- [ ] p=0 returns min, p=100 returns max (document in tests)
- [ ] Linear interpolation between values
- [ ] Compiles clean

**Tests Affected:** None yet

**Dependencies:** None

---

### Task 8: Quartiles (Tier 1 - Depends on Percentile)
**Priority:** LOW
**Files:** `src/statistics.e`
**Features to implement:**
- `quartiles(data: ARRAY [REAL_64]): ARRAY [REAL_64]`

**Algorithm:** Three percentile calls
```eiffel
local result_arr: ARRAY [REAL_64]
do
    create result_arr.make_filled (0.0, 1, 3)
    result_arr[1] := percentile(data, 25.0)  -- Q1
    result_arr[2] := percentile(data, 50.0)  -- Q2 (median)
    result_arr[3] := percentile(data, 75.0)  -- Q3
    Result := result_arr
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_size: Result.count = 3` satisfied
- [ ] Postcondition `ordered: Result[1] <= Result[2] and Result[2] <= Result[3]` satisfied
- [ ] Q2 equals median (documented in test)
- [ ] Compiles clean

**Tests Affected:** None yet

**Dependencies:** Task 7 (percentile)

---

### Task 9: Mode (Tier 1 - Independent but Complex)
**Priority:** LOW
**Files:** `src/statistics.e`
**Features to implement:**
- `mode(data: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Frequency counting with hash table
```eiffel
local freq_table: HASH_TABLE [INTEGER, REAL_64]; max_freq: INTEGER; result_val: REAL_64
do
    create freq_table.make (data.count)
    across data as ic loop
        if freq_table.has(ic.item) then
            freq_table[ic.item] := freq_table[ic.item] + 1
        else
            freq_table[ic.item] := 1
        end
    end
    max_freq := 0
    across freq_table as ft loop
        if ft.item > max_freq then
            max_freq := ft.item
            result_val := ft.key
        end
    end
    Result := result_val
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_in_data: data.has(Result)` satisfied
- [ ] Returns element with highest frequency
- [ ] For multimodal data, returns first found (implementation-defined)
- [ ] Compiles clean

**Tests Affected:** None yet

**Dependencies:** None

---

## PHASE 3: Bivariate Analysis (Tasks 10-12)

### Task 10: Covariance (Tier 2 - Depends on Mean)
**Priority:** MEDIUM
**Files:** `src/statistics.e`
**Features to implement:**
- `covariance(x, y: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Welford's two-pass covariance
```eiffel
local mean_x, mean_y, sum_products: REAL_64
do
    mean_x := mean(x)
    mean_y := mean(y)
    sum_products := 0.0
    across x.indices as i loop
        sum_products := sum_products + (x[i] - mean_x) * (y[i] - mean_y)
    end
    Result := sum_products / x.count
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_is_covariance: True` satisfied (documented)
- [ ] Calls `mean(x)` and `mean(y)` internally
- [ ] Result can be negative (negative correlation), zero, or positive
- [ ] Compiles clean

**Tests Affected:** None yet

**Dependencies:** Task 2 (mean)

---

### Task 11: Correlation (Tier 2 - Depends on Covariance, Std_Dev)
**Priority:** HIGH
**Files:** `src/statistics.e`
**Features to implement:**
- `correlation(x, y: ARRAY [REAL_64]): REAL_64`

**Algorithm:** Pearson correlation = cov(x,y) / (std_dev(x) * std_dev(y))
```eiffel
local cov_val, std_x, std_y: REAL_64
do
    cov_val := covariance(x, y)
    std_x := std_dev(x)
    std_y := std_dev(y)
    if std_x > 0.0 and std_y > 0.0 then
        Result := cov_val / (std_x * std_y)
    else
        Result := 0.0  -- Degenerate case: no variance
    end
end
```

**Acceptance Criteria:**
- [ ] **Postcondition `result_in_range: Result >= -1.0 and Result <= 1.0` satisfied** ✓
- [ ] Perfect positive correlation (y=x) returns 1.0 (document in test)
- [ ] Perfect negative correlation (y=-x) returns -1.0 (document in test)
- [ ] No correlation returns ~0.0
- [ ] Unit tests pass: `test_correlation_perfect_positive`, `test_correlation_in_range`
- [ ] Compiles clean

**Tests Affected:**
- `test_correlation_perfect_positive` - must pass
- `test_correlation_in_range` - must pass

**Dependencies:** Task 10 (covariance), Task 5 (std_dev)

---

### Task 12: Linear Regression (Tier 2 - Depends on Mean)
**Priority:** HIGH
**Files:** `src/statistics.e`, `src/regression_result.e`
**Features to implement:**
- `linear_regression(x, y: ARRAY [REAL_64]): REGRESSION_RESULT`

**Algorithm:** QR decomposition (numerically stable OLS)
```eiffel
-- Design matrix [1, x[i]] for each point
-- Use simple_linalg QR decomposition (or inline if unavailable)
-- Solve R*beta = Q^T*y for slope and intercept
-- Compute residuals, R^2, condition number
```

**Implementation Complexity:** HIGH (requires matrix operations)
**Fallback:** If simple_linalg unavailable, implement QR inline

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `r2_valid: Result.r_squared >= 0.0 and <= 1.0` satisfied
- [ ] Returns REGRESSION_RESULT with slope, intercept, r_squared, residuals, condition_number
- [ ] Numerically stable (works with ill-conditioned matrices)
- [ ] Unit tests pass: `test_linear_regression_simple`, `test_regression_result_predict`
- [ ] Compiles clean

**Tests Affected:**
- `test_linear_regression_simple` - must pass
- `test_regression_result_predict` - must pass

**Dependencies:** Task 2 (mean) (optional - mainly uses matrix algebra)

---

## PHASE 4: Hypothesis Testing - Parametric (Tasks 13-15)

### Task 13: One-Sample t-test (Tier 2 - Depends on Mean, Std_Dev)
**Priority:** HIGH
**Files:** `src/statistics.e`, `src/test_result.e`
**Features to implement:**
- `t_test_one_sample(data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT`

**Algorithm:**
```eiffel
local t_stat, mean_val, std_error: REAL_64; dof: INTEGER
do
    mean_val := mean(data)
    std_error := std_dev(data) / (data.count).sqrt
    t_stat := (mean_val - mu_0) / std_error
    dof := data.count - 1
    -- Compute p-value from t-distribution with dof
    -- Create assumption checks (normality - placeholder for Phase 5)
    create Result.make(t_stat, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
end
```

**Blocking Issue:** Requires **t-distribution CDF** function (Task 18)

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `p_value_valid: Result.p_value >= 0.0 and <= 1.0` satisfied
- [ ] Postcondition `dof_correct: Result.degrees_of_freedom = data.count - 1` satisfied
- [ ] Unit tests pass: `test_t_test_one_sample`
- [ ] Compiles clean

**Tests Affected:**
- `test_t_test_one_sample` - must pass

**Dependencies:** Task 2 (mean), Task 5 (std_dev), **Task 18** (t-distribution CDF)

---

### Task 14: Two-Sample t-test (Tier 2 - Depends on Mean, Variance)
**Priority:** HIGH
**Files:** `src/statistics.e`
**Features to implement:**
- `t_test_two_sample(x, y: ARRAY [REAL_64]): TEST_RESULT`

**Algorithm:** Welch's t-test (unequal variances)
```eiffel
local t_stat, mean_x, mean_y, var_x, var_y, se: REAL_64; dof: INTEGER
do
    mean_x := mean(x)
    mean_y := mean(y)
    var_x := variance(x)
    var_y := variance(y)
    se := (var_x / x.count + var_y / y.count).sqrt
    t_stat := (mean_x - mean_y) / se
    -- Welch-Satterthwaite formula for dof
    dof := ...
    -- Compute p-value from t-distribution
    create Result.make(t_stat, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `dof_positive: Result.degrees_of_freedom >= 1` satisfied
- [ ] Uses Welch-Satterthwaite dof formula (not simple n1+n2-2)
- [ ] Unit tests pass: `test_t_test_two_sample`
- [ ] Compiles clean

**Tests Affected:**
- `test_t_test_two_sample` - must pass

**Dependencies:** Task 2 (mean), Task 4 (variance), **Task 18** (t-distribution CDF)

---

### Task 15: Paired t-test (Tier 2 - Depends on t_test_one_sample)
**Priority:** MEDIUM
**Files:** `src/statistics.e`
**Features to implement:**
- `t_test_paired(x, y: ARRAY [REAL_64]): TEST_RESULT`

**Algorithm:** Compute differences, call one-sample t-test
```eiffel
local diffs: ARRAY [REAL_64]; i: INTEGER
do
    create diffs.make_filled (0.0, 1, x.count)
    across x.indices as j loop
        diffs[j] := y[j] - x[j]
    end
    Result := t_test_one_sample(diffs, 0.0)  -- H0: mean(diff) = 0
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `dof_correct: Result.degrees_of_freedom = x.count - 1` satisfied
- [ ] Reuses t_test_one_sample on differences
- [ ] Unit tests pass: `test_t_test_paired`
- [ ] Compiles clean

**Tests Affected:**
- `test_t_test_paired` - must pass

**Dependencies:** Task 13 (t_test_one_sample)

---

## PHASE 5: Hypothesis Testing - Non-Parametric & Utilities (Tasks 16-20)

### Task 16: Chi-Square Test (Tier 2 - Depends on Chi-Square CDF)
**Priority:** MEDIUM
**Files:** `src/statistics.e`
**Features to implement:**
- `chi_square_test(observed, expected: ARRAY [REAL_64]): TEST_RESULT`

**Algorithm:**
```eiffel
local chi_sq_stat: REAL_64; i: INTEGER
do
    chi_sq_stat := 0.0
    across observed.indices as j loop
        chi_sq_stat := chi_sq_stat +
            ((observed[j] - expected[j]) * (observed[j] - expected[j])) / expected[j]
    end
    dof := observed.count - 1
    -- Compute p-value from chi-square distribution
    create Result.make(chi_sq_stat, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `p_value_valid: Result.p_value >= 0.0 and <= 1.0` satisfied
- [ ] **Precondition `expected_frequencies_valid: True` validated** (all >= 5.0)
- [ ] Unit tests pass: `test_chi_square_test`
- [ ] Compiles clean

**Tests Affected:**
- `test_chi_square_test` - must pass

**Dependencies:** **Task 19** (chi-square CDF)

---

### Task 17: One-Way ANOVA (Tier 2 - Depends on Mean, Variance, F-Distribution)
**Priority:** MEDIUM
**Files:** `src/statistics.e`
**Features to implement:**
- `anova(groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT`

**Algorithm:**
```eiffel
local grand_mean, ss_between, ss_within, f_stat: REAL_64; dof_between, dof_within: INTEGER
do
    -- Compute grand mean
    grand_mean := mean(all data points combined)
    -- Compute between-group and within-group sums of squares
    ss_between := ...
    ss_within := ...
    dof_between := groups.count - 1
    dof_within := total_count - groups.count
    f_stat := (ss_between / dof_between) / (ss_within / dof_within)
    -- Compute p-value from F-distribution
    create Result.make(f_stat, p_value, dof_between, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: Result /= Void` satisfied
- [ ] Postcondition `p_value_valid: Result.p_value >= 0.0 and <= 1.0` satisfied
- [ ] **Postcondition `dof_between_groups: Result.degrees_of_freedom = groups.count - 1` satisfied** ✓
- [ ] Unit tests pass: `test_anova`
- [ ] Precondition checks all groups non-empty
- [ ] Compiles clean

**Tests Affected:**
- `test_anova` - must pass

**Dependencies:** Task 2 (mean), Task 4 (variance), **Task 20** (F-distribution CDF)

---

### Task 18: Distribution CDFs - t-distribution (Tier 3 - Blocking)
**Priority:** CRITICAL (blocks Tasks 13, 14)
**Files:** (New file or extend STATISTICS)
**Features to implement:**
- `t_cdf(t: REAL_64; dof: INTEGER): REAL_64` (cumulative distribution function)

**Algorithm Options:**
1. **Simple_probability library** (if available) - use existing CDF
2. **Series approximation** (Abramowitz & Stegun) - moderate accuracy
3. **Numerical integration** - high accuracy but slower

**Decision:** Defer to Phase 5 investigation; use placeholder that returns 0.5 for now

**Acceptance Criteria:**
- [ ] Returns value in [0, 1]
- [ ] t_cdf(0, dof) ≈ 0.5
- [ ] Increasing t increases result
- [ ] Compiles clean

**Tests Affected:**
- All t-test tasks depend on this

**Dependencies:** None (pure statistics function)

---

### Task 19: Distribution CDFs - chi-square (Tier 3 - Blocking)
**Priority:** CRITICAL (blocks Task 16)
**Files:** (New file or extend STATISTICS)
**Features to implement:**
- `chi_square_cdf(x: REAL_64; dof: INTEGER): REAL_64`

**Algorithm Options:** Same as Task 18 (t-distribution)

**Acceptance Criteria:** Same as Task 18

**Dependencies:** None

---

### Task 20: Distribution CDFs - F-distribution (Tier 3 - Blocking)
**Priority:** CRITICAL (blocks Task 17)
**Files:** (New file or extend STATISTICS)
**Features to implement:**
- `f_cdf(f: REAL_64; dof1, dof2: INTEGER): REAL_64`

**Algorithm Options:** Same as Task 18

**Acceptance Criteria:** Same as Task 18

**Dependencies:** None

---

### Task 21: Data Cleaning - CLEANED_STATISTICS Methods (Tier 2 - Utility)
**Priority:** LOW
**Files:** `src/cleaned_statistics.e`
**Features to implement:**
- `has_nan(arr: ARRAY [REAL_64]): BOOLEAN`
- `has_infinite(arr: ARRAY [REAL_64]): BOOLEAN`
- `remove_nan(data: ARRAY [REAL_64]): ARRAY [REAL_64]`
- `remove_infinite(data: ARRAY [REAL_64]): ARRAY [REAL_64]`
- `clean(data: ARRAY [REAL_64]): ARRAY [REAL_64]`

**Algorithm:** Iterate and filter
```eiffel
-- has_nan: across arr check for .is_nan
-- remove_nan: create new array excluding NaN values
-- etc.
```

**Acceptance Criteria:**
- [ ] `has_nan` returns true if any NaN in array
- [ ] `has_infinite` returns true if any infinity in array
- [ ] `remove_*` methods return new arrays without problematic values
- [ ] Postconditions satisfied (size constraints)
- [ ] Compiles clean

**Tests Affected:** None yet (utility class)

**Dependencies:** None

---

### Task 22: Assumption Checking (Tier 3 - Optional Enhancement)
**Priority:** LOW
**Files:** `src/statistics.e`, `src/test_result.e`
**Features to implement:**
- Populate `assumption_checks` array in test results
- Implement normality tests (Shapiro-Wilk, Kolmogorov-Smirnov)
- Implement equal variance tests (Levene's test)

**Acceptance Criteria:**
- [ ] test_one_sample populates normality check
- [ ] t_test_two_sample populates equal variance check
- [ ] anova populates normality and equal variance checks
- [ ] TEST_RESULT.format_for_publication includes assumption status

**Dependencies:** All hypothesis test tasks (13-17)

---

### Task 23: TEST_RESULT Formatting (Tier 2 - Polish)
**Priority:** LOW
**Files:** `src/test_result.e`
**Features to implement:**
- `format_for_publication(test_name: STRING): STRING`

**Algorithm:** Format as `"test_name(dof)=statistic, p=p_value"`
```eiffel
do
    Result := test_name + "(" + degrees_of_freedom.out + ")=" +
              statistic.out + ", p=" + p_value.out
end
```

**Acceptance Criteria:**
- [ ] Postcondition `result_valid: not Result.is_empty` satisfied
- [ ] Produces readable academic format
- [ ] Includes test name, dof, statistic, p-value
- [ ] Compiles clean

**Dependencies:** None (pure formatting)

---

## Dependency Graph

```
                          ┌─────────────────────┐
                          │  Task 3: Sum        │
                          └─────────────────────┘
                                    │
                 ┌──────────────────┼──────────────────┐
                 │                  │                  │
        ┌────────▼──────┐  ┌──────┬▼──┐       ┌──────┴──────┐
        │  Task 2: Mean │  │Task 1: Min/Max    │ Task 6: Median
        │               │  │ Task 4: Variance  │ Task 7: Percentile
        └────────┬──────┘  └──────┬┬──┘       └──────┬───────┘
                 │                ││                 │
        ┌────────▼──────┐  ┌──────▼▼──┐       ┌──────▼───────┐
        │ Task 5: Std   │  │Task 10: Cov│     │Task 8: Quarts│
        │ Dev           │  └──────┬────┘     └──────┬────────┘
        └────────┬──────┘         │                 │
                 │      ┌─────────▼──────┐        │
                 │      │ Task 11: Corr  │        │
                 │      └─────────┬──────┘        │
                 │                │               │
        ┌────────▼──────┐  ┌──────▼──┐  ┌────────▼──────┐
        │Task 13: t-1s  │  │Task 14:t-2│  │Task 12: LR   │
        │(needs CDF-t)  │  │(needs CDF-t)  └──────┬───────┘
        └────────┬──────┘  └──────┬──┘             │
                 │                │                │
        ┌────────▼────────────────▼─────┐  ┌──────▼───────┐
        │  Task 15: t-paired            │  │Task 16: χ²   │
        │  (needs Task 13)              │  │(needs CDF-χ²)│
        └────────────────┬──────────────┘  └──────┬────────┘
                         │                        │
                    ┌────▼─────────────────────────▼────┐
                    │  Task 17: ANOVA                   │
                    │  (needs CDF-F)                    │
                    └────────────────────────────────────┘

┌─────────────────────────────────┐
│Distribution CDF Functions (*)   │  * CRITICAL BLOCKING DEPENDENCIES
├─────────────────────────────────┤
│Task 18: t-distribution CDF      │
│Task 19: χ²-distribution CDF     │
│Task 20: F-distribution CDF      │
└─────────────────────────────────┘

┌──────────────────────────────────┐
│Utility & Polish Tasks            │
├──────────────────────────────────┤
│Task 21: Data Cleaning            │
│Task 22: Assumption Checking      │
│Task 23: Result Formatting        │
└──────────────────────────────────┘
```

---

## Implementation Sequence (Critical Path)

**Week 1: Foundation & Descriptive**
1. Task 1: Min/Max/Range (0.5 day)
2. Task 2: Mean (0.5 day)
3. Task 3: Sum (0.5 day)
4. Task 4: Variance (1 day)
5. Task 5: Std Dev (0.5 day)

**Week 2: More Descriptive**
6. Task 6: Median (1 day)
7. Task 7: Percentile (1 day)
8. Task 8: Quartiles (0.5 day)
9. Task 9: Mode (1 day)

**Week 3: Bivariate**
10. Task 10: Covariance (1 day)
11. Task 11: Correlation (1 day)
12. Task 12: Linear Regression (2 days)

**Week 4: Hypothesis Testing (Parallel with CDF Work)**
13. Task 18, 19, 20: Distribution CDFs (2-3 days) **CRITICAL PATH**
14. Task 13: One-Sample t-test (1 day)
15. Task 14: Two-Sample t-test (1 day)
16. Task 15: Paired t-test (0.5 day)
17. Task 16: Chi-Square Test (1 day)
18. Task 17: ANOVA (1.5 days)

**Week 5: Polish & Utilities**
19. Task 21: Data Cleaning (1 day)
20. Task 22: Assumption Checking (1 day)
21. Task 23: Result Formatting (0.5 day)

---

## Notes

- **Critical Blocking Dependencies:** Tasks 18, 19, 20 (distribution CDFs) must be completed before hypothesis testing tasks can be finished
- **Numerical Stability:** All algorithms explicitly use stable variants (Welford, Kahan, QR) as documented in approach.md
- **Test Coverage:** Each task includes references to affected unit tests (to be fully written in Phase 5)
- **Phase 4 vs Phase 5:** Tasks 1-17 are Phase 4 (implementation). Tasks 18-23 are Phase 5 (hypothesis testing, utilities, polish)

