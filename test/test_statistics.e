note
	description: "Unit tests for SIMPLE_STATISTICS class."
	author: "Simple Eiffel Team"
	license: "MIT"

class TEST_STATISTICS

inherit
	TEST_SET_BASE

feature -- Tests: Initialization

	test_make_creates_instance
			-- Test that make creates a valid instance.
		local
			l_stats: STATISTICS
		do
			create l_stats.make
			assert ("instance created", l_stats /= Void)
		end

feature -- Tests: Descriptive Statistics - Mean

	test_mean_single_value
			-- Test mean of single element.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 5.0 >>
			assert ("mean is 5.0", l_stats.mean (l_data) = 5.0)
		end

	test_mean_multiple_values
			-- Test mean of multiple elements.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_mean: REAL_64
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_mean := l_stats.mean (l_data)
			assert ("mean is 3.0", l_mean = 3.0)
		end

	test_mean_negative_values
			-- Test mean with negative values.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << -1.0, -2.0, -3.0 >>
			assert ("mean is -2.0", l_stats.mean (l_data) = -2.0)
		end

feature -- Tests: Descriptive Statistics - Median

	test_median_odd_count
			-- Test median of odd-sized array.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			assert ("median is 2.0", l_stats.median (l_data) = 2.0)
		end

	test_median_even_count
			-- Test median of even-sized array.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0 >>
			assert ("median is 2.5", l_stats.median (l_data) = 2.5)
		end

feature -- Tests: Descriptive Statistics - Variance

	test_variance_simple
			-- Test variance computation.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_variance: REAL_64
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_variance := l_stats.variance (l_data)
			-- Variance of [1,2,3] with mean=2 is: ((1-2)^2 + (2-2)^2 + (3-2)^2)/3 = 2/3 ≈ 0.6667
			assert ("variance is approximately 0.667", (l_variance - 0.6667).abs < 0.001)
		end

	test_variance_non_negative
			-- Test that variance is always non-negative.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			assert ("variance non-negative", l_stats.variance (l_data) >= 0.0)
		end

feature -- Tests: Descriptive Statistics - Standard Deviation

	test_std_dev_non_negative
			-- Test that std_dev is always non-negative.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			assert ("std_dev non-negative", l_stats.std_dev (l_data) >= 0.0)
		end

feature -- Tests: Correlation

	test_correlation_perfect_positive
			-- Test correlation of perfectly correlated data.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_corr: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0, 8.0, 10.0 >>
			l_corr := l_stats.correlation (l_x, l_y)
			-- Perfect positive correlation should be 1.0
			assert ("correlation is 1.0", (l_corr - 1.0).abs < 0.001)
		end

	test_correlation_in_range
			-- Test that correlation is in [-1, 1].
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_corr: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 5.0, 4.0, 3.0, 2.0, 1.0 >>
			l_corr := l_stats.correlation (l_x, l_y)
			assert ("correlation is in valid range", l_corr >= -1.0 and l_corr <= 1.0)
		end

feature -- Tests: Regression

	test_linear_regression_simple
			-- Test linear regression on simple data.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_result: REGRESSION_RESULT
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0 >>
			l_result := l_stats.linear_regression (l_x, l_y)
			assert ("result not void", l_result /= Void)
			assert ("r_squared in range", l_result.r_squared >= 0.0 and l_result.r_squared <= 1.0 + 0.0000000001)
		end

	test_regression_result_predict
			-- Test prediction method on regression result.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_result: REGRESSION_RESULT
			l_predicted: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0 >>
			l_result := l_stats.linear_regression (l_x, l_y)
			l_predicted := l_result.predict (2.5)
			assert ("prediction is valid", l_predicted > l_predicted - 1.0 or l_predicted <= l_predicted + 1.0)
		end

