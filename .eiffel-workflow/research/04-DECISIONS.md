# DECISIONS: simple_statistics

## Decision Log

### D-001: Extract vs. Enhance SIMPLE_STATISTICS

**Question:** Should we enhance existing SIMPLE_STATISTICS in simple_math, or extract to new library?

**Options:**
1. **Enhance in place:** Add features to simple_math
   - Pros: No new library to maintain
   - Cons: Statistics hidden in math module; can't specialize; breaks single responsibility
2. **Extract to dedicated library:** Create simple_statistics.ecf
   - Pros: Clean separation; discoverability; specialized development; composition with other libraries
   - Cons: New maintenance burden; requires dependency coordination

**Decision:** EXTRACT to dedicated library

**Rationale:**
- Statistics is distinct domain deserving dedicated curation
- Enables composition with simple_probability, simple_calculus, simple_linalg
- Aligns with Simple Eiffel philosophy (single-responsibility libraries)
- Improves ecosystem discoverability and adoption

**Implications:**
- Create simple_statistics.ecf
- Maintain backward compatibility in simple_math for 1-2 releases
- Coordinate with simple_math maintainer

**Reversible:** NO (once v1.0 released, separation is fixed)

---

### D-002: API Architecture (Monolithic vs. Modular)

**Question:** Single SIMPLE_STATISTICS class, or split into TIER 1/2/3 modules?

**Options:**
1. **Monolithic:** One SIMPLE_STATISTICS class with all methods
   - Pros: Simple import; single facade
   - Cons: 500+ lines per class; mixing concerns
2. **Modular (Tier-based):** SIMPLE_STATISTICS (Tier 1) + ROBUST_STATISTICS, EFFECT_SIZES, etc.
   - Pros: Clear progressions; can skip advanced features; easier to maintain
   - Cons: More imports; slightly more complex

**Decision:** MODULAR (Tier-based)

**Rationale:**
- Mirrors simple_calculus/simple_linalg pattern
- Tier 1 (80% of users) doesn't need Tier 2/3 complexity
- Enables incremental adoption and learning
- Easier testing and documentation per tier

**Implications:**
- 4-5 classes for Tier 1+2
- 10+ classes for full Tier 3
- Clear documented progression

**Reversible:** YES (refactor into monolithic if needed)

---

### D-003: Data Input Format

**Question:** Accept ARRAY [REAL_64], or generic data structure?

**Options:**
1. **ARRAY [REAL_64] only:** Strict Eiffel type
   - Pros: Type-safe; no conversion overhead; clear contracts
   - Cons: Users must convert from other formats
2. **Generic ITERABLE [REAL_64]:** Accept lists, arrays, sequences
   - Pros: Flexible; convenient for users
   - Cons: Reduces type safety; slower (no direct indexing); harder to optimize

**Decision:** ARRAY [REAL_64] (strict)

**Rationale:**
- Type safety is Simple Eiffel principle
- Direct indexing enables optimal algorithms
- Users can easily convert via LIST_TO_ARRAY if needed
- Aligns with simple_linalg (MATRIX, VECTOR use ARRAY internally)

**Implications:**
- Precondition: Require ARRAY [REAL_64]
- Provide utility conversion functions in documentation
- Performance-optimal algorithms enabled

**Reversible:** YES (add overloads for LIST later)

---

### D-004: simple_probability Integration

**Question:** Should we compute p-values using simple_probability distributions, or implement ourselves?

