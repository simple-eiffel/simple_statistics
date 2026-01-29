# Eiffel Contract Review Request (Ollama)

## Context

You are reviewing **Eiffel Design by Contract** specifications for a statistical library (`simple_statistics` v1.0). Find obvious problems with the contracts before implementation begins.

## Review Checklist

- [ ] Preconditions that are just `True` (too weak to enforce anything)
- [ ] Postconditions that don't constrain anything (always satisfied regardless of implementation)
- [ ] Postconditions that assume implementation details instead of just constraining outputs
- [ ] Missing invariants on classes with mutable state
- [ ] Frame conditions: What did NOT change? Missing `old` expressions?
- [ ] Edge cases not handled by preconditions (empty arrays, single element, negatives, zeros, infinity, NaN)
- [ ] Obvious dead code or impossible conditions
- [ ] Contradictions between preconditions and postconditions
- [ ] Missing MML model queries for collection attributes (arrays, tables, lists)

## Contracts to Review

### File 1: statistics.e (Main Facade Class)

```eiffel
note
	description: "Core statistical operations for descriptive analysis, correlation, regression, and hypothesis testing."
	author: "Simple Eiffel Team"
	license: "MIT"

class STATISTICS

create
	make

feature {NONE} -- Initialization

	make
			-- Create instance. Stateless; no configuration needed.
		do
		ensure
			instance_created: True
		end

feature -- Descriptive Statistics

	mean (data: ARRAY [REAL_64]): REAL_64
			-- Arithmetic mean using numerically stable summation.
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Implement using numerically stable summation
			Result := 0.0
		ensure
			result_valid: True  -- result is finite
		end

	median (data: ARRAY [REAL_64]): REAL_64
			-- Middle value (50th percentile).
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Implement via sorted array
			Result := 0.0
		ensure
			result_valid: True  -- result is within data range
		end

	mode (data: ARRAY [REAL_64]): REAL_64
			-- Most frequent value (may not be unique for multimodal data).
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Implement frequency counting
			Result := 0.0
		ensure
			result_in_data: data.has (Result)
		end

	variance (data: ARRAY [REAL_64]): REAL_64
			-- Population variance using Welford's algorithm (numerically stable).
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Implement Welford's algorithm
			Result := 0.0
		ensure
			result_non_negative: Result >= 0.0
		end

	std_dev (data: ARRAY [REAL_64]): REAL_64
			-- Standard deviation = sqrt(variance).
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Return sqrt(variance(data))
			Result := 0.0
		ensure
			result_non_negative: Result >= 0.0
		end

	percentile (data: ARRAY [REAL_64]; p: REAL_64): REAL_64
			-- p-th percentile where p ∈ [0, 100].
		require
			data_not_empty: not data.is_empty
			percentile_valid: p >= 0.0 and p <= 100.0
		do
			-- TODO: Phase 4 - Implement percentile via linear interpolation
			Result := 0.0
		ensure
			result_valid: True  -- result is within data range
		end

	quartiles (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Q1, Q2 (median), Q3 as array of 3 values.
		require
			data_not_empty: not data.is_empty
			sufficient_data: data.count >= 4
		do
			-- TODO: Phase 4 - Return quartiles using percentile function
			create Result.make_empty
			Result.force (0.0, 1)
			Result.force (0.0, 2)
			Result.force (0.0, 3)
		ensure
			result_size: Result.count = 3
			ordered: Result [1] <= Result [2] and Result [2] <= Result [3]
		end

	min_value (data: ARRAY [REAL_64]): REAL_64
			-- Minimum value in dataset.
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Return minimum
			Result := 0.0
		ensure
			result_valid: True  -- result is valid
		end

	max_value (data: ARRAY [REAL_64]): REAL_64
			-- Maximum value in dataset.
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Return maximum
			Result := 0.0
		ensure
			result_valid: True  -- result is valid
		end

	range (data: ARRAY [REAL_64]): REAL_64
			-- max - min (spread).
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Return max - min
			Result := 0.0
		ensure
			result_non_negative: Result >= 0.0
		end

	sum (data: ARRAY [REAL_64]): REAL_64
			-- Sum of all values.
		require
			data_not_empty: not data.is_empty
		do
			-- TODO: Phase 4 - Return sum
			Result := 0.0
		ensure
			result_valid: True  -- result is finite
		end

feature -- Correlation & Covariance

	correlation (x, y: ARRAY [REAL_64]): REAL_64
			-- Pearson correlation coefficient in [-1, 1].
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		do
			-- TODO: Phase 4 - Implement Pearson correlation
			Result := 0.0
		ensure
			result_valid: True  -- result is valid
		end

	covariance (x, y: ARRAY [REAL_64]): REAL_64
			-- Covariance between x and y.
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		do
			-- TODO: Phase 4 - Implement covariance
			Result := 0.0
		ensure
			result_valid: True  -- result is finite
		end

feature -- Regression

	linear_regression (x, y: ARRAY [REAL_64]): REGRESSION_RESULT
			-- Ordinary least squares regression using QR decomposition (numerically stable).
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 3
		do
			-- TODO: Phase 4 - Implement via QR decomposition
			create Result.make (0.0, 0.0, 0.0, x, 1.0)
		ensure
			result_valid: Result /= Void
			r2_valid: Result.r_squared >= 0.0 and Result.r_squared <= 1.0
		end

feature -- Hypothesis Testing

	t_test_one_sample (data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT
			-- One-sample t-test: H0: mu = mu_0.
		require
			data_not_empty: not data.is_empty
			sufficient_data: data.count >= 2
		do
			-- TODO: Phase 4 - Implement one-sample t-test
			create Result.make (0.0, 0.5, data.count - 1, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
			dof_correct: Result.degrees_of_freedom = data.count - 1
		end

	t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
			-- Two-sample t-test: H0: mu1 = mu2.
		require
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2 and y.count >= 2
		do
			-- TODO: Phase 4 - Implement two-sample t-test
			create Result.make (0.0, 0.5, x.count + y.count - 2, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			dof_correct: Result.degrees_of_freedom = x.count + y.count - 2
		end

	t_test_paired (x, y: ARRAY [REAL_64]): TEST_RESULT
			-- Paired t-test: H0: mu_diff = 0.
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		do
			-- TODO: Phase 4 - Implement paired t-test
			create Result.make (0.0, 0.5, x.count - 1, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			dof_correct: Result.degrees_of_freedom = x.count - 1
		end

	chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
			-- Chi-square goodness-of-fit test.
		require
			same_length: observed.count = expected.count
			data_valid: not observed.is_empty
		do
			-- TODO: Phase 4 - Implement chi-square test
			create Result.make (0.0, 0.5, observed.count - 1, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
			dof_correct: Result.degrees_of_freedom = observed.count - 1
		end

	anova (groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
			-- One-way ANOVA: H0: all group means are equal.
		require
			sufficient_groups: groups.count >= 3
		do
			-- TODO: Phase 4 - Implement one-way ANOVA
			create Result.make (0.0, 0.5, 1, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
		end

invariant
	-- Stateless: no invariant on object state
	instance_valid: True

end
```