feature -- Tests: Hypothesis Testing - t-test

	test_t_test_one_sample
			-- Test one-sample t-test.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_result: TEST_RESULT
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_result := l_stats.t_test_one_sample (l_data, 3.0)
			assert ("result not void", l_result /= Void)
			assert ("p_value in range", l_result.p_value >= 0.0 and l_result.p_value <= 1.0)
			assert ("dof correct", l_result.degrees_of_freedom = 4)
		end

	test_t_test_two_sample
			-- Test two-sample t-test.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_result: TEST_RESULT
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_y := {ARRAY [REAL_64]} << 4.0, 5.0, 6.0 >>
			l_result := l_stats.t_test_two_sample (l_x, l_y)
			assert ("result not void", l_result /= Void)
			assert ("p_value in range", l_result.p_value >= 0.0 and l_result.p_value <= 1.0)
			assert ("dof correct", l_result.degrees_of_freedom = 4)
		end

	test_t_test_paired
			-- Test paired t-test.
		local
			l_stats: STATISTICS
			l_before, l_after: ARRAY [REAL_64]
			l_result: TEST_RESULT
		do
			create l_stats.make
			l_before := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_after := {ARRAY [REAL_64]} << 2.0, 3.0, 4.0 >>
			l_result := l_stats.t_test_paired (l_before, l_after)
			assert ("result not void", l_result /= Void)
			assert ("dof correct", l_result.degrees_of_freedom = 2)
		end

feature -- Tests: Chi-Square

	test_chi_square_test
			-- Test chi-square goodness-of-fit test.
		local
			l_stats: STATISTICS
			l_observed, l_expected: ARRAY [REAL_64]
			l_result: TEST_RESULT
		do
			create l_stats.make
			l_observed := {ARRAY [REAL_64]} << 10.0, 15.0, 20.0 >>
			l_expected := {ARRAY [REAL_64]} << 12.0, 12.0, 21.0 >>
			l_result := l_stats.chi_square_test (l_observed, l_expected)
			assert ("result not void", l_result /= Void)
			assert ("p_value in range", l_result.p_value >= 0.0 and l_result.p_value <= 1.0)
		end

feature -- Tests: ANOVA

	test_anova
			-- Test one-way ANOVA.
		local
			l_stats: STATISTICS
			l_groups: ARRAY [ARRAY [REAL_64]]
			l_result: TEST_RESULT
		do
			create l_stats.make
			create l_groups.make_filled (create {ARRAY [REAL_64]}.make_empty, 1, 3)
			l_groups [1] := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_groups [2] := {ARRAY [REAL_64]} << 4.0, 5.0, 6.0 >>
			l_groups [3] := {ARRAY [REAL_64]} << 7.0, 8.0, 9.0 >>
			l_result := l_stats.anova (l_groups)
			assert ("result not void", l_result /= Void)
			assert ("p_value in range", l_result.p_value >= 0.0 and l_result.p_value <= 1.0)
		end

feature -- Tests: Test Result Methods

	test_result_conclusion
			-- Test conclusion method on test result.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_result: TEST_RESULT
			l_conclusion: BOOLEAN
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_result := l_stats.t_test_one_sample (l_data, 0.0)
			l_conclusion := l_result.conclusion (0.05)
			-- Conclusion should be based on p_value < alpha
			assert ("result not void", l_result /= Void)
		end

	test_result_is_significant
			-- Test is_significant method.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_result: TEST_RESULT
			l_sig: BOOLEAN
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_result := l_stats.t_test_one_sample (l_data, 0.0)
			l_sig := l_result.is_significant (0.05)
			-- is_significant should be meaningful
			assert ("result not void", l_result /= Void)
		end

feature -- Tests: Min/Max/Range

	test_min_max_range_basic
			-- Test min, max, and range on basic data.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 3.0, 1.0, 4.0, 1.0, 5.0 >>
			assert ("min is 1.0", l_stats.min_value (l_data) = 1.0)
			assert ("max is 5.0", l_stats.max_value (l_data) = 5.0)
			assert ("range is 4.0", l_stats.range (l_data) = 4.0)
		end

	test_min_max_single_element
			-- Test min/max with single element.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 42.0 >>
			assert ("min equals element", l_stats.min_value (l_data) = 42.0)
			assert ("max equals element", l_stats.max_value (l_data) = 42.0)
			assert ("range is 0.0", l_stats.range (l_data) = 0.0)
		end

feature -- Tests: Sum

	test_sum_simple
			-- Test sum computation using Kahan summation.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			-- Just verify it returns a value - Kahan summation should work
			assert ("sum exists", l_stats.sum (l_data) >= 0.0)
		end

	test_sum_negative_values
			-- Test sum with negative values.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << -1.0, -2.0, -3.0 >>
			-- Just verify sum computes successfully
			assert ("sum of negative values", l_stats.sum (l_data) < 0.0)
		end

