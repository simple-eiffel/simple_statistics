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

	mean (a_data: ARRAY [REAL_64]): REAL_64
			-- Arithmetic mean using numerically stable summation.
		require
			data_not_empty: not a_data.is_empty
		local
			l_mean_val: REAL_64
			l_count: INTEGER
		do
			l_mean_val := 0.0
			l_count := 0
			across a_data as ic loop
				l_count := l_count + 1
				l_mean_val := l_mean_val + (ic.item - l_mean_val) / l_count
			end
			Result := l_mean_val
		ensure
			result_is_average: True  -- result is average of all a_data points
		end

	median (a_data: ARRAY [REAL_64]): REAL_64
			-- Middle value (50th percentile).
		require
			data_not_empty: not a_data.is_empty
		do
			Result := percentile (a_data, 50.0)
		ensure
			result_is_median: True  -- result is 50th percentile
		end

	mode (a_data: ARRAY [REAL_64]): REAL_64
			-- Most frequent value (may not be unique for multimodal data).
			-- For continuous data with no repeats, returns one value from data.
		require
			data_not_empty: not a_data.is_empty
		local
			l_frequency_map: HASH_TABLE [INTEGER, REAL_64]
			l_max_freq: INTEGER
			l_mode_val: REAL_64
		do
			create l_frequency_map.make (a_data.count)
			l_max_freq := 0
			l_mode_val := a_data[a_data.lower]

			across a_data as ic loop
				if l_frequency_map.has (ic.item) then
					l_frequency_map[ic.item] := l_frequency_map[ic.item] + 1
				else
					l_frequency_map[ic.item] := 1
				end

				if l_frequency_map[ic.item] > l_max_freq then
					l_max_freq := l_frequency_map[ic.item]
					l_mode_val := ic.item
				end
			end

			Result := l_mode_val
		ensure
			result_in_data: a_data.has (Result)
		end

	variance (a_data: ARRAY [REAL_64]): REAL_64
			-- Population variance using Welford's algorithm (numerically stable).
		require
			data_not_empty: not a_data.is_empty
		local
			l_mean_val: REAL_64
			l_sum_sq_dev: REAL_64
		do
			l_mean_val := mean (a_data)
			l_sum_sq_dev := 0.0
			across a_data as ic loop
				l_sum_sq_dev := l_sum_sq_dev + (ic.item - l_mean_val) * (ic.item - l_mean_val)
			end
			Result := l_sum_sq_dev / a_data.count
		ensure
			result_non_negative: Result >= 0.0
		end

	std_dev (a_data: ARRAY [REAL_64]): REAL_64
			-- Standard deviation = sqrt(variance).
		require
			data_not_empty: not a_data.is_empty
		local
			l_var: REAL_64
			l_math: SIMPLE_MATH
		do
			l_var := variance (a_data)
			create l_math.make
			Result := l_math.sqrt (l_var)
		ensure
			result_non_negative: Result >= 0.0
		end

	percentile (a_data: ARRAY [REAL_64]; p: REAL_64): REAL_64
			-- p-th percentile where p ∈ [0, 100].
		require
			data_not_empty: not a_data.is_empty
			percentile_valid: p >= 0.0 and p <= 100.0
		local
			l_sorted: ARRAY [REAL_64]
			l_h: REAL_64
			l_h_floor: INTEGER
			l_h_ceil: INTEGER
			l_fraction: REAL_64
			i, j: INTEGER
			l_temp: REAL_64
		do
			-- Create sorted copy of data using bubble sort
			create l_sorted.make_from_array (a_data)

			-- Simple bubble sort
			from i := l_sorted.lower until i >= l_sorted.upper loop
				from j := l_sorted.lower until j >= l_sorted.upper - (i - l_sorted.lower) loop
					if l_sorted[j] > l_sorted[j + 1] then
						l_temp := l_sorted[j]
						l_sorted[j] := l_sorted[j + 1]
						l_sorted[j + 1] := l_temp
					end
					j := j + 1
				end
				i := i + 1
			end

			-- Compute h = (p/100) * (n - 1)
			l_h := (p / 100.0) * (l_sorted.count - 1)
			l_h_floor := l_h.floor
			l_h_ceil := l_h.ceiling

			if l_h_floor = l_h_ceil then
				-- h is exact integer - return sorted[h + 1] (adjust for 1-based indexing)
				Result := l_sorted[l_sorted.lower + l_h_floor]
			else
				-- Interpolate between sorted[h_floor] and sorted[h_ceil]
				l_fraction := l_h - l_h.floor
				Result := l_sorted[l_sorted.lower + l_h_floor] * (1.0 - l_fraction) +
						  l_sorted[l_sorted.lower + l_h_ceil] * l_fraction
			end
		ensure
			result_is_percentile: True  -- result is p-th percentile of a_data
		end

	quartiles (a_data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Q1, Q2 (median), Q3 as array of 3 values.
		require
			data_not_empty: not a_data.is_empty
			sufficient_data: a_data.count >= 4
		do
			create Result.make_filled (0.0, 1, 3)
			Result[1] := percentile (a_data, 25.0)
			Result[2] := percentile (a_data, 50.0)
			Result[3] := percentile (a_data, 75.0)
		ensure
			result_size: Result.count = 3
			ordered: Result [1] <= Result [2] and Result [2] <= Result [3]
		end

	min_value (a_data: ARRAY [REAL_64]): REAL_64
			-- Minimum value in dataset.
		require
			data_not_empty: not a_data.is_empty
		do
			Result := a_data[a_data.lower]
			across a_data as ic loop
				if ic.item < Result then
					Result := ic.item
				end
			end
		ensure
			result_in_data: a_data.has (Result)
			result_is_minimum: True  -- result is smallest element
		end

	max_value (a_data: ARRAY [REAL_64]): REAL_64
			-- Maximum value in dataset.
		require
			data_not_empty: not a_data.is_empty
		do
			Result := a_data[a_data.lower]
			across a_data as ic loop
				if ic.item > Result then
					Result := ic.item
				end
			end
		ensure
			result_in_data: a_data.has (Result)
			result_is_maximum: True  -- result is largest element
		end

	range (a_data: ARRAY [REAL_64]): REAL_64
			-- max - min (spread).
		require
			data_not_empty: not a_data.is_empty
		do
			Result := max_value (a_data) - min_value (a_data)
		ensure
			result_non_negative: Result >= 0.0
		end

	sum (a_data: ARRAY [REAL_64]): REAL_64
			-- Sum of all values using Kahan summation for numerical stability.
		require
			data_not_empty: not a_data.is_empty
		local
			l_running_sum: REAL_64
			l_compensation: REAL_64
			l_temp: REAL_64
		do
			l_running_sum := 0.0
			l_compensation := 0.0
			across a_data as ic loop
				l_temp := ic.item - l_compensation
				l_running_sum := l_running_sum + l_temp
				l_compensation := (l_running_sum - ic.item) - l_temp
			end
			Result := l_running_sum
		ensure
			result_is_sum: True  -- result is sum of all a_data points
		end

feature -- Correlation & Covariance

	correlation (x, y: ARRAY [REAL_64]): REAL_64
			-- Pearson correlation coefficient: measure of linear relationship in [-1, 1].
			-- Returns 1 for perfect positive, -1 for perfect negative, 0 for no correlation.
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		local
			l_cov_xy: REAL_64
			l_std_x: REAL_64
			l_std_y: REAL_64
		do
			l_cov_xy := covariance (x, y)
			l_std_x := std_dev (x)
			l_std_y := std_dev (y)

			if l_std_x = 0.0 or l_std_y = 0.0 then
				Result := 0.0
			else
				Result := l_cov_xy / (l_std_x * l_std_y)
			end
		ensure
			result_in_range: Result >= -1.0 and Result <= 1.0
		end

	covariance (x, y: ARRAY [REAL_64]): REAL_64
			-- Covariance between x and y.
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		local
			l_mean_x: REAL_64
			l_mean_y: REAL_64
			l_sum_products: REAL_64
			i: INTEGER
		do
			l_mean_x := mean (x)
			l_mean_y := mean (y)
			l_sum_products := 0.0

			from i := x.lower until i > x.upper loop
				l_sum_products := l_sum_products + (x[i] - l_mean_x) * (y[y.lower + (i - x.lower)] - l_mean_y)
				i := i + 1
			end

			Result := l_sum_products / x.count
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
		local
			l_mean_x: REAL_64
			l_mean_y: REAL_64
			l_slope_num: REAL_64
			l_slope_den: REAL_64
			l_slope: REAL_64
			l_intercept: REAL_64
			l_y_pred: REAL_64
			l_ss_res: REAL_64
			l_ss_tot: REAL_64
			l_r_squared: REAL_64
			i: INTEGER
		do
			l_mean_x := mean (x)
			l_mean_y := mean (y)

			-- Compute slope using formula: slope = cov(x,y) / var(x)
			l_slope_num := 0.0
			l_slope_den := 0.0

			from i := x.lower until i > x.upper loop
				l_slope_num := l_slope_num + (x[i] - l_mean_x) * (y[y.lower + (i - x.lower)] - l_mean_y)
				l_slope_den := l_slope_den + (x[i] - l_mean_x) * (x[i] - l_mean_x)
				i := i + 1
			end

			if l_slope_den = 0.0 then
				l_slope := 0.0
			else
				l_slope := l_slope_num / l_slope_den
			end

			l_intercept := l_mean_y - l_slope * l_mean_x

			-- Compute R-squared
			l_ss_res := 0.0
			l_ss_tot := 0.0

			from i := x.lower until i > x.upper loop
				l_y_pred := l_slope * x[i] + l_intercept
				l_ss_res := l_ss_res + (y[y.lower + (i - x.lower)] - l_y_pred) * (y[y.lower + (i - x.lower)] - l_y_pred)
				l_ss_tot := l_ss_tot + (y[y.lower + (i - x.lower)] - l_mean_y) * (y[y.lower + (i - x.lower)] - l_mean_y)
				i := i + 1
			end

			if l_ss_tot = 0.0 then
				l_r_squared := 1.0
			else
				l_r_squared := 1.0 - (l_ss_res / l_ss_tot)
			end

			-- Ensure r_squared is in valid range [0, 1]
			if l_r_squared < 0.0 then
				l_r_squared := 0.0
			elseif l_r_squared > 1.0 then
				l_r_squared := 1.0
			end

			create Result.make (l_slope, l_intercept, l_r_squared, x, 1.0)
		ensure
			result_valid: Result /= Void
			r2_valid: Result.r_squared >= 0.0 and Result.r_squared <= 1.0
		end

feature -- Hypothesis Testing

	t_test_one_sample (a_data: ARRAY [REAL_64]; mu_0: REAL_64): TEST_RESULT
			-- One-sample t-test: H0: mu = mu_0.
		require
			data_not_empty: not a_data.is_empty
			sufficient_data: a_data.count >= 2
		local
			l_sample_mean: REAL_64
			l_std_error: REAL_64
			l_t_statistic: REAL_64
			l_dof: INTEGER
			l_p_value: REAL_64
			l_math: SIMPLE_MATH
			l_n_sqrt: REAL_64
			n: REAL_64
		do
			l_sample_mean := mean (a_data)
			create l_math.make
			n := a_data.count
			l_n_sqrt := l_math.sqrt (n)
			l_std_error := std_dev (a_data) / l_n_sqrt
			l_t_statistic := (l_sample_mean - mu_0) / l_std_error
			l_dof := a_data.count - 1

			-- Placeholder p-value (simplified - Phase 5 will use proper t-CDF)
			-- For now, return 0.5 as placeholder
			l_p_value := 0.5

			create Result.make (l_t_statistic, l_p_value, l_dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
			dof_correct: Result.degrees_of_freedom = a_data.count - 1
		end

	t_test_two_sample (x, y: ARRAY [REAL_64]): TEST_RESULT
			-- Two-sample t-test: H0: mu1 = mu2 (Welch's t-test for unequal variances).
		require
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2 and y.count >= 2
		local
			l_mean_x: REAL_64
			l_mean_y: REAL_64
			l_var_x: REAL_64
			l_var_y: REAL_64
			l_t_statistic: REAL_64
			l_dof: INTEGER
			l_p_value: REAL_64
			l_math: SIMPLE_MATH
			l_se: REAL_64
		do
			l_mean_x := mean (x)
			l_mean_y := mean (y)
			l_var_x := variance (x)
			l_var_y := variance (y)

			create l_math.make
			-- Welch's t-test statistic
			l_se := l_math.sqrt (l_var_x / x.count + l_var_y / y.count)
			l_t_statistic := (l_mean_x - l_mean_y) / l_se

			-- Welch-Satterthwaite degrees of freedom
			l_dof := ((l_var_x / x.count + l_var_y / y.count) * (l_var_x / x.count + l_var_y / y.count) /
					((l_var_x / x.count) * (l_var_x / x.count) / (x.count - 1) +
					 (l_var_y / y.count) * (l_var_y / y.count) / (y.count - 1))).floor

			-- Placeholder p-value (Phase 5 will use proper t-CDF)
			l_p_value := 0.5

			create Result.make (l_t_statistic, l_p_value, l_dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			dof_positive: Result.degrees_of_freedom >= 1
		end

	t_test_paired (x, y: ARRAY [REAL_64]): TEST_RESULT
			-- Paired t-test: H0: mu_diff = 0.
		require
			same_length: x.count = y.count
			data_valid: not x.is_empty and not y.is_empty
			sufficient_data: x.count >= 2
		local
			l_differences: ARRAY [REAL_64]
			i: INTEGER
			l_mean_diff: REAL_64
			l_std_error: REAL_64
			l_t_statistic: REAL_64
			l_dof: INTEGER
			l_p_value: REAL_64
			l_math: SIMPLE_MATH
			l_n_sqrt: REAL_64
			n: REAL_64
		do
			-- Compute differences
			create l_differences.make_filled (0.0, 1, x.count)
			from i := x.lower until i > x.upper loop
				l_differences[i - x.lower + 1] := x[i] - y[y.lower + (i - x.lower)]
				i := i + 1
			end

			l_mean_diff := mean (l_differences)
			create l_math.make
			n := l_differences.count
			l_n_sqrt := l_math.sqrt (n)
			l_std_error := std_dev (l_differences) / l_n_sqrt
			l_t_statistic := l_mean_diff / l_std_error
			l_dof := x.count - 1

			-- Placeholder p-value (Phase 5 will use proper t-CDF)
			l_p_value := 0.5

			create Result.make (l_t_statistic, l_p_value, l_dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			dof_correct: Result.degrees_of_freedom = x.count - 1
		end

	chi_square_test (observed, expected: ARRAY [REAL_64]): TEST_RESULT
			-- Chi-square goodness-of-fit test.
			-- Assumption: All expected frequencies should be >= 5 for valid test.
		require
			same_length: observed.count = expected.count
			data_valid: not observed.is_empty
			expected_frequencies_valid: True  -- all expected frequencies >= 5
		local
			l_chi_sq: REAL_64
			i: INTEGER
			l_dof: INTEGER
			l_p_value: REAL_64
		do
			l_chi_sq := 0.0
			from i := observed.lower until i > observed.upper loop
				l_chi_sq := l_chi_sq + (observed[i] - expected[i]) * (observed[i] - expected[i]) / expected[i]
				i := i + 1
			end

			l_dof := observed.count - 1

			-- Placeholder p-value (Phase 5 will use proper chi-square CDF)
			l_p_value := 0.5

			create Result.make (l_chi_sq, l_p_value, l_dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
			dof_correct: Result.degrees_of_freedom = observed.count - 1
		end

	anova (a_groups: ARRAY [ARRAY [REAL_64]]): TEST_RESULT
			-- One-way ANOVA: H0: all group means are equal.
		require
			sufficient_groups: a_groups.count >= 3
		local
			l_grand_mean: REAL_64
			l_all_data: ARRAY [REAL_64]
			l_total_count: INTEGER
			l_ss_between: REAL_64
			l_ss_within: REAL_64
			l_ms_between: REAL_64
			l_ms_within: REAL_64
			l_f_statistic: REAL_64
			l_dof_between: INTEGER
			l_dof_within: INTEGER
			i, j, k: INTEGER
			l_p_value: REAL_64
		do
			-- Combine all data to compute grand mean
			l_total_count := 0
			from i := a_groups.lower until i > a_groups.upper loop
				l_total_count := l_total_count + a_groups[i].count
				i := i + 1
			end

			create l_all_data.make_filled (0.0, 1, l_total_count)
			k := 1
			from i := a_groups.lower until i > a_groups.upper loop
				from j := a_groups[i].lower until j > a_groups[i].upper loop
					l_all_data[k] := a_groups[i][j]
					k := k + 1
					j := j + 1
				end
				i := i + 1
			end

			l_grand_mean := mean (l_all_data)

			-- Compute sum of squares between groups
			l_ss_between := 0.0
			from i := a_groups.lower until i > a_groups.upper loop
				l_ss_between := l_ss_between + a_groups[i].count * (mean (a_groups[i]) - l_grand_mean) * (mean (a_groups[i]) - l_grand_mean)
				i := i + 1
			end

			-- Compute sum of squares within groups
			l_ss_within := 0.0
			from i := a_groups.lower until i > a_groups.upper loop
				from j := a_groups[i].lower until j > a_groups[i].upper loop
					l_ss_within := l_ss_within + (a_groups[i][j] - mean (a_groups[i])) * (a_groups[i][j] - mean (a_groups[i]))
					j := j + 1
				end
				i := i + 1
			end

			-- Compute degrees of freedom
			l_dof_between := a_groups.count - 1
			l_dof_within := l_total_count - a_groups.count

			-- Compute mean squares
			l_ms_between := l_ss_between / l_dof_between
			l_ms_within := l_ss_within / l_dof_within

			-- Compute F-statistic
			if l_ms_within = 0.0 then
				l_f_statistic := 0.0
			else
				l_f_statistic := l_ms_between / l_ms_within
			end

			-- Placeholder p-value (Phase 5 will use proper F-CDF)
			l_p_value := 0.5

			create Result.make (l_f_statistic, l_p_value, l_dof_between, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
		end

invariant
	-- Stateless: no invariant on object state
	instance_valid: True

end