### File 2: test_result.e (Test Result Class)

```eiffel
note
	description: "Immutable result of hypothesis test with significance testing and formatting."
	author: "Simple Eiffel Team"
	license: "MIT"

class TEST_RESULT

create
	make

feature -- Access

	statistic: REAL_64
			-- Test statistic value (t, F, χ², U, etc.).

	p_value: REAL_64
			-- p-value: probability of observing statistic under H₀.

	degrees_of_freedom: INTEGER
			-- Degrees of freedom for the test.

	assumption_checks: ARRAY [ASSUMPTION_CHECK]
			-- Validation of test assumptions.

feature -- Interpretation

	conclusion (alpha: REAL_64): BOOLEAN
			-- Is null hypothesis rejected at significance level alpha?
			-- True means reject H₀ (result is significant).
		require
			alpha_valid: alpha > 0.0 and alpha < 1.0
		do
			Result := p_value < alpha
		ensure
			result_defined: Result = (p_value < alpha)
		end

	is_significant (alpha: REAL_64): BOOLEAN
			-- Alias for conclusion (alpha).
		require
			alpha_valid: alpha > 0.0 and alpha < 1.0
		do
			Result := conclusion (alpha)
		ensure
			result_defined: Result = conclusion (alpha)
		end

feature -- Formatting

	format_for_publication (test_name: STRING): STRING
			-- Format result for academic publication (e.g., "t(98)=2.34, p=.022").
		require
			test_name_valid: not test_name.is_empty
		do
			-- TODO: Phase 4 - Format as "test_name(dof)=stat, p=pval"
			Result := ""
		ensure
			result_valid: not Result.is_empty
		end

feature {NONE} -- Creation

	make (a_stat: REAL_64; a_p: REAL_64; a_dof: INTEGER; a_checks: ARRAY [ASSUMPTION_CHECK])
			-- Create test result.
		require
			p_valid: a_p >= 0.0 and a_p <= 1.0
			dof_valid: a_dof >= 1
			stat_valid: True  -- statistic validated in implementation
			checks_not_void: a_checks /= Void
		do
			statistic := a_stat
			p_value := a_p
			degrees_of_freedom := a_dof
			assumption_checks := a_checks
		ensure
			statistic_set: statistic = a_stat
			p_value_set: p_value = a_p
			dof_set: degrees_of_freedom = a_dof
		end

invariant
	p_value_valid: p_value >= 0.0 and p_value <= 1.0
	dof_valid: degrees_of_freedom >= 1
	statistic_valid: True  -- statistic is ensured finite by contract
	assumption_checks_not_void: assumption_checks /= Void

end
```

