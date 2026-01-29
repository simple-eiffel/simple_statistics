# Phase 0: Intent Review Request

**Project:** simple_statistics
**Objective:** Generate probing questions to clarify vague language, identify missing requirements, and surface implicit assumptions in the intent document.

## Review Criteria

Look for:
1. **Vague language:** Words like "competitive", "acceptable", "good", "suitable" without concrete definitions
2. **Missing edge cases:** What happens with edge inputs? (empty arrays, single element, infinite values, NaN boundaries)
3. **Untestable criteria:** Are acceptance criteria specific and measurable? (Can you test them?)
4. **Hidden dependencies:** What external systems or assumptions are implicit?
5. **Scope ambiguity:** Is "out of scope" clearly defined and justified?
6. **Performance claims:** Are timing and accuracy claims precise? (How many digits of precision? How fast is "competitive"?)
7. **User assumptions:** Does the intent accurately reflect what users need?

## Output Format

Provide 5-10 probing questions. For each:
1. **Quote the vague phrase** from the intent document
2. **Explain why it's vague** and what impact vagueness has
3. **Offer 2-3 concrete alternatives** the user can choose from
4. **Ask a direct clarifying question**

---

## Intent Document to Review

```markdown
# Intent: simple_statistics

## What

A dedicated statistical library for the Simple Eiffel ecosystem providing type-safe,
contract-based statistical operations. Fills the market gap where Eiffel has no
statistical library equivalent to Python's SciPy or R.

**Core Capabilities:**
- **Tier 1 (MVP):** Descriptive statistics (mean, median, variance, percentiles),
  correlation, linear regression, hypothesis testing (t-test, chi-square, ANOVA)
- **Tier 2 (Extended):** Robust statistics, effect sizes, distribution tests,
  non-parametric tests, advanced regression
- **Tier 3 (Future v1.1+):** Bootstrap, custom tests, Bayesian inference

**Target Dataset Size:** n < 100,000 observations (mid-size analytics)

---

## Why

**Problem:** Eiffel developers doing data analysis must switch to Python/R and
manually integrate results. No native Eiffel statistical library exists.

**Opportunity:** Simple Eiffel has stable foundation libraries (simple_probability,
simple_linalg, simple_calculus) that enable composition. Can provide type safety
and Design by Contract guarantees that Python/R cannot match.

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

## Dependencies (simple_* First Policy)

| Need | Library | Justification |
|------|---------|---------------|
| Math operations | simple_math | 1.0+ |
| Probability distributions | simple_probability | 1.0+ |
| Matrix operations (QR) | simple_linalg | 1.0+ |
| Numerical integration | simple_calculus | 1.0+ |
| Design by Contract (MML) | simple_mml | 1.0+ |

## MML Decision

**Answer:** **YES - Required**

**Rationale:** simple_statistics has internal collections (assumption arrays,
residuals) that require frame conditions documented via MML model queries.
```

## Questions for Review

After reading the intent document above, generate probing questions like this:

---

### Question 1: Numerical Accuracy Definition
**Vague phrase:** "Match scipy.stats within 1e-10 for n < 100k"

**Why it's vague:**
- "Match" could mean absolute error, relative error, or per-operation error
- Different scipy functions have different precision
- 1e-10 might be tight for some operations (percentiles) but loose for others (correlation)

**Concrete alternatives:**
- Option A: "Mean absolute error < 1e-10 on all test cases from scipy.stats benchmark suite"
- Option B: "Relative error < 1e-12 for correlation/regression; 1e-8 for distribution quantiles"
- Option C: "Match scipy to at least 10 significant digits; report any precision differences"

**Question:** Which precision standard will users expect, and how will we measure conformance?

---

### Question 2: Performance Claim
**Vague phrase:** "Competitive with scipy (n < 100k)"

**Why it's vague:**
- "Competitive" undefined: within 2x? 5x? 10x?
- "scipy" is not monolithic: different functions have different speeds
- No specific performance targets or SLAs stated

