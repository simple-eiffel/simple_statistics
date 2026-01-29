# INNOVATIONS: simple_statistics

## What Makes This Different from Existing Solutions

### I-001: Design by Contract for Statistics

**Problem Solved:** Statistical libraries (scipy, R, MATLAB) have no formal contracts. Errors silently produce wrong answers.

**Approach:**
- Every Tier 1 function has preconditions (non-empty, no NaN, n ≥ minimum)
- Every function has postconditions (result in valid range, d.o.f. > 0)
- Invariants on result classes (p_value in [0,1], statistic is finite)

**Novelty:** NO OTHER statistical library uses Design by Contract at this scale

**Design Impact:**
- Users get clear contract violations instead of subtle bugs
- Enables automated verification and property testing
- Theory meets practice in executable contracts

**Example:**
```eiffel
t_test_one_sample (data: ARRAY [REAL_64]; μ0: REAL_64): TEST_RESULT
  require
    data.count >= 2  -- Need at least 2 samples
    not data.exists (agent (x) do Result := x.is_nan end)  -- No NaN
    not μ0.is_nan and not μ0.is_infinite  -- Valid null hypothesis
  ensure
    Result.p_value >= 0.0 and Result.p_value <= 1.0  -- p in [0,1]
    Result.degrees_of_freedom = data.count - 1  -- d.o.f = n-1
    Result.statistic.is_finite  -- t-statistic is finite
end
```

---

### I-002: Tier-Based Progressive Learning

**Problem Solved:** scipy and R are overwhelming; users don't know which functions to start with.

**Approach:**
- Tier 1 (80% of users): 20 functions covering descriptive stats, basic regression, basic tests
- Tier 2 (15% of users): 20+ functions for robust stats, effect sizes, advanced tests
- Tier 3 (5% of users): Custom hypothesis tests, bootstrap, Bayesian inference

**Novelty:** Explicit tier structure unknown in scipy; R has it implicitly but undocumented

**Design Impact:**
- New users start with Tier 1 (SIMPLE_STATISTICS class)
- Advanced users graduate to ROBUST_STATISTICS, EFFECT_SIZES, etc.
- Clear documentation for each tier

**Example Documentation:**
```
TIER 1: Beginners
├─ SIMPLE_STATISTICS (20 methods)
│  ├─ Descriptive: mean, median, variance, std_dev
│  ├─ Correlation: correlation, covariance
│  ├─ Regression: linear_regression
│  └─ Testing: t_test, chi_square, anova
│
├─ Next Level: Understand effect sizes (Tier 2)
└─ Deep Dive: Custom tests (Tier 3)
```

---

### I-003: Type-Safe Result Objects

**Problem Solved:** scipy returns tuples; users access via index `result[0]` or named tuples. Error-prone.

**Approach:**
- TEST_RESULT class with fields: `statistic`, `p_value`, `degrees_of_freedom`
- Methods: `conclusion(α)`, `format_for_publication()`, `assumption_checks()`
- Type-safe: compiler checks field access

**Novelty:** NO statistical library returns fully-typed result classes

**Design Impact:**
- Results are extensible objects, not immutable tuples
- Can add methods without breaking API
- IDE autocomplete shows available fields

**Example:**
```eiffel
result := t_test_one_sample(data, 0.0)
-- Type-safe: compiler knows result has these fields
assert (result.p_value < 0.05)
assert (result.statistic.abs > 1.96)
print (result.format_for_publication())  -- "t(98) = 2.34, p = .022"
```

---

### I-004: Composition with Simple Eiffel Ecosystem

**Problem Solved:** In other languages, you need separate libraries. In Simple Eiffel, we integrate seamlessly.

**Approach:**
- Composition with simple_probability (distributions for p-values, Tier 3)
- Composition with simple_linalg (matrix operations for regression)
- Composition with simple_calculus (integration for distribution functions)

**Novelty:** Designed from ground-up to compose with other Simple libraries