### File 3: regression_result.e (Regression Result Class)

```eiffel
note
	description: "Immutable result of regression analysis with diagnostics and prediction."
	author: "Simple Eiffel Team"
	license: "MIT"

class REGRESSION_RESULT

create
	make

feature -- Model Parameters

	slope: REAL_64
			-- Regression coefficient (change in y per unit change in x).

	intercept: REAL_64
			-- y-intercept (predicted y when x = 0).

	r_squared: REAL_64
			-- Coefficient of determination: proportion of variance explained.

feature -- Diagnostics

	residuals: ARRAY [REAL_64]
			-- Differences: observed_y - predicted_y.

	condition_number: REAL_64
			-- Condition number of design matrix; measure of numerical stability.
			-- κ < 10: excellent; κ < 1e12: acceptable; κ > 1e12: ill-conditioned.

feature -- Prediction & Validation

	predict (x: REAL_64): REAL_64
			-- Predict y for given x using fitted model.
		require
			x_valid: True  -- x validated in implementation
		do
			Result := slope * x + intercept
		ensure
			result_valid: True  -- result is finite
		end

	is_numerically_stable: BOOLEAN
			-- Is condition number acceptable (< 1e12)?
		do
			Result := condition_number < 1000000000000.0
		ensure
			result_defined: Result = (condition_number < 1000000000000.0)
		end

feature {NONE} -- Creation

	make (a_slope: REAL_64; a_intercept: REAL_64; a_r2: REAL_64;
			a_residuals: ARRAY [REAL_64]; a_condition: REAL_64)
			-- Create regression result.
		require
			r2_valid: a_r2 >= 0.0 and a_r2 <= 1.0 + 0.0000000001
			slopes_valid: True  -- slopes validated in implementation
			condition_non_negative: a_condition >= 1.0
			residuals_not_void: a_residuals /= Void
		do
			slope := a_slope
			intercept := a_intercept
			r_squared := a_r2
			residuals := a_residuals
			condition_number := a_condition
		ensure
			slope_set: slope = a_slope
			intercept_set: intercept = a_intercept
			r2_set: r_squared = a_r2
		end

invariant
	r_squared_valid: r_squared >= 0.0 and r_squared <= 1.0 + 0.0000000001
	slopes_valid: True  -- slopes are finite
	condition_positive: condition_number >= 1.0
	residuals_not_void: residuals /= Void

end
```