**Options:**
1. **Use simple_probability:** Call distributions.cdf() for p-values
   - Pros: DRY (don't repeat yourself); coordinate with probab library; single source of truth
   - Cons: Tight coupling; requires simple_probability stable; Tier 3 only
2. **Implement independently:** Hard-code statistical tables or numerical approximations
   - Pros: No dependency; self-contained
   - Cons: Duplicate code; harder to maintain; divergence from simple_probability

**Decision:** USE simple_probability (with Tier 3 wrapping)

**Rationale:**
- Tier 1/2 return p-values computed from statistical tables (no external call)
- Tier 3 offers integration with simple_probability for advanced users
- Respects library boundaries while enabling composition

**Implications:**
- Tier 1/2: Use pre-computed p-value tables (t, F, chi-square distributions)
- Tier 3: Offer functions using simple_probability CDF/quantile
- Clear documentation on when each is appropriate

**Reversible:** YES (could decouple if simple_probability changes)

---

### D-005: Numerical Stability Approach

**Question:** How much algorithmic complexity for numerical stability?

**Options:**
1. **Naive:** Standard formulas (simple but numerically unstable)
   - Pros: Fewer lines of code; faster
   - Cons: Catastrophic cancellation; wrong answers on edge cases
2. **Stable:** Welford for variance, QR for regression, etc.
   - Pros: Correct; robust; scientific-grade
   - Cons: More complex; slightly slower; harder to verify

**Decision:** STABLE (use proven algorithms)

**Rationale:**
- Users trust us to give correct answers
- "Wrong fast" is worse than "slow correct"
- scipy.stats uses stable algorithms; we should match
- Design by Contract enables verification of stability assumptions

**Implications:**
- Use Welford's algorithm for variance (not naïve two-pass)
- Use QR decomposition for regression (not normal equations)
- Check condition numbers; warn if > 1e12
- Document each algorithm's stability properties

**Reversible:** YES (could add fast-but-unstable variants if benchmarked)

---

### D-006: Null/NaN Handling

**Question:** How to handle missing data (NaN, empty arrays)?

**Options:**
1. **Strict:** Reject any NaN; raise exception
   - Pros: Explicit contract; no hidden behavior
   - Cons: Users must pre-clean data
2. **Lenient:** Skip NaN silently
   - Pros: Convenient for users
   - Cons: Hidden behavior; could mask data quality issues
3. **Configurable:** Allow both (parameter in each function)
   - Pros: Flexible
   - Cons: API complexity; harder to test

**Decision:** STRICT with utility function for cleaning

**Rationale:**
- Preconditions explicit: "data must not contain NaN"
- Users appreciate knowing what we're doing
- Offer CLEANED_STATISTICS class for convenience

**Implications:**
- Precondition: `data.for_all (agent (x) do Result := not x.is_nan end)`
- CLEANED_STATISTICS utility class to filter NaN before passing
- Clear documentation of expectations

**Reversible:** YES (add lenient mode later if demanded)

---

### D-007: Result Type Strategy

**Question:** Return (statistic, p_value) tuples, or typed result classes?

**Options:**
1. **Tuples:** TUPLE [t: REAL_64; p: REAL_64]
   - Pros: Simple; few lines of code
   - Cons: Type-unsafe (access by index); no documentation in result; error-prone
2. **Typed Results:** CLASS TEST_RESULT with fields and methods
   - Pros: Type-safe; self-documenting; can add methods (conclusion, format, etc.)
   - Cons: More classes; more code

**Decision:** TYPED RESULTS

**Rationale:**
- Type safety is core Simple Eiffel principle
- Results become first-class citizens (testable, documentable, extensible)
- Methods like `result.conclusion(α: REAL_64): BOOLEAN` are natural
- Mirrors simple_linalg (MATRIX, VECTOR are classes not tuples)

**Implications:**
- Create TEST_RESULT, REGRESSION_RESULT, etc. classes
- 4-6 result types for Tier 1+2
- Each result class has methods for interpretation (conclusion, format, etc.)

**Reversible:** YES (could flatten to tuples if performance critical)

---

## Decision Summary

| ID | Decision | Impact | Confidence |
|----|----------|--------|-----------|
| D-001 | Extract to simple_statistics.ecf | Architecture | HIGH |
| D-002 | Modular Tier-based API | API | HIGH |
| D-003 | ARRAY [REAL_64] input | Type Safety | HIGH |
| D-004 | Use simple_probability for p-values | Integration | MEDIUM |
| D-005 | Numerically stable algorithms | Quality | HIGH |
| D-006 | Strict NaN handling | Contract | HIGH |
| D-007 | Typed result classes | Type Safety | HIGH |

---

**Status:** DECISIONS COMPLETE - Ready for INNOVATIONS research
