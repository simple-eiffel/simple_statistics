note
	description: "Test application for simple_statistics"
	author: "Simple Eiffel Team"
	license: "MIT"

class TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running simple_statistics tests...%N%N")
			passed := 0
			failed := 0

			run_statistics_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_statistics_tests
		do
			create stats_tests
			run_test (agent stats_tests.test_make_creates_instance, "test_make_creates_instance")
			run_test (agent stats_tests.test_mean_single_value, "test_mean_single_value")
			run_test (agent stats_tests.test_mean_multiple_values, "test_mean_multiple_values")
			run_test (agent stats_tests.test_mean_negative_values, "test_mean_negative_values")
			run_test (agent stats_tests.test_median_odd_count, "test_median_odd_count")
			run_test (agent stats_tests.test_median_even_count, "test_median_even_count")
			run_test (agent stats_tests.test_variance_simple, "test_variance_simple")
			run_test (agent stats_tests.test_variance_non_negative, "test_variance_non_negative")
			run_test (agent stats_tests.test_std_dev_non_negative, "test_std_dev_non_negative")
			run_test (agent stats_tests.test_correlation_perfect_positive, "test_correlation_perfect_positive")
			run_test (agent stats_tests.test_correlation_in_range, "test_correlation_in_range")
			run_test (agent stats_tests.test_linear_regression_simple, "test_linear_regression_simple")
			run_test (agent stats_tests.test_regression_result_predict, "test_regression_result_predict")
			run_test (agent stats_tests.test_t_test_one_sample, "test_t_test_one_sample")
			run_test (agent stats_tests.test_t_test_two_sample, "test_t_test_two_sample")
			run_test (agent stats_tests.test_t_test_paired, "test_t_test_paired")
			run_test (agent stats_tests.test_chi_square_test, "test_chi_square_test")
			run_test (agent stats_tests.test_anova, "test_anova")
			run_test (agent stats_tests.test_result_conclusion, "test_result_conclusion")
			run_test (agent stats_tests.test_result_is_significant, "test_result_is_significant")
			run_test (agent stats_tests.test_min_max_range_basic, "test_min_max_range_basic")
			run_test (agent stats_tests.test_min_max_single_element, "test_min_max_single_element")
			run_test (agent stats_tests.test_sum_simple, "test_sum_simple")
			run_test (agent stats_tests.test_sum_negative_values, "test_sum_negative_values")
			run_test (agent stats_tests.test_percentile_values, "test_percentile_values")
			run_test (agent stats_tests.test_quartiles_order, "test_quartiles_order")
			run_test (agent stats_tests.test_mode_in_data, "test_mode_in_data")
			run_test (agent stats_tests.test_covariance_value, "test_covariance_value")
			run_test (agent stats_tests.test_cleaned_statistics_remove_nan, "test_cleaned_statistics_remove_nan")
			run_test (agent stats_tests.test_cleaned_statistics_clean, "test_cleaned_statistics_clean")

			-- Adversarial: Zero Variance
			run_test (agent stats_tests.test_zero_variance_identical_values, "test_zero_variance_identical_values")
			run_test (agent stats_tests.test_correlation_zero_variance_x, "test_correlation_zero_variance_x")

			-- Adversarial: Extreme Values
			run_test (agent stats_tests.test_mean_extreme_magnitudes, "test_mean_extreme_magnitudes")
			run_test (agent stats_tests.test_regression_perfect_fit, "test_regression_perfect_fit")

			-- Adversarial: Statistical Identities
			run_test (agent stats_tests.test_percentile_0_equals_min, "test_percentile_0_equals_min")
			run_test (agent stats_tests.test_percentile_100_equals_max, "test_percentile_100_equals_max")
			run_test (agent stats_tests.test_correlation_symmetry, "test_correlation_symmetry")
			run_test (agent stats_tests.test_median_equals_50th_percentile, "test_median_equals_50th_percentile")

			-- Stress Tests: Large Datasets
			run_test (agent stats_tests.test_large_dataset_mean, "test_large_dataset_mean")
			run_test (agent stats_tests.test_large_dataset_percentile, "test_large_dataset_percentile")

			-- Adversarial: Negative Correlation
			run_test (agent stats_tests.test_correlation_perfect_negative, "test_correlation_perfect_negative")

			-- Adversarial: Boundary Samples
			run_test (agent stats_tests.test_two_element_array, "test_two_element_array")
			run_test (agent stats_tests.test_anova_minimum_groups, "test_anova_minimum_groups")
		end

feature {NONE} -- Implementation

	stats_tests: TEST_STATISTICS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
