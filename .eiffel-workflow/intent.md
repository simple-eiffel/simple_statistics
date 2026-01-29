# Intent: simple_statistics

## What

A dedicated statistical library for the Simple Eiffel ecosystem providing type-safe, contract-based statistical operations. Fills the market gap where Eiffel has no statistical library equivalent to Python's SciPy or R.

**Core Capabilities:**
- **Tier 1 (MVP):** Descriptive statistics (mean, median, variance, percentiles), correlation, linear regression, hypothesis testing (t-test, chi-square, ANOVA)
- **Tier 2 (Extended):** Robust statistics, effect sizes, distribution tests, non-parametric tests, advanced regression
- **Tier 3 (Future v1.1+):** Bootstrap, custom tests, Bayesian inference

**Target Dataset Size:** n < 100,000 observations (mid-size analytics)

---

## Why

**Problem:** Eiffel developers doing data analysis must switch to Python/R and manually integrate results. No native Eiffel statistical library exists.

**Opportunity:** Simple Eiffel has stable foundation libraries (simple_probability, simple_linalg, simple_calculus) that enable composition. Can provide type safety and Design by Contract guarantees that Python/R cannot match.

**Strategic Value:**
1. Closes ecosystem gap; keeps analytics workflows in Eiffel
2. Leverages SCOOP for future parallel hypothesis testing (Python's GIL prevents this)
3. Differentiates via Design by Contract (preconditions, postconditions, invariants on every function)
4. Type-safe result objects (TEST_RESULT, REGRESSION_RESULT classes, not tuples)
5. Demonstrates Simple Eiffel quality model to scientific computing community

---

## Users

| User Type | Use Case | Eiffel Audience |
|-----------|----------|-----------------|
| **Data Scientists** | Exploratory analysis, hypothesis testing, model validation | 25% of users |
| **Researchers** | Rigorous statistical testing with formal verification | 20% of users |
| **QA Engineers** | Process validation, statistical quality control | 30% of users |
| **Financial Analysts** | Risk metrics, portfolio analysis, performance testing | 15% of users |
| **Eiffel Developers** | Statistical components in applications | 10% of users |

**Adoption Target:** 50+ downloads in first 3 months (based on ecosystem baseline)

---

## Acceptance Criteria

### Tier 1 (v1.0 - MVP)
- [ ] SIMPLE_STATISTICS class: 20 public methods (descriptive, correlation, regression, testing)
- [ ] TEST_RESULT class: immutable result object with conclusion(α), is_significant(), format_for_publication()
- [ ] REGRESSION_RESULT class: slope, intercept, r_squared, predict(x), is_numerically_stable
- [ ] ASSUMPTION_CHECK class: document test assumptions
- [ ] All features have complete Design by Contract (preconditions, postconditions, invariants)
- [ ] 100+ unit tests; > 95% code coverage
- [ ] Numerical stability: Welford for variance, QR for regression, condition number checking
- [ ] Zero silent failures: NaN/infinity rejection with clear error messages
- [ ] Integration with simple_probability (Tier 3 wrapping), simple_linalg (regression), simple_calculus (future)
- [ ] User documentation: 50+ pages; 20+ working examples
- [ ] Production-ready v1.0.0 release with GitHub Pages documentation

### Tier 2 (v1.0 - Extended)
- [ ] ROBUST_STATISTICS: trimmed_mean, mad, outliers_by_iqr, outliers_by_zscore
- [ ] EFFECT_SIZES: cohens_d, eta_squared, cramers_v
- [ ] DISTRIBUTION_TESTS: shapiro_wilk, anderson_darling, ks_test
- [ ] NONPARAMETRIC_TESTS: mann_whitney_u, wilcoxon_signed_rank, kruskal_wallis
- [ ] ADVANCED_REGRESSION: weighted_least_squares, ridge_regression, lasso_regression
- [ ] 150+ additional unit tests (300+ total)
- [ ] Tier 2 documentation: advanced features guide

### Type Safety & Correctness
- [ ] void_safety="all" enforced throughout
- [ ] No Void dereference possible (compiler checked)
- [ ] Immutable result objects (no setter methods)
- [ ] SCOOP-compatible (separate keyword on result objects not needed; immutability sufficient)
- [ ] REAL_64 double precision throughout
- [ ] Deterministic behavior (same input → same output always)

### Performance & Scalability
- [ ] Descriptive stats: O(n) time complexity
- [ ] Percentiles: O(n log n) via sorting
- [ ] Linear regression: O(n²) via QR decomposition
- [ ] Tested on n = 1,000 to 100,000 observations
- [ ] Competitive with SciPy for mid-size datasets (n < 100k)

### Educational Value
- [ ] Assumption documentation: each test explains when/why to use it
- [ ] Clear error messages: precondition violations tell user what's wrong
- [ ] Example-driven documentation: 20+ working programs
- [ ] Algorithm documentation: Welford, QR, statistical formulas explained
- [ ] Progression path: Tier 1 → Tier 2 → Tier 3 learning curve

---

## Out of Scope

**Explicitly NOT included in v1.0:**

| What | Why Excluded | Planned For |
|-----|--------------|-------------|
| Machine Learning | Different domain; requires separate library (simple_ml) | Future |
| Time Series (ARIMA, ACF/PACF) | Specialized domain; Tier 3 feature | v1.1 |
| Bayesian Inference | Advanced; requires posterior inference algorithms | v1.2 |
| Streaming Analytics | Online algorithms; incremental computation | v1.2+ |
| Visualization | Plotting library (simple_chart) handles graphics | N/A |
| SQL/Database Integration | Data access layer; out of scope | N/A |
| GPU Acceleration | Future (if simple_gpu created) | v2.0+ |
| Multi-dimensional Arrays | Use simple_linalg for matrices | N/A |

**Why these are excluded:**
- Focus on core statistical operations first; solid foundation before extensions
- Avoid scope creep (research defined 80/15/5 user distribution by tier)
- Each excluded feature has clear path to future inclusion
- v1.0 ships faster with focused scope; v1.1+ adds extensions based on user demand

---

## Dependencies (simple_* First Policy)

**Rule:** Always prefer `simple_*` libraries over ISE EiffelStudio stdlib and Gobo.

### Required Dependencies

| Need | Library | Version | Justification | Eiffel Alternative |
|------|---------|---------|---------------|-------------------|
| Math operations (sqrt, abs, exp, log) | simple_math | 1.0+ | Consistent with Simple Eiffel philosophy; stable foundation | $ISE/math |
| Probability distributions (CDF, quantile) | simple_probability | 1.0+ | Tier 3 integration; p-value computation from test statistics | $ISE/probability |
| Matrix operations (QR decomposition) | simple_linalg | 1.0+ | Regression implementation; numerically stable algorithms | Custom or Gobo |
| Numerical integration (future) | simple_calculus | 1.0+ | Distribution moment computation (v1.1+) | Custom integration |
| Design by Contract (MML) | simple_mml | 1.0+ | Model queries for collection invariants and frame conditions | ETH base2 |

### ISE Required (No simple_* Alternative)

| Need | Library | Justification |
|------|---------|---------------|
| Fundamental Types (INTEGER, REAL_64, BOOLEAN, STRING) | $ISE/base | Core Eiffel types; essential |
| Array Operations (ARRAY, iteration) | $ISE/base | Collection type; no simple_* equivalent |
| Date/Time | $ISE/time | Standard library; no simple_* equivalent needed |
| Testing Framework | EQA_TEST_SET | Eiffel standard; no simple_* replacement |

### Explicitly AVOID

| What | Why Avoid |
|-----|-----------|
| Gobo LINALG | simple_linalg is maintained and stable; prefer Simple Eiffel |
| Custom math implementations | simple_math exists; reuse not reinvent |
| External C libraries (e.g., LAPACK) | Eiffel-native solutions preferred; maintains portability |

---

## MML Decision

**Question:** Does simple_statistics need MML model queries for precise postconditions?

**Answer:** **YES - Required**

**Rationale:**

simple_statistics has **internal collections** that require frame conditions:
- ASSUMPTION_CHECK arrays in TEST_RESULT
- Residual arrays in REGRESSION_RESULT
- Statistical data arrays (sorted, ranked, etc. in implementations)

**MML Integration Plan:**

For result objects:
```eiffel
class TEST_RESULT
    assumption_checks: ARRAY [ASSUMPTION_CHECK]

    ensure
        -- MML postcondition: no assumption_checks were modified
        Result.assumption_checks |=| old Result.assumption_checks.deep_twin
    end
```

For regression residuals:
```eiffel
class REGRESSION_RESULT
    residuals: ARRAY [REAL_64]

    ensure
        -- All residuals are finite (computed, not modified input)
        Result.residuals.for_all (agent (x) do Result := x.is_finite end)
    end
```

**When Added:** Phase 1 (Foundation); simple_mml added as dependency in ECF.

**User Impact:** None (MML is internal to contracts; users don't interact with it directly).

---

## Success Metrics (v1.0)

| Metric | Target | Why Matters |
|--------|--------|------------|
| **Functionality** | Tier 1 + 80% Tier 2 at v1.0 | Covers 95% of use cases |
| **Test Coverage** | > 95% code coverage | High confidence in correctness |
| **Test Count** | 300+ unit tests | Comprehensive edge case handling |
| **Numerical Accuracy** | Match scipy.stats within 1e-10 for n < 100k | Scientific credibility |
| **Performance** | Competitive with scipy (n < 100k) | Users don't sacrifice speed |
| **Documentation** | 50+ pages; 20+ examples | Users can self-serve learning |
| **Adoption** | 50+ downloads in 3 months | Ecosystem viability |
| **Community Bugs** | 0 critical bugs in first 6 months | Production quality |

---

## Timeline & Phases

| Phase | Duration | Deliverable | Status |
|-------|----------|-------------|--------|
| **0: Intent** | Week 1 | This document | IN PROGRESS |
| **1: Foundation** | Weeks 1-2 | Extract from simple_math; setup CI/CD | Ready to start |
| **2: Tier 1 Core** | Weeks 3-4 | 20 methods; 100+ tests | Specification complete |
| **3: Tier 2 Advanced** | Weeks 5-7 | 5 advanced classes; 150+ tests | Specification complete |
| **4: Testing & Docs** | Weeks 8-9 | 50+ edge case tests; full documentation | Plan ready |
| **5: Release** | Week 10 | v1.0-beta, v1.0.0; announcement | Ready |

**Contingency:** If behind schedule, release v1.0-beta with Tier 1 only; v1.1 adds Tier 2.

---

## Risks & Mitigations (Summary)

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **Numerical instability** | Medium | High | Welford, QR, condition checking; 300+ tests |
| **Performance lag** | High | Medium | Accept trade-off; target n < 100k; document |
| **Test coverage gaps** | Medium | High | Property-based testing; expert review |
| **Timeline slips** | Medium | Medium | Tier-based scope; fail-fast approach |
| **API churn** | Medium | Medium | Freeze Tier 1 early; v1.0-beta feedback loop |

**Risk Overall:** MEDIUM (mitigations in place; manageable)

---

## Gaps Identified (Potential Future simple_* Libraries)

During dependency analysis, the following gaps were identified for potential future Simple Eiffel ecosystem expansion:

| Gap | Current Workaround | Proposed simple_* | Priority |
|-----|-------------------|-------------------|----------|
| No time series library | Custom implementation needed | simple_timeseries | v1.2 |
| No machine learning | Python/R integration required | simple_ml | v2.0 |
| No Bayesian inference | Manual posterior computation | simple_bayesian | v1.2 |

**Recommendation:** Track these as future ecosystem opportunities once simple_statistics ships.

---

## Success Story (Vision)

When complete, an Eiffel developer can:

```eiffel
-- v1.0: Core statistics
stats := create {SIMPLE_STATISTICS}.make
before_data := {ARRAY [REAL_64]} << ... >>
after_data := {ARRAY [REAL_64]} << ... >>

result := stats.t_test_two_sample (before_data, after_data)
if result.is_significant (0.05) then
    print (result.format_for_publication ("paired t-test"))
    -- Output: "t(48) = 2.34, p = .021"
end

-- v1.1: Advanced analysis
robust := create {ROBUST_STATISTICS}.make
outliers := robust.outliers_by_iqr (data)
effect_size := create {EFFECT_SIZES}.make
d := effect_size.cohens_d (group1, group2)

-- v1.2: Bayesian results (future)
-- No need to switch to Python/R
```

**This keeps statistical workflows native to Eiffel while leveraging type safety and Design by Contract.**

---

## Sign-Off

**Project Owner:** Simple Eiffel Team
**Status:** READY FOR PHASE 1 (Foundation/Extraction)
**Next Step:** Run `/eiffel.contracts d:\prod\simple_statistics` to generate class skeletons with contracts

---

**Intent Document Version:** 1.0
**Date Created:** 2026-01-29
**Last Updated:** 2026-01-29
