# CHALLENGED ASSUMPTIONS: simple_statistics

## Assumptions Challenged

### A-001: Tier 1 Should Support 20 Functions

**Assumption from research:** Tier 1 should include mean, median, mode, variance, std_dev, percentiles, quartiles, min/max/range, sum, correlation, covariance, linear regression, and hypothesis tests (t-test, chi-square, ANOVA).

**Challenge:** Is 20 functions too many for "simple" Tier 1? Will it overwhelm users?

**Evidence for:**
- SciPy.stats has 150+ functions; users are overwhelmed by flat API
- Simple Eiffel philosophy: "simple" means focused, not necessarily minimal
- Research shows 80% of statistical use cases covered by descriptive stats + basic tests
- Tier 1 has clear sub-categories (descriptive, correlation, regression, testing)
- 20 functions is manageable if organized well in documentation

**Evidence against:**
- Users might not use all 20 functions
- More functions = more testing, more maintenance
- Could start with 10 functions and add later

**Verdict:** VALID with qualifications
- Keep 20 Tier 1 functions but organize them with clear sub-sections
- Provide beginners' documentation focusing on first 5-10 functions
- Show progression path from simple (mean, median) to complex (regression)

**Action:**
- Create "Getting Started" guide that starts with 5 core functions
- Organize SIMPLE_STATISTICS into feature groups with clear comments
- Document which functions depend on others

---

### A-002: ARRAY [REAL_64] Input is Type-Safe Enough

**Assumption from research:** Strict ARRAY [REAL_64] input satisfies type safety requirement.

**Challenge:** Does rejecting ITERABLE [REAL_64] or LIST [REAL_64] unnecessarily restrict users?

**Evidence for:**
- ARRAY [REAL_64] has O(1) indexed access; enables optimal algorithms
- Type safety is core Simple Eiffel principle
- Users can convert LIST to ARRAY easily
- Aligns with simple_linalg (MATRIX uses ARRAY internally)
- Forces explicit data preparation (good design)

**Evidence against:**
- Users importing CSV data might have LIST first
- Python/R accept any numeric sequence
- Eiffel generics could support ITERABLE [REAL_64]

**Verdict:** VALID
- Keep ARRAY [REAL_64] requirement for v1.0
- Plan utility functions for v1.1 (LIST_TO_ARRAY converter in documentation)
- Note: If performance becomes bottleneck with small datasets, add generic support

**Action:**
- Require ARRAY [REAL_64] in preconditions
- Provide documentation example: "Converting from LIST to ARRAY"
- Keep option open to add generic overloads in v1.1

---

### A-003: Strict NaN Handling (Fail Fast) is Better Than Lenient

**Assumption from research:** Preconditions should reject NaN; no silent skipping.

**Challenge:** Will strict handling frustrate users who have messy data?

**Evidence for:**
- Silent NaN skipping masks data quality issues
- Explicit contract: "data must be clean"
- Easier to debug (fails at obvious point, not later)
- Users appreciate knowing what the function did
- CLEANED_STATISTICS utility class available for convenience

**Evidence against:**
- Python/R silently skip NaN (users expect this)
- Real-world data often has NaN; users want convenience
- Might discourage adoption for quick analyses

**Verdict:** VALID but provide mitigation
- Keep strict NaN handling for v1.0
- Provide CLEANED_STATISTICS utility class that filters NaN
- Plan lenient mode for v1.1 if demanded

**Action:**
- Implement strict precondition checking
- Create CLEANED_STATISTICS class: removes NaN, returns cleaned array
- Document: "Always use CLEANED_STATISTICS for real-world data"

---

### A-004: Design by Contract is Worth the Implementation Cost

**Assumption from research:** Every function should have preconditions, postconditions, and invariants.

**Challenge:** Does comprehensive contracting slow down development? Is the benefit worth the cost?

**Evidence for:**
- Design by Contract is Eiffel core; foundational to quality
- Enables automated testing and verification
- Users get clear error messages (not silent failures)
- Contracts are documentation (users understand guarantees)
- Unique to Eiffel (differentiates from Python/R)
- Enables formal proofs of correctness (future)

**Evidence against:**
- Takes longer to write contracts than naive code
- Contracts must be correct (bugs in contracts = wrong assertions)
- Users might not understand contract violations
- Performance overhead from assertion checking (in DEBUG mode)