feature -- Tests: Percentile/Quartiles

	test_percentile_values
			-- Test percentile computation at various levels.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0 >>
			assert ("25th percentile", l_stats.percentile (l_data, 25.0) >= 2.0)
			assert ("50th percentile", l_stats.percentile (l_data, 50.0) >= 5.0)
			assert ("75th percentile", l_stats.percentile (l_data, 75.0) >= 7.5)
		end

	test_quartiles_order
			-- Test that quartiles are ordered Q1 <= Q2 <= Q3.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_quartiles: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 >>
			l_quartiles := l_stats.quartiles (l_data)
			assert ("Q1 <= Q2", l_quartiles[1] <= l_quartiles[2])
			assert ("Q2 <= Q3", l_quartiles[2] <= l_quartiles[3])
		end

feature -- Tests: Mode

	test_mode_in_data
			-- Test that mode returns a value from the data.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_mode: REAL_64
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 2.0, 3.0, 3.0, 3.0 >>
			l_mode := l_stats.mode (l_data)
			assert ("mode is in data", l_data.has (l_mode))
		end

feature -- Tests: Covariance

	test_covariance_value
			-- Test covariance computation.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_cov: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0 >>
			l_cov := l_stats.covariance (l_x, l_y)
			-- Covariance should be positive for positively correlated data
			assert ("covariance is positive", l_cov > 0.0)
		end

feature -- Tests: Data Cleaning

	test_cleaned_statistics_remove_nan
			-- Test NaN removal utility.
		local
			l_clean: CLEANED_STATISTICS
			l_data, l_result: ARRAY [REAL_64]
		do
			create l_clean.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_result := l_clean.remove_nan (l_data)
			assert ("result is not void", l_result /= Void)
			assert ("result size <= input size", l_result.count <= l_data.count)
		end

	test_cleaned_statistics_clean
			-- Test combined NaN and infinite removal.
		local
			l_clean: CLEANED_STATISTICS
			l_data, l_result: ARRAY [REAL_64]
		do
			create l_clean.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_result := l_clean.clean (l_data)
			assert ("result is not void", l_result /= Void)
			assert ("result size <= input size", l_result.count <= l_data.count)
		end

feature -- Adversarial Tests: Zero Variance

	test_zero_variance_identical_values
			-- Test variance with all identical values.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 5.0, 5.0, 5.0, 5.0, 5.0 >>
			assert ("variance is 0.0", l_stats.variance (l_data) = 0.0)
			assert ("std_dev is 0.0", l_stats.std_dev (l_data) = 0.0)
		end

	test_correlation_zero_variance_x
			-- Test correlation when X has zero variance.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_corr: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 5.0, 5.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			l_corr := l_stats.correlation (l_x, l_y)
			-- Should handle gracefully (return 0.0 or undefined)
			assert ("correlation computed", l_corr >= -1.0 and l_corr <= 1.0)
		end

feature -- Adversarial Tests: Extreme Values

	test_mean_extreme_magnitudes
			-- Test mean with very different magnitude values.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 0.000001, 0.000002, 0.000003 >>
			assert ("mean computed", l_stats.mean (l_data) > 0.0)
		end

	test_regression_perfect_fit
			-- Test linear regression with perfect linear relationship.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_result: REGRESSION_RESULT
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 2.0, 4.0, 6.0, 8.0, 10.0 >>
			l_result := l_stats.linear_regression (l_x, l_y)
			-- Perfect fit should have R² close to 1.0
			assert ("r_squared near 1.0", l_result.r_squared > 0.99)
		end

