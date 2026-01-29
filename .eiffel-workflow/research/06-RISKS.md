# RISKS: simple_statistics

## Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Contingency |
|----|------|------------|--------|-----------|------------|
| RISK-001 | Numerical instability causes silent wrong answers | MEDIUM | HIGH | Use Welford, QR, condition number checks | Escalate to Tier 3; use numerical libraries |
| RISK-002 | Performance lags Python/NumPy significantly | HIGH | MEDIUM | Optimize hot paths; benchmark; document tradeoffs | Position for mid-sized analytics (n < 100k) |
| RISK-003 | API churn before v1.0 breaks expectations | MEDIUM | MEDIUM | Finalize Tier 1 before v1.0; freeze interface | Release beta; gather early feedback |
| RISK-004 | Incomplete features at v1.0 | MEDIUM | MEDIUM | Clear scope documentation; prioritize by demand | Phase approach (v1.0 Tier 1, 1.1 Tier 2) |
| RISK-005 | Dependency on simple_probability breaks | LOW | MEDIUM | Maintain stable interfaces; coordinate early | Abstract to statistical tables if needed |
| RISK-006 | Test coverage gaps allow bugs in production | MEDIUM | HIGH | 300+ unit tests; property-based testing; code review | Delay v1.0 until > 95% coverage |
| RISK-007 | Users struggle with API complexity | MEDIUM | LOW | Tier-based learning; extensive documentation | Release beginner guide; webinar series |
| RISK-008 | Small user community / adoption | HIGH | MEDIUM | Community outreach; academic partnerships | Ensure library quality for early adopters |

---

## Technical Risks

### RISK-001: Numerical Instability