**Verdict:** VALID - Design by Contract is essential for library quality
- DBC is non-negotiable (constraint C-003)
- Cost is upfront in implementation; pays off in long-term maintenance
- Eiffel's competitive advantage over Python/R

**Action:**
- Include comprehensive contracts in every public feature
- Write clear precondition/postcondition comments
- Use MML (Mathematical Modeling Language) for postconditions where applicable
- Plan expert review of contracts before v1.0 release

---

### A-005: Tier-Based Architecture (1/2/3) is Better Than Flat API

**Assumption from research:** Three-tier structure (simple/advanced/expert) is better than single monolithic class.

**Challenge:** Does tier separation add complexity or improve usability?

**Evidence for:**
- 80/15/5 user distribution justifies tiers
- Beginners not overwhelmed by advanced options
- Clear learning progression (Tier 1 → Tier 2 → Tier 3)
- Easier to maintain; each tier is testable independently
- Mirrors successful ecosystem patterns (simple_calculus, simple_linalg)
- Documentation can be tier-specific

**Evidence against:**
- Users need to import multiple classes
- More classes = more code to maintain
- Could flatten to single class with optional parameters
- Might fragment community (Tier 1 users vs Tier 2 users)

**Verdict:** VALID - Tier-based architecture is superior
- Tier structure is non-negotiable (decision D-002)
- Manageable import cost (same as simple_calculus)
- Enables incremental adoption and learning

**Action:**
- Proceed with SIMPLE_STATISTICS (Tier 1)
- Plan ROBUST_STATISTICS, EFFECT_SIZES, DISTRIBUTION_TESTS, NONPARAMETRIC_TESTS, ADVANCED_REGRESSION for Tier 2
- Preserve Tier 3 for v1.1+

---

### A-006: Immutable Result Objects Support SCOOP

**Assumption from research:** Immutable TEST_RESULT and REGRESSION_RESULT enable SCOOP parallelism.

**Challenge:** Is immutability necessary? Could we have mutable results with SCOOP guards?

**Evidence for:**
- Immutable objects are SCOOP-safe by definition
- No need for separate guards; no race conditions
- Foundation for future parallel hypothesis testing (v1.1)
- Aligns with functional programming principles
- Simpler to reason about (no side effects)

**Evidence against:**
- Users might want to modify results after creation
- Immutability prevents lazy initialization
- SCOOP guards could allow controlled mutation

**Verdict:** VALID - Immutability is right choice
- Immutability is non-negotiable (constraint C-001: SCOOP-compatible)
- Enables future parallelism without API change
- Cleaner design (results are data, not mutable objects)

**Action:**
- Make all result classes fully immutable
- Use creation routines to initialize all fields
- No setter methods
- Document SCOOP composability in v1.1 roadmap

---

### A-007: 300+ Unit Tests is Achievable by v1.0

**Assumption from research:** v1.0 should have > 95% code coverage with 300+ unit tests.

**Challenge:** Is 300 unit tests feasible in the 10-week timeline?

**Evidence for:**
- 20 Tier 1 functions × 10-15 tests each = 200-300 tests
- Statistical libraries depend heavily on correctness; testing pays off
- Test-driven development (TDD) saves overall time
- Property-based testing (QuickCheck-style) generates tests automatically
- scipy.stats has 1000+ tests; 300 is reasonable subset

**Evidence against:**
- Takes time to write 300+ tests properly
- Each test must handle edge cases (very small, very large, NaN boundary)
- Risk of behind-schedule if testing is slow

**Verdict:** VALID but conditional
- 300+ tests is achievable if TDD approach is followed
- Property-based testing reduces manual test burden
- Prioritize Tier 1 testing; Tier 2 can be deferred to v1.1

**Action:**
- Plan 100+ tests for Tier 1 in v1.0
- Plan 150+ tests for Tier 2 to reach 250+ total
- Use property-based testing for numerical stability verification
- Plan community contribution of tests post-v1.0

---

### A-008: Numerical Stability is Worth Algorithm Complexity

**Assumption from research:** Welford's algorithm, QR decomposition, and condition checking are necessary.

