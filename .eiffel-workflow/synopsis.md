# Phase 2 Synthesis: Contract Review Findings

**Review Conducted:** 2026-01-29
**Reviewers:** Claude (MML/Correctness/Testability/Synthesis)
**Status:** COMPLETE - Ready for Phase 3

---

## Executive Summary

**Overall Quality:** MEDIUM - Contracts are structurally sound but suffer from vague postconditions that don't meaningfully constrain implementations.

**Blocking Issues:** 3 CRITICAL, 7 HIGH, 5 MEDIUM
**Recommendation:** Fix critical issues before Phase 4, address high-priority issues during implementation.

**Key Finding:** Postconditions like `result_valid: True` and `result_valid: True -- result is finite` appear throughout and provide NO actual constraint. A completely wrong implementation could still satisfy these contracts.

---

## Critical Issues (Must Fix Before Phase 4)

### ISSUE 1: Vague Postconditions - Result Validity Claims

**LOCATION:**
- STATISTICS.mean, median, percentile, min_value, max_value, sum, correlation, covariance
- REGRESSION_RESULT.predict
- CLEANED_STATISTICS.remove_nan, remove_infinite, clean

**SEVERITY:** CRITICAL

**PROBLEM:**
Multiple postconditions use `result_valid: True` or `result_valid: True -- result is finite` which is a **tautology** - it's always true regardless of implementation. These do not constrain the implementation at all.

Example:
```eiffel
mean (data: ARRAY [REAL_64]): REAL_64
    ...
    ensure
        result_valid: True  -- result is finite
```

A function that returns `0.0` always, or returns `data[1]` always, would satisfy this contract.

**FIX:** Replace with actual mathematical constraints:
```eiffel
mean (data: ARRAY [REAL_64]): REAL_64
    ensure
        result_valid: Result = (sum of all elements) / data.count
        result_example_constraint: data.count = 1 implies Result = data[1]
```

Or at minimum:
```eiffel
mean (data: ARRAY [REAL_64]): REAL_64
    ensure
        result_bounded: (across data as d all Result <= d.max and Result >= d.min end)
        -- For 3 elements [1.0, 2.0, 3.0], mean must be 2.0
```

**CONFIDENCE:** Very High - This is mathematically provable issue

---

### ISSUE 2: Postcondition That Assumes Implementation (mode)

**LOCATION:** STATISTICS.mode

**SEVERITY:** CRITICAL

**PROBLEM:**
```eiffel
mode (data: ARRAY [REAL_64]): REAL_64
    ensure
        result_in_data: data.has (Result)
```

This postcondition **assumes an implementation detail** - that the mode must be a value actually in the data. But for floating-point data, the mode might be computed as an average or interpolation. This constraint makes sense semantically but needs clarification:

- Is mode *always* one of the input values? (binned/discrete assumption)
- Or can it be interpolated? (continuous assumption)

For statistical mode with continuous REAL_64 data, the postcondition is problematic because:
1. No value may appear more than once (all unique)
2. Multiple values may tie (multimodal data)

**FIX:** Clarify in docstring and strengthen postcondition:
```eiffel
mode (data: ARRAY [REAL_64]): REAL_64
        -- Most frequent value. For data with no repeats or multiple modes,
        -- returns one with highest frequency (implementation-defined which when tied).
    ensure
        result_in_data: data.has (Result)
        result_has_max_frequency: (across data as d all
            (count of d in data) <= (count of Result in data)
        end)
```

But this requires frequency counting, which can't be expressed in pure Eiffel contracts without external functions.

**SUGGESTED FIX:** Defer mode to Phase 5, or document that data should be pre-processed (binned).

**CONFIDENCE:** High

---

### ISSUE 3: Correlation Result Constraint Missing

**LOCATION:** STATISTICS.correlation

**SEVERITY:** CRITICAL

**PROBLEM:**
```eiffel
correlation (x, y: ARRAY [REAL_64]): REAL_64
        -- Pearson correlation coefficient in [-1, 1].
    ensure
        result_valid: True  -- result is valid
```