**Description:**
Floating-point arithmetic can produce wrong answers through catastrophic cancellation:
- Variance computed as E[X²] - E[X]² can lose digits
- Normal equations for regression (X'X)⁻¹ X'y can become ill-conditioned
- Percentiles from naive sorting can be inaccurate

**Likelihood:** MEDIUM
- Occurs with large numbers or small variance
- Most users won't notice (silently wrong)
- scipy/R also have edge cases, but better documented

**Impact:** HIGH
- Wrong statistical answers undermine scientific conclusions
- Users might publish incorrect results
- Damages Simple Eiffel reputation

**Indicators:**
- Results inconsistent with scipy for same data
- User reports of "strange p-values"
- Condition number > 1e12 in regression

**Mitigation:**
1. Use Welford's algorithm for variance (avoids cancellation)
2. Use QR decomposition for regression (numerically stable)
3. Check condition number κ; warn if > 1e12
4. Postconditions verify numerical properties where possible
5. Extensive testing on edge cases (very large/small numbers)
6. Document numerical stability properties for each function

**Contingency:**
- Flag results as "unstable" if κ > threshold
- Escalate to Tier 3 with more robust algorithms
- Offer DEBUG mode with extended precision checking

**Cost:** 2-3 weeks (careful algorithm selection + testing)

---

### RISK-002: Performance Lag Behind Python

**Description:**
Eiffel is compiled but single-threaded. Python/NumPy is vectorized via C/Fortran. For large datasets:
- NumPy mean: ~1 μs per element
- Eiffel native: ~5-10 μs per element
- Gap widens with SCOOP parallelism overhead

**Likelihood:** HIGH
- Eiffel is inherently slower at numerical computing
- Python has 30+ years of optimization

**Impact:** MEDIUM
- Users doing big-data analytics will prefer Python
- But most users do small-to-medium datasets (n < 100k)

**Indicators:**
- User complains "runs too slow"
- Benchmarks show 5-10x slower than Python
- Dataset size > 100k points

**Mitigation:**
1. Target market: mid-sized analytics (n < 100k)
2. Optimize hot paths (variance, percentile, correlation)
3. Benchmark against scipy; publish results
4. Document performance characteristics clearly
5. Recommend Python for large-scale analytics

**Contingency:**
- Offer "fast approximations" (e.g., approximate percentiles)
- Provide Eiffel→Python bridge for big data
- Focus on correctness/safety over speed

**Cost:** Minimal if we accept trade-off; 2-3 weeks if optimizing aggressively

---

### RISK-003: Silent NaN/Invalid Data Bugs

**Description:**
If we're lenient with NaN/invalid data, users might not realize their data is corrupted:
- Function silently skips NaN (wrong sample size)
- Results biased without user knowledge
- Correlation computed on partial pairs

**Likelihood:** MEDIUM
- Depends on our choice (we chose STRICT NaN handling)

**Impact:** MEDIUM
- Users accidentally compute statistics on wrong data
- Results appear reasonable but are wrong

**Indicators:**
- User reports "variance seems off"
- Sample size doesn't match expected
- Correlation computed on 50 pairs but they expected 100

**Mitigation:**
- Strict precondition: No NaN allowed
- Provide CLEANED_STATISTICS utility class
- Clear error messages when NaN detected
- Document data validation expectations

**Contingency:**
- Add optional lenient mode in Tier 3
- Automatic data quality report

**Cost:** Negligible (decision already made)

---

## Ecosystem Risks

### RISK-004: simple_probability Instability

**Description:**
If simple_probability changes API or introduces bugs, our Tier 3 p-value computation breaks.

**Likelihood:** LOW
- simple_probability v1.0 is production-ready
- Clear maintainer communication

**Impact:** MEDIUM
- Tier 3 features become unreliable
- Users lose integration benefits

**Mitigation:**
1. Coordinate with simple_probability maintainer early
2. Use stable interfaces (CDF, quantile functions)
3. Tier 1/2 don't depend on simple_probability (use tables)
4. Clear interface contracts between libraries

**Contingency:**
- Maintain internal statistical tables (redundant but safe)
- Fallback to analytical p-value approximations

**Cost:** 1 week (defensive programming)

---

### RISK-005: Dependency Circular Lock

**Description:**
If simple_probability needs simple_statistics, circular dependency blocks both libraries.

**Likelihood:** LOW
- unlikely simple_probability needs statistics

**Impact:** HIGH
- Build breaks; both libraries unusable
- Ecosystem blocker

**Mitigation:**
1. Define clear dependency graph upfront
2. Communicate with simple_probability team
3. Design to avoid circular dependencies

**Contingency:**
- Refactor one library to break cycle
- Introduce third library (e.g., simple_distributions_core)

**Cost:** Minimal if planned early

---

## Resource Risks

### RISK-006: Test Coverage Gaps

**Description:**
Statistical bugs often hide in edge cases. Without comprehensive testing, bugs reach production.

**Likelihood:** MEDIUM
- 300+ tests is ambitious
- Edge cases are subtle (large numbers, small variance, singular matrices)

**Impact:** HIGH
- Produces wrong statistical answers
- Undermines user trust

**Mitigation:**
1. Target > 95% code coverage
2. Property-based testing (random data generation)
3. Explicit edge case tests (very large, very small numbers)
4. Manual testing against scipy/R on identical datasets
5. Code review by statistician/mathematician

**Contingency:**
- Delay v1.0 release until coverage > 95%
- Community contribution of additional tests

**Cost:** 2-3 weeks (comprehensive test suite)

---

### RISK-007: Knowledge Gap in Team

**Description:**
If developers don't understand numerical analysis or statistics, code will be incorrect.

**Likelihood:** MEDIUM
- Requires expertise in both domains

**Impact:** HIGH
- Subtle bugs in algorithms

**Mitigation:**
1. Documentation: Each algorithm includes paper/reference
2. Code review by domain expert
3. Pair programming with statistician
4. Extensive inline comments
5. Test-driven development (tests first, then code)

**Contingency:**
- Hire external consultant for algorithm review
- Partner with university researcher

**Cost:** 1-2 weeks (expert review)

---

## Timeline & Rollback Risks

### RISK-008: 10-17 Week Timeline Slips

**Description:**
Complex algorithms can take longer to implement correctly than estimated.

**Likelihood:** MEDIUM
- Estimates are optimistic
- Bugs push back timeline

**Impact:** MEDIUM
- Delayed release
- Resources stretched thin

**Mitigation:**
1. Realistic time estimates per feature
2. Prioritize Tier 1 (MVP) over Tier 2/3
3. Incremental releases (v1.0-beta, v1.0, v1.1)
4. Fail fast: if behind schedule, cut scope

**Contingency:**
- Release v1.0-beta with Tier 1 only
- v1.1 adds Tier 2
- v1.2 adds Tier 3

**Cost:** Variable (0-4 weeks depending on scope cut)

---

## Risk Summary

**Overall Risk Level:** MEDIUM

**Top 3 Risks by Impact:**
1. Numerical instability (HIGH impact) → Mitigation: Stable algorithms + testing
2. Test coverage gaps (HIGH impact) → Mitigation: 300+ tests + property-based testing
3. Knowledge gap (HIGH impact) → Mitigation: Expert review + documentation

**Top 3 Risks by Likelihood:**
1. Performance lag (HIGH likelihood) → Mitigation: Accept trade-off; target mid-size analytics
2. Test gaps (MEDIUM likelihood) → Mitigation: Comprehensive testing
3. API churn (MEDIUM likelihood) → Mitigation: Finalize Tier 1 before v1.0

---

**Status:** RISKS COMPLETE - Ready for RECOMMENDATION research
