# LANDSCAPE: simple_statistics

## Existing Solutions

### Solution 1: SciPy (Python)

| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY |
| Platform | Python 3.9+ |
| URL | https://docs.scipy.org/doc/scipy/reference/stats.html |
| Maturity | MATURE (released 2003, v1.17.0 current) |
| License | BSD-3-Clause |

**Strengths:**
- 100+ probability distributions
- Comprehensive hypothesis testing (40+ tests)
- Effect size calculations
- Non-parametric tests (Mann-Whitney U, Wilcoxon, etc.)
- Highly optimized via NumPy vectorization
- Massive user base (millions of users)
- Extensive documentation and tutorials

**Weaknesses:**
- Dynamic typing (type errors at runtime)
- GIL prevents true parallelism in Python
- No Design by Contract or formal verification
- Requires NumPy, pandas for data handling
- License requires explicit BSD attribution

**Relevance:** 95% - Feature parity is our goal, but with type safety

**Key Algorithms:**
- Welford's algorithm for variance (numerically stable)
- QR decomposition for regression
- Multiple hypothesis testing corrections

---

### Solution 2: NumPy Statistics (Python)

| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY (SUBMODULE) |
| Platform | Python 3.9+ |
| URL | https://numpy.org/doc/stable/reference/routines.statistics.html |
| Maturity | MATURE (integrated with NumPy v1.0+, v2.4 current) |
| License | BSD-3-Clause |

**Strengths:**
- Vectorized operations (extremely fast for large arrays)
- Basic statistics: mean, median, std, var, percentile
- Low-level control over computation
- Part of standard scientific Python stack

**Weaknesses:**
- Limited to descriptive statistics
- No hypothesis testing or hypothesis testing-related functions
- Requires array abstraction (not suitable for small datasets)
- No formal contracts or type safety

**Relevance:** 60% - We'll provide similar API but with type safety

---

### Solution 3: R Base Statistics

| Aspect | Assessment |
|--------|------------|
| Type | LANGUAGE + LIBRARY |
| Platform | R 4.0+ |
| URL | https://www.r-project.org/ |
| Maturity | MATURE (first release 1995, R-4.3 current) |
| License | GPL v2+ |

**Strengths:**
- Comprehensive statistical functions in base R
- Massive ecosystem: 20,000+ packages on CRAN
- Standard in academic statistics
- Designed from ground up for statistics (not retrofitted)
- ggplot2 visualization ecosystem
- Excellent documentation

**Weaknesses:**
- GPL license (some commercial restrictions)
- Slower than compiled languages
- Dynamic typing (type checking at runtime only)
- Steep learning curve for non-statisticians
- Package quality varies widely (no type safety requirement)

**Relevance:** 85% - Gold standard for statistics; we should match functionality

**Key Packages:**
- `base` - core statistics
- `stats` - statistical models and tests
- `forecast` - time series (deferred for simple_statistics v1.1)
- `caret` - machine learning (future simple_ml library)

---

### Solution 4: MATLAB Statistics Toolbox

| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY |
| Platform | MATLAB R2024a+ |
| URL | https://www.mathworks.com/products/statistics.html |
| Maturity | MATURE (MATLAB first released 1984) |
| License | Commercial (expensive) |

**Strengths:**
- Industrial-grade reliability
- Optimization and algorithm efficiency
- GPU acceleration support
- Extensive documentation
- Well-tested algorithms

**Weaknesses:**
- Commercial license ($2,000+/seat)
- Not applicable to open-source Eiffel ecosystem
- Proprietary algorithms (no source access)
- Overkill for small-to-medium datasets

**Relevance:** 20% - Premium option; not accessible to Eiffel community

---

### Solution 5: Octave (MATLAB Alternative)

| Aspect | Assessment |
|--------|------------|
| Type | LANGUAGE + LIBRARY |
| Platform | Linux, macOS, Windows |
| URL | https://www.gnu.org/software/octave/ |
| Maturity | MATURE (first release 1992, v8.4 current) |
| License | GPL v3 |

**Strengths:**
- MATLAB-compatible syntax
- Free and open-source
- Good documentation

**Weaknesses:**
- Slower than MATLAB
- Not type-safe
- No integration with Eiffel ecosystem
- Separate language requirement

**Relevance:** 15% - Not applicable to Eiffel

---

## Eiffel Ecosystem Check

### ISE EiffelStudio Libraries

**EiffelBase:**
- Containers, data structures
- NO statistics module found
- Search: "EiffelBase documentation" → No statistical functions in standard library

**EiffelVision (GUI):**
- Widget library
- NO statistical computation

**EiffelNet (Networking):**
- Network protocols, sockets
- NO statistical functions

**Conclusion:** ISE provides no dedicated statistics library

---

### simple_* Ecosystem Libraries (Existing)