The docstring claims result is in [-1, 1], but the postcondition (`result_valid: True`) does NOT enforce this. A function returning 5.0 would satisfy the contract.

**FIX:**
```eiffel
correlation (x, y: ARRAY [REAL_64]): REAL_64
    ensure
        result_in_range: Result >= -1.0 and Result <= 1.0
        result_is_pearsons: Result = (covariance(x,y) / (std_dev(x) * std_dev(y)))
```

**CONFIDENCE:** Very High - Directly contradicts docstring

---

## High-Priority Issues (Fix Before Phase 4 if Possible)

### ISSUE 4: Quartiles Ordering Postcondition Too Weak

**LOCATION:** STATISTICS.quartiles

**PROBLEM:**
```eiffel
quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
    ensure
        result_size: Result.count = 3
        ordered: Result [1] <= Result [2] and Result [2] <= Result [3]
```

Good ordering constraint, but missing what these values actually represent:
- Should Result[1] = percentile(data, 25)?
- Should Result[2] = percentile(data, 50)?
- Should Result[3] = percentile(data, 75)?

**FIX:**
```eiffel
quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
    ensure
        result_size: Result.count = 3
        q1_defined: Result [1] = percentile(data, 25.0)
        q2_defined: Result [2] = percentile(data, 50.0)
        q3_defined: Result [3] = percentile(data, 75.0)
        ordered: Result [1] <= Result [2] and Result [2] <= Result [3]
```

**CONFIDENCE:** High

---

### ISSUE 5: Missing Edge Case - Degrees of Freedom in t_test_two_sample

**LOCATION:** STATISTICS.t_test_two_sample

**PROBLEM:**
```eiffel
t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
    ensure
        dof_correct: Result.degrees_of_freedom = x.count + y.count - 2
```

This assumes **equal variances t-test** (pooled variance). For **Welch's t-test** (unequal variances), the degrees of freedom uses Welch-Satterthwaite formula, which is NOT `x.count + y.count - 2`.

**DOCUMENTATION:** Docstring should clarify which t-test variant is implemented. Contract should match.

**FIX:** Either:
- Change to implement Welch's and update dof formula, OR
- Document that it's Welch's and update postcondition to use correct formula

**CONFIDENCE:** High (statistical knowledge)

---

### ISSUE 6: Test Result Format Postcondition Too Vague

**LOCATION:** TEST_RESULT.format_for_publication

**PROBLEM:**
```eiffel
format_for_publication (test_name: STRING): STRING
    ensure
        result_valid: not Result.is_empty
```

Postcondition only says "not empty" but doesn't specify format. Docstring says `"t(98)=2.34, p=.022"` but contract doesn't enforce this pattern.

**FIX:**
```eiffel
format_for_publication (test_name: STRING): STRING
        -- Format: "test_name(dof)=statistic, p=p_value"
        -- Example: "t(98)=2.34, p=.022"
    ensure
        result_non_empty: not Result.is_empty
        result_contains_name: Result.has_substring(test_name)
        result_contains_dof: Result.has_substring("(" + degrees_of_freedom.out + ")")
        result_has_equals: Result.has_substring("=")
        result_has_p: Result.has_substring("p=")
```

But this requires string utility predicates not available in base Eiffel.

**SIMPLIFICATION:** Just document the expected format clearly in docstring, accept vague contract.

**CONFIDENCE:** Medium

---

### ISSUE 7: CLEANED_STATISTICS Helper Methods Have Dead Code Postconditions

**LOCATION:** CLEANED_STATISTICS.has_nan, has_infinite

**PROBLEM:**
```eiffel
has_nan (arr: ARRAY [REAL_64]): BOOLEAN
    ensure
        result_is_boolean: True
```

Postcondition `result_is_boolean: True` is always satisfied for any function returning a BOOLEAN. This is dead code.

Also, the TODO comment reveals these are not implemented:
```eiffel
do
    Result := False
    -- TODO: Phase 4 - Check for NaN values
```

So `has_nan` always returns False, even if array contains NaNs.

**FIX:**
1. Remove useless postconditions
2. Implement actual NaN/infinity checking in Phase 4