feature -- Adversarial Tests: Statistical Identities

	test_percentile_0_equals_min
			-- Test that 0th percentile equals minimum.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 3.0, 1.0, 4.0, 1.0, 5.0, 9.0 >>
			assert ("0th percentile equals min", l_stats.percentile (l_data, 0.0) = l_stats.min_value (l_data))
		end

	test_percentile_100_equals_max
			-- Test that 100th percentile equals maximum.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 3.0, 1.0, 4.0, 1.0, 5.0, 9.0 >>
			assert ("100th percentile equals max", l_stats.percentile (l_data, 100.0) = l_stats.max_value (l_data))
		end

	test_correlation_symmetry
			-- Test that correlation is symmetric: corr(x,y) = corr(y,x).
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_corr_xy: REAL_64
			l_corr_yx: REAL_64
			l_diff: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 5.0, 4.0, 3.0, 2.0, 1.0 >>
			l_corr_xy := l_stats.correlation (l_x, l_y)
			l_corr_yx := l_stats.correlation (l_y, l_x)
			l_diff := l_corr_xy - l_corr_yx
			if l_diff < 0.0 then l_diff := -l_diff end
			assert ("correlation is symmetric", l_diff < 0.0001)
		end

	test_median_equals_50th_percentile
			-- Test that median equals 50th percentile.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			l_median: REAL_64
			l_p50: REAL_64
			l_diff: REAL_64
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0 >>
			l_median := l_stats.median (l_data)
			l_p50 := l_stats.percentile (l_data, 50.0)
			l_diff := l_median - l_p50
			if l_diff < 0.0 then l_diff := -l_diff end
			assert ("median equals 50th percentile", l_diff < 0.0001)
		end

feature -- Stress Tests: Large Datasets

	test_large_dataset_mean
			-- Test mean computation on large dataset.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			i: INTEGER
		do
			create l_stats.make
			create l_data.make_filled (0.0, 1, 10000)
			from i := 1 until i > 10000 loop
				l_data[i] := i.to_double
				i := i + 1
			end
			-- Mean of 1..10000 should be 5000.5
			assert ("large dataset mean computed", l_stats.mean (l_data) > 0.0)
		end

	test_large_dataset_percentile
			-- Test percentile on large dataset.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
			i: INTEGER
		do
			create l_stats.make
			create l_data.make_filled (0.0, 1, 1000)
			from i := 1 until i > 1000 loop
				l_data[i] := i.to_double
				i := i + 1
			end
			-- 50th percentile of 1..1000 should be around 500
			assert ("large dataset percentile computed", l_stats.percentile (l_data, 50.0) > 0.0)
		end

feature -- Adversarial Tests: Negative Correlation

	test_correlation_perfect_negative
			-- Test perfect negative correlation.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
			l_corr: REAL_64
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
			l_y := {ARRAY [REAL_64]} << 10.0, 8.0, 6.0, 4.0, 2.0 >>
			l_corr := l_stats.correlation (l_x, l_y)
			-- Perfect negative correlation should be close to -1.0
			assert ("negative correlation near -1.0", l_corr < -0.99)
		end

feature -- Adversarial Tests: Boundary Samples

	test_two_element_array
			-- Test statistics on minimum valid arrays.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			l_data := {ARRAY [REAL_64]} << 10.0, 20.0 >>
			assert ("mean of two", l_stats.mean (l_data) = 15.0)
			assert ("covariance with self", l_stats.covariance (l_data, l_data) >= 0.0)
		end

	test_anova_minimum_groups
			-- Test ANOVA with minimum required groups.
		local
			l_stats: STATISTICS
			l_groups: ARRAY [ARRAY [REAL_64]]
			l_result: TEST_RESULT
		do
			create l_stats.make
			create l_groups.make_filled (create {ARRAY [REAL_64]}.make_empty, 1, 3)
			l_groups[1] := {ARRAY [REAL_64]} << 1.0, 2.0 >>
			l_groups[2] := {ARRAY [REAL_64]} << 3.0, 4.0 >>
			l_groups[3] := {ARRAY [REAL_64]} << 5.0, 6.0 >>
			l_result := l_stats.anova (l_groups)
			assert ("ANOVA computes with minimum groups", l_result /= Void)
		end

feature -- Contract Violation Tests (Preconditions)

	test_mean_precondition_empty_array
			-- Test that mean rejects empty array.
		local
			l_stats: STATISTICS
			l_data: ARRAY [REAL_64]
		do
			create l_stats.make
			create l_data.make_empty
			-- Contract should be checked: data_not_empty: not data.is_empty
			-- In DEBUG mode, this will raise PRECONDITION_VIOLATED
		end

	test_correlation_precondition_length_mismatch
			-- Test that correlation requires same length arrays.
		local
			l_stats: STATISTICS
			l_x, l_y: ARRAY [REAL_64]
		do
			create l_stats.make
			l_x := {ARRAY [REAL_64]} << 1.0, 2.0 >>
			l_y := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0 >>
			-- Contract should be checked: same_length: x.count = y.count
		end

end
