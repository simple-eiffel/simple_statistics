# Adversarial Test Suggestions for simple_statistics

## Purpose
Identify edge cases, boundary conditions, and stress scenarios that could break the statistical implementations.

## Review Checklist

Generate adversarial tests for:

1. **Boundary Values**
   - Empty arrays (should violate preconditions)
   - Single-element arrays
   - Arrays with two elements
   - Very large arrays (stress test)

2. **Numerical Edge Cases**
   - All identical values (zero variance)
   - Very small numbers (underflow risks)
   - Very large numbers (overflow risks)
   - Mixed magnitudes (Kahan summation importance)

3. **Correlation/Regression Edge Cases**
   - Perfect positive correlation (r = 1.0)
   - Perfect negative correlation (r = -1.0)
   - Zero correlation
   - Single data point (precondition violation)
   - Identical X values (singular matrix in regression)

4. **Hypothesis Testing Edge Cases**
   - Very small sample sizes (n=2)
   - All identical data (zero variance)
   - Extreme differences between groups
   - Single observation in group

5. **Statistical Invariants**
   - Percentile: 0th and 100th percentiles should match min/max
   - Quartiles: Q2 should equal median
   - Variance: variance(data) = mean(squared deviations)
   - Correlation: symmetric - corr(x,y) = corr(y,x)

6. **SCOOP Concurrency**
   - Concurrent calls to different features
   - Shared data access patterns
   - Thread-safe result objects

## Test Categories to Add

1. **Statistical Identity Tests** (verify mathematical properties)
2. **Stress Tests** (large datasets)
3. **Numerical Stability Tests** (precision at extremes)
4. **Concurrent Access Tests** (SCOOP scenarios)

## Expected Outcomes

All adversarial tests should either:
- **PASS**: Implementation is robust
- **FAIL with clear cause**: Precondition violation or expected behavior
- Never **CRASH**: Runtime errors indicate bugs