**simple_math:**
- Scalars, transcendental functions (sin, cos, exp, log)
- Contains SIMPLE_STATISTICS class (450 lines) - EMBEDDED
- Not designed for statistics (bundled for convenience)

**simple_probability:**
- Probability distributions (normal, uniform, exponential, etc.)
- Provides CDFs, PDFs, sampling
- No hypothesis testing or statistical analysis
- **Integration Opportunity:** Use distributions for p-values

**simple_calculus:**
- Derivatives, integrals, partial derivatives
- Numerical integration (Monte Carlo, adaptive quadrature)
- **Integration Opportunity:** Integration for distribution functions

**simple_linalg:**
- Vectors, matrices, LU decomposition
- **Integration Opportunity:** Matrix operations for regression, covariance

**Conclusion:** Ecosystem ready for dedicated simple_statistics library; natural composition points exist

---

### Gobo Eiffel Libraries

**EiffelBASE (Gobo equivalent):**
- Data structures: LINKED_LIST, ARRAY, HASH_TABLE
- NO statistics module

**Search Result:** Gobo focused on data structures; no statistical computation

---

## Gap Analysis

**Not Available in Eiffel:**
1. Hypothesis testing framework
2. Effect size calculations
3. Non-parametric statistics
4. Advanced regression (ridge, lasso)
5. Distribution testing (Shapiro-Wilk, Anderson-Darling)
6. Robust statistics methods
7. Correlation and covariance matrices

**Closest Alternative:**
- scipy (requires Python integration; loses type safety)
- Implement yourself (time-consuming, error-prone)

**Conclusion:** Genuine market gap; no competitive solution in Eiffel

---

## Comparison Matrix

| Feature | SciPy | NumPy | R | MATLAB | Eiffel (Current) |
|---------|-------|-------|---|--------|-----------------|
| Descriptive Statistics | ✓ | ✓ | ✓ | ✓ | ✗ |
| Hypothesis Testing | ✓ | ✗ | ✓ | ✓ | ✗ |
| Effect Sizes | ✓ | ✗ | ✓ | ✓ | ✗ |
| Linear Regression | ✓ | Partial | ✓ | ✓ | ✗ |
| Type Safety | ✗ | ✗ | ✗ | ✗ | ✓ (Potential) |
| Design by Contract | ✗ | ✗ | ✗ | ✗ | ✓ (Potential) |
| Concurrency (SCOOP) | ✗ | ✗ | ✗ | ✗ | ✓ (Potential) |
| Free & Open Source | ✓ | ✓ | ✓ | ✗ | ✓ |

---

## Patterns Identified

| Pattern | Seen In | Adopt for simple_statistics? |
|---------|---------|------------------------------|
| Tier 1/2/3 API | R, SciPy (implicit) | **YES** - Progressive complexity |
| Immutable Results | Pure FP languages | **YES** - SCOOP compatibility |
| Distribution Objects | SciPy rv_frozen | **YES** - Composition with simple_probability |
| Matrix Operations | MATLAB, NumPy | **YES** - Leverage simple_linalg |
| Effect Size Objects | R (partially) | **YES** - Type-safe results |
| Assumption Validation | R (via testing) | **YES** - Design by Contract |
| Numerically Stable Algorithms | SciPy (Welford, QR) | **YES** - Use proven methods |

---

## Build vs Buy vs Adapt Analysis

| Option | Effort | Risk | Fit | Cost |
|--------|--------|------|-----|------|
| **BUILD** | 10-17 weeks | Medium (algorithms, testing) | 95% | Developer time only |
| **ADOPT scipy** | 0 weeks | High (Python integration, type safety) | 30% | External dependency |
| **ADAPT Gobo** | 2-3 weeks | Medium (missing features) | 40% | Limited by Gobo scope |
| **WRAP ISE** | 4-6 weeks | Medium (performance, API) | 50% | Incomplete ISE base |
| **Do Nothing** | 0 weeks | High (gap remains, users leave) | 0% | Ecosystem weakens |

---

## Initial Recommendation

**Action: BUILD**

**Rationale:**
1. **Genuine Gap:** No statistical library in Eiffel ecosystem
2. **Type Safety Advantage:** Can enforce contracts; scipy/R cannot
3. **Ecosystem Fit:** Natural composition with simple_probability, simple_calculus, simple_linalg
4. **Community Control:** Simple Eiffel team maintains quality and direction
5. **SCOOP Ready:** Immutable design enables future parallelism (Python's GIL blocks this)

**Timeline:** 10-17 weeks to v1.0 production release

**Dependencies:**
- simple_math (basic functions)
- simple_probability (for p-values, distributions)
- simple_linalg (for regression, covariance)
- simple_calculus (for numerical integration, if needed)

---

**Status:** LANDSCAPE COMPLETE - Ready for REQUIREMENTS research
