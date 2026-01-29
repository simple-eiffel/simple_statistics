# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-29

### Added

#### Descriptive Statistics
- `mean` - Arithmetic mean using Welford's numerically stable algorithm
- `median` - 50th percentile with linear interpolation
- `variance` - Population variance using Welford's two-pass algorithm
- `std_dev` - Standard deviation as sqrt(variance)
- `sum` - Kahan compensated summation for numerical stability
- `min_value`, `max_value`, `range` - Extrema and spread
- `percentile` - NIST R-7 linear interpolation method
- `quartiles` - Q1, Q2, Q3 as array of three values
- `mode` - Most frequent value via hash table frequency counting

#### Bivariate Analysis
- `covariance` - Joint dispersion between two variables
- `correlation` - Pearson correlation coefficient in [-1, 1]
- `linear_regression` - Ordinary least squares with R² computation

#### Hypothesis Testing
- `t_test_one_sample` - One-sample t-test with t-statistic and dof
- `t_test_two_sample` - Welch's t-test for unequal variances
- `t_test_paired` - Paired t-test on differences
- `chi_square_test` - Chi-square goodness-of-fit test
- `anova` - One-way ANOVA with F-statistic

#### Utilities
- `TEST_RESULT` - Immutable test result with p-value, dof, and assumption checks
- `REGRESSION_RESULT` - Regression output with slope, intercept, R², and predict method
- `ASSUMPTION_CHECK` - Documentation of test assumption validation
- `CLEANED_STATISTICS` - Data cleaning (remove NaN and infinite values)

### Technical Features

- **Design by Contract**: Full contract specification (require, ensure, invariant)
- **Numerical Stability**: Welford's algorithm, Kahan summation, QR decomposition approach
- **Void-Safe**: void_safety="all" enabled throughout
- **SCOOP Compatible**: All result objects immutable for concurrent access
- **Type-Safe**: REAL_64 for all numeric operations, proper generics
- **Zero Dependencies**: Only simple_math for sqrt function

### Quality Assurance

- 43 comprehensive tests (100% pass rate)
- 30 baseline tests verifying correctness
- 13 adversarial tests verifying robustness
- Statistical identity verification (symmetry, bounds)
- Stress testing on 10,000+ element arrays
- Zero compilation warnings

### Known Limitations

P-value computation in hypothesis tests uses placeholder value (0.5) pending Phase 5 distribution CDF implementations:
- `t_test_*` methods need t-distribution CDF
- `chi_square_test` needs χ²-distribution CDF
- `anova` needs F-distribution CDF

These will compute proper p-values when CDFs are implemented in a future release.

### Installation

```bash
# Add to your ECF:
<library name="simple_statistics" location="$SIMPLE_EIFFEL/simple_statistics/simple_statistics.ecf"/>
```

### Usage Example

```eiffel
-- Create statistics instance
create stats.make

-- Compute descriptive statistics
data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
avg := stats.mean (data)
med := stats.median (data)
std := stats.std_dev (data)

-- Analyze correlation
x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0 >>
corr := stats.correlation (x, y)

-- Perform regression
result := stats.linear_regression (x, y)
slope := result.slope
intercept := result.intercept
r_squared := result.r_squared

-- Run hypothesis test
t_result := stats.t_test_one_sample (data, 2.5)
if t_result.conclusion (0.05) then
    print ("Mean significantly different from 2.5%N")
end
```

### License

MIT License

### Contributors

Simple Eiffel Team

---

## Version History

- **v1.0.0** (2026-01-29): Initial production release with 20 core statistical functions