```eiffel
has_nan (arr: ARRAY [REAL_64]): BOOLEAN
    ensure
        result_correct: Result = (exists i in arr where i.is_nan)
```

**CONFIDENCE:** High - Code inspection shows obvious issue

---

### ISSUE 8: ANOVA Postcondition Incomplete

**LOCATION:** STATISTICS.anova

**PROBLEM:**
```eiffel
anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
    ensure
        result_valid: Result /= Void
        p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
```

Missing degrees of freedom specification. For ANOVA:
- dof_between = k - 1 (number of groups - 1)
- dof_within = n - k (total samples - number of groups)
- Total dof = n - 1

**FIX:**
```eiffel
anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
    ensure
        result_valid: Result /= Void
        p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
        dof_correct: Result.degrees_of_freedom = (total_count - groups.count)
            -- or specify between-groups dof: groups.count - 1
```

**CONFIDENCE:** High

---

### ISSUE 9: Chi-Square Test Expected Value Validation Missing

**LOCATION:** STATISTICS.chi_square_test

**PROBLEM:**
```eiffel
chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
    require
        same_length: observed.count = expected.count
        data_valid: not observed.is_empty
    ensure
        ...
```

Chi-square test has important precondition not enforced: **all expected frequencies must be ≥ 5** (standard assumption). Without this, test is invalid.

**FIX:**
```eiffel
chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
    require
        same_length: observed.count = expected.count
        data_valid: not observed.is_empty
        expected_valid: (across expected as e all e >= 5.0 end)
            -- Standard assumption: all expected frequencies >= 5
    ensure
        ...
```

**CONFIDENCE:** High (statistical requirement)

---

### ISSUE 10: Linear Regression Residuals Array Size Unspecified

**LOCATION:** REGRESSION_RESULT

**PROBLEM:**
```eiffel
residuals: ARRAY [REAL_64]
        -- Differences: observed_y - predicted_y.
```

The `make` feature accepts `a_residuals: ARRAY [REAL_64]` but doesn't verify it matches the number of data points. A regression with 100 data points should have 100 residuals.

**FIX:**
Store the count of original data points and verify in postcondition:
```eiffel
make (a_slope: REAL_64; a_intercept: REAL_64; a_r2: REAL_64;
        a_residuals: ARRAY [REAL_64]; a_condition: REAL_64; a_data_count: INTEGER)
    require
        residuals_size: a_residuals.count = a_data_count
    ensure
        ...
```

Or accept that implementation will verify this internally (document in docstring).

**CONFIDENCE:** Medium

---

## Medium-Priority Issues (Nice to Fix)

### ISSUE 11: Covariance Result Sign Not Constrained

**LOCATION:** STATISTICS.covariance

**PROBLEM:**
```eiffel
covariance (x, y: ARRAY [REAL_64]): REAL_64
    ensure
        result_valid: True  -- result is finite
```

Covariance can be negative (negative relationship), zero (no relationship), or positive (positive relationship). The contract doesn't specify any constraint. At minimum, document this.

**FIX:** Document in docstring that result can be any real number.

**CONFIDENCE:** Medium

---

### ISSUE 12: Missing MML Model Queries for Collection Attributes

**LOCATION:** TEST_RESULT.assumption_checks, REGRESSION_RESULT.residuals

**PROBLEM:**
Collections in result objects should have MML model queries for frame conditions:

```eiffel
assumption_checks: ARRAY [ASSUMPTION_CHECK]
    -- Should have model query:
    -- assumption_checks_model: MML_SEQUENCE [ASSUMPTION_CHECK]
    --     for frame conditions in postconditions
```

Currently no way to express: "This array didn't change" or "This array was constructed with these elements."

**FIX (Phase 5):**
```eiffel
assumption_checks_model: MML_SEQUENCE [ASSUMPTION_CHECK]
    do
        create Result
        across assumption_checks as ac loop
            Result := Result & @ac.item
        end
    end

-- Then in postconditions:
ensure
    checks_unchanged: old assumption_checks_model |=| assumption_checks_model
```

