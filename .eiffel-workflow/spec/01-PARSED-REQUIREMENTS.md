# PARSED REQUIREMENTS: simple_statistics

## Problem Summary

Statistical functionality currently embedded in `simple_math.SIMPLE_STATISTICS` needs extraction into a dedicated library. This addresses a genuine market gap: Eiffel has no statistical library while Python (SciPy), R, and MATLAB dominate. The Simple Eiffel ecosystem is positioned to provide type-safe, contract-based statistics with SCOOP-ready architecture.

## Scope

### In Scope
- **Tier 1 (MVP)**: Core descriptive statistics, correlation, regression, basic hypothesis testing
- **Tier 2 (Extended)**: Robust statistics, effect sizes, distribution tests, non-parametric tests
- **Tier 3 (Expert)**: Custom hypothesis tests, bootstrap, Bayesian inference (v1.1+)
- **Composition**: Integration with simple_probability, simple_linalg, simple_calculus
- **Type Safety**: void_safety="all", ARRAY [REAL_64] input, immutable result objects
- **Design by Contract**: Full preconditions, postconditions, invariants on all public features

### Out of Scope
- Machine learning (that's simple_ml, future library)
- Time series analysis (defer to v1.1)
- Streaming analytics (defer to v1.2)
- External dependencies beyond simple_probability/linalg/calculus
- Bayesian methods in v1.0 (defer to v1.2)

### Deferred to Future Versions
- v1.1: Tier 3 custom tests, bootstrap, time series (ACF, PACF, ARIMA)
- v1.2: Bayesian credible intervals, posterior inference
- v1.3: Streaming analytics, online algorithms

## Functional Requirements

### Tier 1 Requirements (MUST for v1.0)
| ID | Requirement | Category | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T1-001 | Compute arithmetic mean | Descriptive | mean([1,2,3]) = 2.0 |
| FR-T1-002 | Compute median | Descriptive | median([1,2,3,4,5]) = 3.0 |
| FR-T1-003 | Compute mode | Descriptive | mode([1,1,2,3]) = 1.0 |
| FR-T1-004 | Compute variance | Descriptive | variance([1,2,3]) = 1.0 |
| FR-T1-005 | Compute standard deviation | Descriptive | std_dev([1,2,3]) ≈ 1.0 |
| FR-T1-006 | Compute quartiles (Q1, Q2, Q3) | Descriptive | quartiles([1..100]) = [25.5, 50.5, 75.5] |
| FR-T1-007 | Compute arbitrary percentiles | Descriptive | percentile([1..100], 75) ≈ 75 |
| FR-T1-008 | Compute min, max, range | Descriptive | min/max/range work correctly |
| FR-T1-009 | Compute sum | Descriptive | sum([1,2,3]) = 6.0 |
| FR-T1-010 | Pearson correlation | Correlation | correlation(x, y) ∈ [-1, 1] |
| FR-T1-011 | Covariance | Correlation | covariance(x, y) is numeric |
| FR-T1-012 | Linear regression (OLS) | Regression | Fit y = mx + b with R² |
| FR-T1-013 | Coefficient of determination | Regression | r_squared ∈ [0, 1] |
| FR-T1-014 | One-sample t-test | Hypothesis Testing | Test μ = μ₀; return t, p, d.o.f |
| FR-T1-015 | Two-sample t-test | Hypothesis Testing | Test μ₁ = μ₂; return t, p, d.o.f |
| FR-T1-016 | Paired t-test | Hypothesis Testing | Test mean(diff) = 0; return t, p, d.o.f |
| FR-T1-017 | Chi-square test | Hypothesis Testing | Test categorical fit; return χ², p, d.o.f |
| FR-T1-018 | ANOVA | Hypothesis Testing | Test >2 groups; return F, p, d.o.f |
| FR-T1-019 | Handle missing data | Data Quality | Strict: reject NaN with error message |
| FR-T1-020 | Handle empty data | Data Quality | Raise EMPTY_DATASET exception |

### Tier 2 Requirements (SHOULD for v1.0)
| ID | Requirement | Category | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T2-001 | Trimmed mean | Robust Stats | Mean excluding top/bottom k% |
| FR-T2-002 | Median absolute deviation | Robust Stats | MAD ≥ 0, robust to outliers |
| FR-T2-003 | Outlier detection (IQR) | Robust Stats | Identify Q3 + 1.5×IQR outliers |
| FR-T2-004 | Outlier detection (Z-score) | Robust Stats | Flag where \|z\| > 3 |
| FR-T2-005 | Cohen's d | Effect Size | Standardized mean difference |
| FR-T2-006 | Eta-squared | Effect Size | Variance proportion explained |
| FR-T2-007 | Cramér's V | Effect Size | Categorical association [0, 1] |
| FR-T2-008 | Shapiro-Wilk test | Distribution Tests | Normality test; return statistic, p |
| FR-T2-009 | Anderson-Darling test | Distribution Tests | Alternative normality test |
| FR-T2-010 | Kolmogorov-Smirnov test | Distribution Tests | Test vs reference distribution |
| FR-T2-011 | Mann-Whitney U test | Non-parametric | Alternative to t-test |
| FR-T2-012 | Wilcoxon signed-rank test | Non-parametric | Paired non-parametric test |
| FR-T2-013 | Kruskal-Wallis test | Non-parametric | Alternative to ANOVA |
| FR-T2-014 | Weighted least squares | Advanced Regression | Regression with weights |
| FR-T2-015 | Ridge regression | Advanced Regression | Regression with L2 regularization |
| FR-T2-016 | Lasso regression | Advanced Regression | Regression with L1 regularization |
| FR-T2-017 | Skewness | Distribution Shape | Asymmetry measure |
| FR-T2-018 | Kurtosis | Distribution Shape | Tail behavior measure |
| FR-T2-019 | Multiple testing correction | Correction Methods | Bonferroni, FDR, Holm |

### Tier 3 Requirements (COULD for v1.1+)
| ID | Requirement | Category | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-T3-001 | p-value from t-statistic | Custom Tests | Use simple_probability CDF |
| FR-T3-002 | Critical value computation | Custom Tests | Inverse CDF for significance level |
| FR-T3-003 | Custom test framework | Custom Tests | Infrastructure for user-defined tests |
| FR-T3-004 | Bootstrap resampling | Resampling | Confidence intervals via resampling |
| FR-T3-005 | Permutation testing | Resampling | Non-parametric alternative |
| FR-T3-006 | Bayesian credible intervals | Bayesian | Posterior inference (v1.2) |

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | Language version | Technical | EiffelStudio | 25.02+ |
| NFR-002 | Type safety | Technical | void_safety | "all" |
| NFR-003 | Design by Contract | Technical | Coverage | 100% public features |
| NFR-004 | SCOOP compatibility | Concurrency | Mutability | All results immutable |
| NFR-005 | Numerical stability | Accuracy | Condition number | Warn if κ > 1e12 |
| NFR-006 | Performance (descriptive) | Speed | Time complexity | O(n) for mean, variance |
| NFR-007 | Performance (percentiles) | Speed | Time complexity | O(n log n) sorting-based |
| NFR-008 | Performance (regression) | Speed | Time complexity | O(n²) for n < 100k |
| NFR-009 | Test coverage | Testing | Code coverage | > 95% |
| NFR-010 | Unit tests | Testing | Test count | 300+ for v1.0 |
| NFR-011 | Documentation | Documentation | User guide | 50+ pages |
| NFR-012 | Code examples | Documentation | Runnable examples | 20+ |
| NFR-013 | Algorithm docs | Documentation | Theory reference | Each algo documented |
| NFR-014 | API stability | Compatibility | Versioning | SEMVER (v1.0+) |
| NFR-015 | Backward compatibility | Compatibility | Deprecation | Graceful path from simple_math |
| NFR-016 | Dependency stability | Ecosystem | Coordination | With simple_* maintainers |

## Constraints (Non-Negotiable)

| ID | Constraint | Type | Rationale |
|----|-----------|------|-----------|
| C-001 | SCOOP-compatible | Technical | Eiffel concurrency standard |
| C-002 | void_safety="all" | Technical | Type safety requirement |
| C-003 | Design by Contract | Technical | Eiffel ecosystem standard |
| C-004 | Prefer simple_* | Ecosystem | Align with Simple Eiffel philosophy |
| C-005 | Handle NaN/Inf | Technical | IEEE 754 standard compliance |
| C-006 | Limited external dependencies | Technical | Only simple_probability/linalg/calculus allowed |
| C-007 | REAL_64 precision | Technical | Double precision standard |
| C-008 | Open source license | Legal | MIT or GPL (Simple Eiffel standard) |

## Decisions Already Made

| ID | Decision | Rationale | From Research |
|----|----------|-----------|----------------|
| D-001 | Extract to simple_statistics.ecf | Statistics deserves dedicated library; enables composition | 04-DECISIONS.md |
| D-002 | Modular Tier-based API | Mirrors simple_calculus/linalg; supports progressive learning | 04-DECISIONS.md |
| D-003 | ARRAY [REAL_64] input (strict) | Type safety; optimal algorithms; users can convert | 04-DECISIONS.md |
| D-004 | Use simple_probability (Tier 3) | Tier 1/2 use tables; Tier 3 integrates with library | 04-DECISIONS.md |
| D-005 | Numerically stable algorithms | Users trust correctness over speed; use Welford, QR | 04-DECISIONS.md |
| D-006 | Strict NaN handling | Explicit contracts; no hidden behavior; CLEANED_STATISTICS utility | 04-DECISIONS.md |
| D-007 | Typed result classes | Type-safe; self-documenting; extensible (not tuples) | 04-DECISIONS.md |

## Innovations to Implement

| ID | Innovation | Design Impact |
|----|------------|---------------|
| I-001 | Design by Contract for statistics | Every function has pre/post/invariant; formal verification possible |
| I-002 | Tier-based progressive learning | Users start with Tier 1; graduate to Tier 2/3; clear progression |
| I-003 | Type-safe result objects | TEST_RESULT, REGRESSION_RESULT classes with methods (not tuples) |
| I-004 | Composition with Simple Eiffel | Uses simple_probability, simple_linalg, simple_calculus naturally |
| I-005 | Numerically stable algorithms | Welford, QR, condition number checks; correctness prioritized |
| I-006 | SCOOP-ready architecture | Immutable results; no shared mutable state; futures possible |
| I-007 | Built-in educational value | Assumption documentation; when/why to use each test |

## Risks to Address in Design

| ID | Risk | Likelihood | Impact | Mitigation Strategy |
|----|------|------------|--------|---------------------|
| RISK-001 | Numerical instability | Medium | High | Use Welford, QR, condition checks; 300+ tests |
| RISK-002 | Performance lag behind Python | High | Medium | Accept trade-off; target n < 100k; document |
| RISK-003 | Silent NaN bugs | Medium | Medium | Strict preconditions; CLEANED_STATISTICS utility |
| RISK-004 | simple_probability dependency | Low | Medium | Maintain stable interfaces; Tier wrapping strategy |
| RISK-005 | Test coverage gaps | Medium | High | 300+ tests; property-based testing; expert review |
| RISK-006 | Knowledge/expertise gaps | Medium | High | Documentation per algorithm; expert review; pair programming |
| RISK-007 | API churn before v1.0 | Medium | Medium | Freeze Tier 1 early; beta release for feedback |
| RISK-008 | Timeline slips | Medium | Medium | Fail fast; release v1.0-beta with Tier 1 only; v1.1 for Tier 2 |

## Use Cases

### UC-001: Data Analyst Computes Basic Statistics
**Actor:** Data scientist with dataset
**Precondition:** ARRAY [REAL_64] data without NaN values
**Main Flow:**
1. Create SIMPLE_STATISTICS instance
2. Call mean(data), std_dev(data), percentiles
3. Interpret results directly
**Postcondition:** Summary statistics computed and verified by contracts

### UC-002: Researcher Tests Hypothesis
**Actor:** Researcher comparing two groups
**Precondition:** Two ARRAY [REAL_64] datasets, no NaN, n ≥ 2 each
**Main Flow:**
1. Create SIMPLE_STATISTICS instance
2. Call t_test_two_sample(group1, group2)
3. Check result.p_value < 0.05 for significance
4. Call result.conclusion(0.05) for automated decision
**Postcondition:** TEST_RESULT with statistic, p_value, d.o.f, conclusion method

### UC-003: Advanced User Does Robust Analysis
**Actor:** Statistician checking assumptions
**Precondition:** SIMPLE_STATISTICS test result
**Main Flow:**
1. Use DISTRIBUTION_TESTS.shapiro_wilk(data) to check normality
2. Use ROBUST_STATISTICS.outliers_iqr(data) to detect outliers
3. Fall back to NONPARAMETRIC_TESTS.mann_whitney_u if assumptions fail
**Postcondition:** Robust statistical decision with assumption validation

### UC-004: Researcher Fits Linear Model
**Actor:** Analyst with predictor and response variables
**Precondition:** ARRAY [REAL_64] x, y; same length; no NaN
**Main Flow:**
1. Create SIMPLE_STATISTICS instance
2. Call linear_regression(x, y)
3. Inspect result.slope, result.intercept, result.r_squared
4. Use result.predict(new_x) for predictions
**Postcondition:** REGRESSION_RESULT with model parameters and prediction method

---

**Status:** PARSED REQUIREMENTS COMPLETE