**Challenge:** Should we start simple (naive formulas) and optimize later if users complain?

**Evidence for:**
- scipy/MATLAB use stable algorithms; users expect this
- "Wrong fast" is worse than "slow correct" (statistical correctness is non-negotiable)
- Design by Contract can verify stability properties
- Numerical stability is part of the innovation (I-005)
- Users trust us to give correct answers

**Evidence against:**
- Naive algorithms are simpler (fewer lines of code)
- Optimization can be deferred
- Users doing mid-size analytics (n < 100k) won't notice difference

**Verdict:** VALID - Numerical stability is non-negotiable
- Users trust statistical library for correctness
- Stable algorithms documented in contracts
- Part of core innovation vs. scipy/R
- Cost is upfront; pays off in user trust

**Action:**
- Implement numerically stable algorithms from day 1
- Document algorithm choice with rationale
- Include condition number checks for regression
- Plan numerical stability as validation criterion for v1.0 release

---

## Requirements Questioned

### FR-T1-003: Compute Mode

**Requirement:** mode([1,1,2,3]) = 1

**Question:** Is mode really necessary for Tier 1? It's rarely used.

**Evidence:**
- Mode is a basic descriptive statistic; research marked MUST
- Some statistical analyses need mode (categorical data)
- scipy includes mode; R has Mode function
- Users expect basic descriptive stats to be complete

**Verdict:** KEEP
- Mode is foundational; no reason to remove
- Implementation is O(n log n); negligible cost

---

### FR-T1-019: Handle Missing Data

**Requirement:** Handle NaN or missing values

**Question:** Given strict NaN rejection, is this still relevant?

**Challenge:** "Handle" means reject vs skip. Decision D-006 chose strict rejection.

**Verdict:** MODIFY
- Requirement should be: "Strict precondition: reject NaN with clear error message"
- Add CLEANED_STATISTICS utility for convenience
- No silent skipping; explicit data cleaning required

---

### FR-T2-008 to FR-T2-010: Distribution Tests

**Requirement:** Shapiro-Wilk, Anderson-Darling, Kolmogorov-Smirnov tests

**Question:** Can we implement these correctly without heavy statistics expertise?

**Evidence:**
- All three tests are well-documented in literature
- scipy implements all three; we can reference implementations
- Algorithms are O(n²) or O(n log n); computationally feasible
- Critical for assumption checking (research shows importance)

**Verdict:** KEEP in Tier 2 with expert review
- These are essential for robust statistics
- Plan expert mathematician review before v1.0
- Document algorithm source (paper/reference)

---

## Missing Requirements Identified

| ID | Missing Requirement | How Discovered | Priority |
|----|---------------------|----------------|----------|
| FR-NEW-001 | Utility class to clean NaN from arrays | Strict NaN handling requires workaround | MUST |
| FR-NEW-002 | Seed/random state for bootstrap (Tier 3) | Reproducibility for testing | SHOULD |
| FR-NEW-003 | Numerical stability warnings for condition # | Algorithm documentation requirement | MUST |
| FR-NEW-004 | Assumption checks built-in to TEST_RESULT | Educational value (I-007) | SHOULD |
| FR-NEW-005 | Result formatting for publication (e.g., "t(98)=2.34, p=.022") | I-003 innovation | SHOULD |
| FR-NEW-006 | Confidence intervals (v1.1) | Standard statistical output | DEFER |
| FR-NEW-007 | Regression diagnostics (residual plot data) | Quality assessment | SHOULD |

---

## Design Constraints Validated

| Constraint | Valid? | Notes |
|-----------|--------|-------|
| simple_* first | YES | simple_probability/linalg/calculus are stable; use them |
| SCOOP-compatible | YES | Immutable results enable SCOOP futures (v1.1) |
| void_safety="all" | YES | Required for type safety; no Void everywhere |
| Design by Contract | YES | Core differentiator; essential for quality |
| REAL_64 precision | YES | Double precision standard; sufficient for most analytics |
| Numerical stability | YES | Non-negotiable for statistical correctness |
| Strict NaN handling | YES | Explicit contracts better than silent skipping |

---

**Status:** CHALLENGED ASSUMPTIONS COMPLETE

**Next Step:** Proceed with class design using validated requirements and addressed assumptions.