### File 4: assumption_check.e (Assumption Check Class)

```eiffel
note
	description: "Document single assumption validation for hypothesis test."
	author: "Simple Eiffel Team"
	license: "MIT"

class ASSUMPTION_CHECK

create
	make

feature -- Access

	name: STRING
			-- Assumption name (e.g., "normality", "equal_variance").

	passed: BOOLEAN
			-- Was assumption satisfied?

	detail: STRING
			-- Explanation if failed; empty if passed.

feature {NONE} -- Creation

	make (a_name: STRING; a_passed: BOOLEAN; a_detail: STRING)
			-- Create assumption check record.
		require
			name_valid: a_name /= Void
			detail_not_void: a_detail /= Void
		do
			name := a_name
			passed := a_passed
			detail := a_detail
		ensure
			name_set: name = a_name
			passed_set: passed = a_passed
			detail_set: detail = a_detail
		end

invariant
	name_not_empty: name /= Void and not name.is_empty
	detail_not_void: detail /= Void
	detail_consistency: (not passed) implies (not detail.is_empty)

end
```

### File 5: cleaned_statistics.e (Data Cleaning Utility)

```eiffel
note
	description: "Utility class to remove NaN and infinite values from arrays for convenient data cleaning."
	author: "Simple Eiffel Team"
	license: "MIT"

class CLEANED_STATISTICS

create
	make

feature {NONE} -- Initialization

	make
			-- Create instance.
		do
		ensure
			instance_created: True
		end

feature -- Data Cleaning

	remove_nan (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all NaN values removed.
		require
			input_valid: data /= Void
		do
			-- TODO: Phase 4 - Filter out NaN values
			create Result.make_empty
		ensure
			result_valid: not has_nan (Result)
			result_size: Result.count <= data.count
		end

	remove_infinite (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all infinite values removed.
		require
			input_valid: data /= Void
		do
			-- TODO: Phase 4 - Filter out infinite values
			create Result.make_empty
		ensure
			result_valid: not has_infinite (Result)
			result_size: Result.count <= data.count
		end

	clean (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Remove all NaN and infinite values.
		require
			input_valid: data /= Void
		do
			-- TODO: Phase 4 - Filter out both NaN and infinite
			create Result.make_empty
		ensure
			result_valid: not has_nan (Result) and not has_infinite (Result)
			result_size: Result.count <= data.count
		end

feature {NONE} -- Helper Queries

	has_nan (arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any NaN values?
		require
			arr_not_void: arr /= Void
		do
			Result := False
			-- TODO: Phase 4 - Check for NaN values
		ensure
			result_is_boolean: True
		end

	has_infinite (arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any infinite values?
		require
			arr_not_void: arr /= Void
		do
			Result := False
			-- TODO: Phase 4 - Check for infinite values
		ensure
			result_is_boolean: True
		end

invariant
	-- Stateless: no invariant on object state
	instance_valid: True

end
```

## Implementation Approach Summary

See attached `.eiffel-workflow/approach.md` for full implementation strategy including:
- 5-week implementation plan with dependency ordering
- Specific algorithms (Kahan summation, Welford's variance, QR decomposition)
- Testing strategy (unit tests, edge cases, numerical stability)
- Known limitations (arrays only, population statistics, no missing values handling)

## Your Task

Review the contracts above and identify issues using the checklist. Format each issue as:

```
ISSUE: [Description of problem]
LOCATION: [ClassName.feature_name]
SEVERITY: [Critical / High / Medium / Low]
SUGGESTION: [How to fix it]
```

## Priority Issues (if found)

Look especially for:
1. **Vague postconditions** (e.g., `result_valid: True` - does this actually constrain anything?)
2. **Missing edge cases** (e.g., what about single-element arrays? negative percentiles?)
3. **Weak preconditions** (e.g., checking only for empty, not NaN/infinity)
4. **Dead code** (e.g., postconditions that can never fail)

---

**END OF CONTRACTS**
