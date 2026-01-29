# SCOPE: simple_statistics

## Problem Statement

**Core Problem:** The Simple Eiffel ecosystem lacks a dedicated, type-safe statistical computing library. Currently, SIMPLE_STATISTICS (450 lines) is embedded in simple_math, limiting discoverability and preventing specialized development of statistical features.

**What's Wrong Today:**
- Statistics functionality hidden within simple_math module
- No dedicated API for statistical operations
- Cannot compose cleanly with simple_probability, simple_calculus, simple_linalg
- Difficult to extend without modifying simple_math
- No hypothesis testing, effect sizes, or advanced statistical methods
- Users must implement statistical operations themselves

**Who Experiences This:**
- Data scientists and researchers using Eiffel
- QA engineers performing statistical analysis
- Financial analysts building quantitative systems
- Engineers doing numerical validation

**Impact of Not Solving:**
- Eiffel remains uncompetitive for data-driven applications
- Users forced to use Python/R for statistics, integrating results externally
- Lost opportunity for type-safe, contract-verified statistical operations
- Ecosystem appears incomplete compared to other modern languages

## Target Users

| User Type | Needs | Pain Level |
|-----------|-------|------------|
| Data Scientists | Distributions, hypothesis testing, visualization preparation | HIGH |
| Researchers | Rigorous statistics, academic-grade algorithms, reproducibility | HIGH |
| QA Engineers | Test data analysis, correlation, regression | MEDIUM |
| Financial Analysts | Returns analysis, risk metrics, hypothesis testing | HIGH |
| Systems Engineers | Monitoring data analysis, performance statistics | MEDIUM |

## Success Criteria

| Level | Criterion | Measure |
|-------|-----------|---------|
| MVP | Tier 1 API complete (mean, variance, correlation, basic tests) | 80+ unit tests, 100% pass |
| Full | Tier 2 API complete (robust stats, effect sizes, non-parametric tests) | 300+ unit tests, >95% coverage |
| Excellence | Type-safe, Design by Contract, SCOOP-ready, documented with examples | Code review approval, community adoption |

## Scope Boundaries

### In Scope (MUST)

**Descriptive Statistics:**
- Mean, median, mode, variance, standard deviation
- Quartiles, percentiles, inter-quartile range (IQR)
- Skewness, kurtosis
- Min, max, range, sum

**Correlation & Regression:**
- Pearson correlation coefficient
- Covariance matrix
- Linear regression (ordinary least squares, OLS)
- R², adjusted R², residual analysis

**Hypothesis Testing (Tier 1):**
- One-sample t-test
- Two-sample t-test (independent)
- Paired t-test
- Chi-square goodness of fit
- ANOVA (analysis of variance)

**Integration Points:**
- Composition with simple_probability (p-values from distributions)
- Composition with simple_linalg (matrix operations for regression)
- Composition with simple_calculus (numerical integration if needed)

### In Scope (SHOULD)

**Robust Statistics:**
- Trimmed mean
- Median absolute deviation (MAD)
- Outlier detection methods

**Effect Sizes:**
- Cohen's d (standardized mean difference)
- Eta-squared (proportion of variance explained)
- Cramér's V (association measure)

**Advanced Tests:**
- Shapiro-Wilk (normality test)
- Anderson-Darling
- Kolmogorov-Smirnov test
- Mann-Whitney U (non-parametric)
- Wilcoxon signed-rank test

**Advanced Regression:**
- Weighted least squares
- Ridge regression (L2 regularization)
- Lasso regression (L1 regularization)

### Out of Scope

- **Machine Learning:** Clustering, classification, neural networks (future library: simple_ml)
- **Time Series:** ARIMA, STL decomposition, forecasting (deferred to v1.1+)
- **Bayesian Methods:** MCMC, Gibbs sampling, posterior inference (deferred to v1.2+)
- **Multivariate Analysis:** PCA, factor analysis, canonical correlation (deferred to v2.0+)
- **Visualization:** Plotting, graphing (use simple_vision or external tools)
- **Data Wrangling:** Cleaning, transformation (separate library: simple_data)

### Deferred to Future Versions

- **v1.1:** Time series analysis (ACF, PACF, seasonal decomposition)
- **v1.2:** Bayesian inference (credible intervals, posterior sampling)
- **v2.0:** Multivariate analysis (PCA, clustering, factor analysis)
- **v2.1:** ML integration (cross-validation, model selection, ensemble methods)

## Constraints

| Type | Constraint |
|------|------------|
| **Language** | Eiffel 25.02+ |
| **Type Safety** | void_safety="all" enforced |
| **Design** | Design by Contract (preconditions, postconditions, invariants) |
| **Concurrency** | SCOOP-compatible (immutable results) |
| **Dependencies** | Prefer simple_* ecosystem; minimize external dependencies |
| **Performance** | O(n) descriptive stats; O(n²) regression; O(n log n) for percentiles |
| **Testing** | 100% test coverage target for v1.0 |
| **API Stability** | Once v1.0 released, maintain backward compatibility |
| **Numerical Stability** | Avoid catastrophic cancellation; use stable algorithms (Welford, QR) |

## Assumptions to Validate

| ID | Assumption | Risk if False | Mitigation |
|----|------------|---------------|------------|
| A-1 | Users prefer type-safe statistics over dynamic languages | Users choose Python/R instead | Survey Eiffel community early |
| A-2 | Tier 1 API is sufficient for MVP | Users demand advanced features immediately | Release beta early for feedback |
| A-3 | Numerical stability matters more than raw speed | Users tolerate O(n²) for correctness | Benchmark against scipy, publish results |
| A-4 | Design by Contract doesn't introduce unacceptable overhead | Performance becomes prohibitive | Provide assertion-free finalized versions |
| A-5 | simple_probability/simple_linalg dependencies are stable | Changes break our API | Coordinate with maintainers early |
| A-6 | Eiffel's type system enables cleaner API than Python | Complexity hides benefits | Conduct user study on API clarity |

## Research Questions

- **Problem Domain:** What statistical operations are most commonly needed in Eiffel applications?
- **Existing Solutions:** Do any Eiffel-based statistical libraries already exist (ISE, Gobo, community projects)?
- **Integration:** How can we best compose with simple_probability (distributions) and simple_calculus (integration)?
- **Performance:** At what dataset size does Eiffel become impractical compared to Python/NumPy?
- **Numerical Methods:** Which algorithms provide best accuracy/stability for Eiffel's REAL_64 precision?
- **Testing:** Can we achieve >95% code coverage with 300+ unit tests?
- **Community:** Will Eiffel developers adopt a type-safe statistics library?

## Success Metrics (Post-Launch)

- **Adoption:** 50+ downloads in first 3 months
- **Quality:** 0 critical bugs in first 6 months
- **Maintainability:** <4 hours/month support burden
- **Performance:** Competitive with scipy for datasets < 100k elements
- **Community:** Positive reception, at least 2 external contributors
- **Documentation:** User guide rated >4/5 stars by users

---

**Status:** SCOPE COMPLETE - Ready for LANDSCAPE research