**CONFIDENCE:** High (architectural improvement, not blocking)

---

### ISSUE 13: Percentile Boundary Cases Not Specified

**LOCATION:** STATISTICS.percentile

**PROBLEM:**
```eiffel
percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
    require
        percentile_valid: p >= 0.0 and p <= 100.0
    ensure
        result_valid: True  -- result is within data range
```

What happens for edge cases?
- p = 0.0 should return min
- p = 100.0 should return max
- What about p = 50.0 (should equal median)?

**FIX:**
```eiffel
percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
    require
        percentile_valid: p >= 0.0 and p <= 100.0
    ensure
        p_0_returns_min: p = 0.0 implies Result = min_value(data)
        p_100_returns_max: p = 100.0 implies Result = max_value(data)
        p_50_returns_median: p = 50.0 implies Result = median(data)
```

**CONFIDENCE:** High

---

## Low-Priority Issues (Documentation/Style)

### ISSUE 14: Invariant "instance_valid: True" is Dead Code

**LOCATION:** STATISTICS, CLEANED_STATISTICS, and all stateless classes

**PROBLEM:**
```eiffel
invariant
    instance_valid: True
```

This invariant is always true and provides no value. It's placeholder code left over from generation.

**FIX:** Remove these trivial invariants from stateless classes.

**CONFIDENCE:** High

---

### ISSUE 15: TODOs Should Not Appear in Production Code

**LOCATION:** All classes' `do` sections

**PROBLEM:**
```eiffel
do
    -- TODO: Phase 4 - Implement using numerically stable summation
    Result := 0.0
```

These are placeholder implementations returning false results (0.0). Document this clearly or use `notimplemented` exception.

**FIX:** Either:
1. Leave as-is (contract-only development is valid)
2. Add feature to raise NotImplementedError in Phase 4
3. Document prominently that these are contract skeletons

**CONFIDENCE:** Low (stylistic, not functional)

---

## Synthesis: Issues by Priority

### Must Fix Before Phase 4 (Blocks Implementation)
1. ✗ STATISTICS.mean/median/etc: Vague `result_valid: True` postconditions
2. ✗ STATISTICS.correlation: Missing range constraint
3. ✗ STATISTICS.mode: Semantically problematic postcondition

### Should Fix Before Phase 4 (Otherwise Contract-Implementation Mismatch)
4. ✓ STATISTICS.t_test_two_sample: Clarify Welch's vs pooled variance
5. ✓ STATISTICS.chi_square_test: Add expected frequency precondition
6. ✓ STATISTICS.anova: Add degrees of freedom postcondition
7. ✓ STATISTICS.quartiles: Add percentile mapping postconditions
8. ✓ TEST_RESULT.format_for_publication: Clarify format specification
9. ✓ CLEANED_STATISTICS: Remove dead code postconditions
10. ✓ REGRESSION_RESULT: Verify residuals array size

### Nice to Have (Architectural Improvements)
11. Add MML model queries to collection attributes
12. Add boundary case specifications for percentile
13. Remove trivial `instance_valid: True` invariants

---

## Recommendation: Proceed to Phase 3?

**Status:** CONDITIONAL APPROVAL

**Proceed IF:**
- Fix the 3 CRITICAL issues (mean/median/correlation)
- Address at least issues 4-9 (HIGH priority)
- Accept that LOW priority issues (14-15) defer to Phase 4

**Do NOT Proceed IF:**
- Critical issues remain unfixed (contracts will not guide implementation correctly)

**Suggested Action:**
Generate corrected contracts automatically, OR manually fix identified issues in Eiffel files before Phase 4 begins.

---

## Next Steps

1. **Accept this synopsis** (or request changes)
2. **Fix contracts** in src/*.e files OR defer fixes to Phase 4 with acceptance of risk
3. **Approve contracts** explicitly before Phase 3 (Task Breakdown)
4. **Proceed to Phase 3:** `/eiffel.tasks d:\prod\simple_statistics`

---

**Synthesis Complete:** 2026-01-29
**Ready for User Approval**