**Design Impact:**
- No reinventing wheels (use simple_linalg for matrix ops)
- Natural data flow between libraries
- Enables advanced workflows (e.g., regression + residual hypothesis testing)

**Example:**
```eiffel
-- Regression using simple_linalg
regression_result := linear_regression(x_data, y_data)

-- Check if slope is significantly different from zero
-- (Uses simple_probability internally, Tier 3)
t_stat := regression_result.slope / regression_result.slope_std_error
p_value := t_distribution.survival_function(t_stat, d.o.f)
```

---

### I-005: Numerically Stable Algorithms (Production-Grade)

**Problem Solved:** "Wrong fast" (catastrophic cancellation) vs "slow correct"

**Approach:**
- Welford's algorithm for variance (not naïve two-pass)
- QR decomposition for regression (not normal equations)
- Condition number validation; warn if κ > 1e12

**Novelty:** Explicit algorithm choice documented in code; most libraries hide this

**Design Impact:**
- Users get correct answers even on edge cases
- Design by Contract enforces stable properties
- Documentation includes algorithm choice rationale

**Example:**
```eiffel
-- Implementation detail visible in postcondition
variance (data: ARRAY [REAL_64]): REAL_64
  ensure
    -- Welford algorithm ensures numerical stability
    -- even with large deviations in values
  end
```

---

### I-006: SCOOP-Ready (Future Concurrency)

**Problem Solved:** scipy can't do true parallelism (GIL). Eiffel SCOOP can.

**Approach:**
- All result objects are IMMUTABLE
- No shared mutable state
- Futures can compute independent statistical tests in parallel

**Novelty:** NO Python library can do this; R's parallelism is bolted-on

**Design Impact:**
- Foundation laid for SCOOP parallelism (v1.1+)
- Users can later do:
  ```eiffel
  -- Future: Run hypothesis tests in parallel via SCOOP
  t_result := |t_test_one_sample (data, μ0) |  -- Promise
  ```

---

### I-007: Built-in Educational Value

**Problem Solved:** Users don't understand WHEN to use which test, or what assumptions matter

**Approach:**
- Each test class documents:
  - When to use this test (use cases)
  - Assumptions required (normality, independence, equal variance)
  - What happens if assumptions violated
  - Alternatives if assumptions fail
- TEST_RESULT includes `assumption_checks: ARRAY [ASSUMPTION_CHECK]`

**Novelty:** Most libraries have dense documentation; we integrate theory into code

**Design Impact:**
- Users learn statistics while using the library
- Automatic assumption checking built-in
- Clear error messages when assumptions violated

**Example:**
```eiffel
t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
  -- Assumptions (documented in contract):
  -- 1. Both groups approximately normally distributed
  --    (check with shapiro_wilk test)
  -- 2. Independent samples (design responsibility)
  -- 3. Equal variances (check with levene test)
  --
  -- If assumptions fail:
  -- - Use Mann-Whitney U test (nonparametric alternative)
  -- - Use Welch's t-test (unequal variance variant)
```

---

## Differentiation from Existing Solutions

| Aspect | SciPy | R | simple_statistics |
|--------|-------|---|-------------------|
| **Type Safety** | Dynamic | Dynamic | ✓ Strong (REAL_64, Void-safe) |
| **Design by Contract** | ✗ None | ✗ None | ✓ Full (preconditions, postconditions) |
| **Tier-Based API** | ✗ Flat | ✗ Implicit | ✓ Explicit (Tier 1/2/3) |
| **Result Types** | Tuples/namedtuple | Lists/vectors | ✓ Typed classes |
| **Stable Algorithms** | ✓ Yes (hidden) | ✓ Yes (hidden) | ✓ Yes (documented) |
| **Educational Integration** | ✗ Separate docs | ✗ Separate help | ✓ In-code assumptions |
| **SCOOP Ready** | ✗ No (GIL) | ✗ Bolted-on | ✓ Native (immutable) |
| **Composition with Core** | ✗ None | ✗ None | ✓ Probability, Calculus, Linalg |

---

**Status:** INNOVATIONS COMPLETE - Ready for RISKS research