**Concrete alternatives:**
- Option A: "Within 3x of scipy.stats for descriptive statistics on n < 100k"
- Option B: "Mean computation: < 1 microsecond per element; percentiles: < 10 microseconds per element"
- Option C: "Publish performance benchmarks; document where Eiffel is faster/slower than scipy"

**Question:** What performance expectations do users have, and how will you demonstrate competitive speed?

---

### Question 3: Test Coverage Target
**Vague phrase:** "> 95% code coverage"

**Why it's vague:**
- Code coverage ≠ statement coverage ≠ branch coverage ≠ path coverage
- 95% line coverage might miss complex contracts
- No mention of coverage for error paths (precondition violations)

**Concrete alternatives:**
- Option A: "Line coverage > 95%; branch coverage > 90%; all preconditions tested"
- Option B: "Statement coverage > 95%; 100% coverage of all public features and their contracts"
- Option C: "Mutation testing: catch 95% of introduced mutations (ensure tests are effective, not just comprehensive)"

**Question:** How will you measure coverage, and will error paths (precondition violations) be explicitly tested?

---

### Question 4: "Zero Silent Failures"
**Vague phrase:** "Zero silent failures: NaN/infinity rejection with clear error messages"

**Why it's vague:**
- What counts as a "silent failure"? (NaN in result? Silent NaN skipping? Numerical overflow?)
- What is a "clear error message"? (Precondition text? User-friendly explanation? Stack trace?)
- No specification of error handling for edge cases (empty array, all NaN, single element)

**Concrete alternatives:**
- Option A: "All invalid inputs rejected via precondition violations; no function silently returns NaN or infinity"
- Option B: "When input is invalid, precondition error message explicitly states what's wrong (e.g., 'data_has_no_nan: array contains 3 NaN values at indices [2, 5, 7]')"
- Option C: "CLEANED_STATISTICS utility automatically removes NaN; users must call it explicitly before analysis"

**Question:** How will you handle and communicate errors, and will users be forced to pre-validate data or is automatic cleaning provided?

---

### Question 5: Tier 2 Scope at v1.0
**Vague phrase:** "Tier 1 + 80% Tier 2 at v1.0"

**Why it's vague:**
- Which 80% of Tier 2 features are included? (Robust? Effect sizes? Distribution tests? Non-parametric?)
- What's the prioritization if behind schedule?
- How is "80%" measured? (Number of methods? Classes? Use cases covered?)

**Concrete alternatives:**
- Option A: "v1.0 includes: SIMPLE_STATISTICS, ROBUST_STATISTICS, EFFECT_SIZES, DISTRIBUTION_TESTS; defer NONPARAMETRIC_TESTS and ADVANCED_REGRESSION to v1.1"
- Option B: "Prioritize by user demand: include all Tier 2 classes mentioned in research; defer specialized features (lasso, ridge) to v1.1"
- Option C: "Release v1.0-beta with Tier 1 only; add Tier 2 incrementally in v1.0.1, v1.0.2 point releases"

**Question:** Which Tier 2 classes/features are critical for v1.0, and what's the prioritization for deferral if behind schedule?

---

### Question 6: Adoption Target
**Vague phrase:** "50+ downloads in 3 months (based on ecosystem baseline)"

**Why it's vague:**
- What is the "ecosystem baseline"? (Simple Eiffel downloads per library? Eiffel user base size?)
- Is 50 downloads enough to justify the effort? (Does "success" require higher adoption?)
- How will downloads be tracked? (GitHub releases? ECF downloads?)

**Concrete alternatives:**
- Option A: "Adoption success = 50+ GitHub releases downloaded OR 20+ GitHub stars OR community feedback from 10+ users"
- Option B: "Adopt simple_statistics widely enough that 3+ Simple Eiffel example projects use it"
- Option C: "Measure by: GitHub stars, Eiffel forum mentions, community pull requests, integration into other libraries"

**Question:** How will you measure adoption success, and what download/usage target indicates the library is viable?

---

### Question 7: SCOOP Parallelism (Future)
**Vague phrase:** "Leverages SCOOP for future parallel hypothesis testing (Python's GIL prevents this)"

**Why it's vague:**
- No concrete plan for SCOOP integration in v1.0 or v1.1
- Design says "immutable results enable SCOOP" but no example of actual parallel code
- Unclear if this is a real user need or a theoretical advantage

**Concrete alternatives:**
- Option A: "v1.0 lays foundation (immutable results); v1.1 provides parallel_t_test() using SCOOP futures"
- Option B: "Defer SCOOP parallelism to v1.2; focus v1.0/v1.1 on core functionality"
- Option C: "Document how users can write their own SCOOP parallel wrapper; provide example in v1.0 documentation"

**Question:** Do users actually need parallel hypothesis testing, and will you provide concrete SCOOP examples in v1.1?

---

### Question 8: Educational Value Claims
**Vague phrase:** "Demonstrates Simple Eiffel quality model to scientific computing community"

**Why it's vague:**
- Who is "scientific computing community"? (Academia? R/Python users? Mathematicians?)
- How will you reach them? (Publications? Conferences? Documentation?)
- What does "quality model" mean? (Type safety? DBC? Performance?)

**Concrete alternatives:**
- Option A: "Publish case study comparing simple_statistics DBC to scipy; present at academic conferences"
- Option B: "Create tutorials for statisticians/data scientists transitioning from Python/R to Eiffel"
- Option C: "Contribute examples to Eiffel community; build relationships with academic Eiffel users"

**Question:** What concrete outreach/marketing plan will you execute to demonstrate value to external communities?

---

### Question 9: MML Integration Timing
**Vague phrase:** "When Added: Phase 1 (Foundation); simple_mml added as dependency in ECF."

**Why it's vague:**
- Is simple_mml already available and stable? (Or is this a risk if it's not?)
- What if simple_mml is not ready when Phase 1 starts?
- Should v1.0 be blocked by MML, or is MML optional for v1.0?

**Concrete alternatives:**
- Option A: "Require simple_mml 1.0+ as dependency; if not available, defer MML postconditions to v1.1"
- Option B: "v1.0 includes MML model queries on all collection fields; required before release"
- Option C: "MML is optional enhancement; v1.0 ships without MML, v1.1 adds it if community asks"

**Question:** What's the dependency status of simple_mml, and is MML critical for v1.0 or optional?

---

### Question 10: Backward Compatibility with simple_math
**Vague phrase:** "Maintain backward compatibility in simple_math (deprecate over 2 releases)"

**Why it's vague:**
- When does deprecation start? (v1.0? v1.1?)
- What's the removal timeline? (2 months? 6 months? 1 year?)
- How will existing simple_math users be notified?

**Concrete alternatives:**
- Option A: "simple_math 2.0 (month X): SIMPLE_STATISTICS marked @deprecated; points to simple_statistics library"
- Option B: "simple_math 2.1 (month Y): SIMPLE_STATISTICS removed; existing users must migrate or pin simple_math < 2.1"
- Option C: "Provide migration script/guide; coordinate with simple_math maintainer; announce in release notes"

**Question:** What's the exact deprecation timeline for SIMPLE_STATISTICS in simple_math, and how will users migrate?

---

## Instructions for User

1. Review the questions above
2. Answer each question by choosing one of the concrete alternatives (or your own)
3. Return answers to Claude Code saying "intent review answers:"
4. I will incorporate answers into `intent-v2.md` and proceed to Phase 1

**Expected Time:** 15-20 minutes to answer all questions

---

**Review Document Version:** 1.0
**Date:** 2026-01-29
**Status:** READY FOR REVIEW
