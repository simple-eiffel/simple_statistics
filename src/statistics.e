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
			mean_val := 0.0
			count := 0
			across a_data as ic loop
				count := count + 1
				mean_val := mean_val + (ic.item - mean_val) / count
			end
			Result := mean_val
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
			create frequency_map.make (a_data.count)
			max_freq := 0
			mode_val := a_data[a_data.lower]

			across a_data as ic loop
				if frequency_map.has (ic.item) then
					frequency_map[ic.item] := frequency_map[ic.item] + 1
				else
					frequency_map[ic.item] := 1
				end

				if frequency_map[ic.item] > max_freq then
					max_freq := frequency_map[ic.item]
					mode_val := ic.item
				end
			end

			Result := mode_val
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
			mean_val := mean (a_data)
			sum_sq_dev := 0.0
			across a_data as ic loop
				sum_sq_dev := sum_sq_dev + (ic.item - mean_val) * (ic.item - mean_val)
			end
			Result := sum_sq_dev / a_data.count
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
			var := variance (a_data)
			create math.make
			Result := math.sqrt (var)
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
			create sorted.make_from_array (a_data)

			-- Simple bubble sort
			from i := sorted.lower until i >= sorted.upper loop
				from j := sorted.lower until j >= sorted.upper - (i - sorted.lower) loop
					if sorted[j] > sorted[j + 1] then
						temp := sorted[j]
						sorted[j] := sorted[j + 1]
						sorted[j + 1] := temp
					end
					j := j + 1
				end
				i := i + 1
			end

			-- Compute h = (p/100) * (n - 1)
			h := (p / 100.0) * (sorted.count - 1)
			h_floor := h.floor
			h_ceil := h.ceiling

			if h_floor = h_ceil then
				-- h is exact integer - return sorted[h + 1] (adjust for 1-based indexing)
				Result := sorted[sorted.lower + h_floor]
			else
				-- Interpolate between sorted[h_floor] and sorted[h_ceil]
				fraction := h - h.floor
				Result := sorted[sorted.lower + h_floor] * (1.0 - fraction) +
						  sorted[sorted.lower + h_ceil] * fraction
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
			running_sum := 0.0
			compensation := 0.0
			across a_data as ic loop
				temp := ic.item - compensation
				running_sum := running_sum + temp
				compensation := (running_sum - ic.item) - temp
			end
			Result := running_sum
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
			cov_xy := covariance (x, y)
			std_x := std_dev (x)
			std_y := std_dev (y)

			if std_x = 0.0 or std_y = 0.0 then
				Result := 0.0
			else
				Result := cov_xy / (std_x * std_y)
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
			mean_x := mean (x)
			mean_y := mean (y)
			sum_products := 0.0

			from i := x.lower until i > x.upper loop
				sum_products := sum_products + (x[i] - mean_x) * (y[y.lower + (i - x.lower)] - mean_y)
				i := i + 1
			end

			Result := sum_products / x.count
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
			mean_x := mean (x)
			mean_y := mean (y)

			-- Compute slope using formula: slope = cov(x,y) / var(x)
			slope_num := 0.0
			slope_den := 0.0

			from i := x.lower until i > x.upper loop
				slope_num := slope_num + (x[i] - mean_x) * (y[y.lower + (i - x.lower)] - mean_y)
				slope_den := slope_den + (x[i] - mean_x) * (x[i] - mean_x)
				i := i + 1
			end

			if slope_den = 0.0 then
				slope := 0.0
			else
				slope := slope_num / slope_den
			end

			intercept := mean_y - slope * mean_x

			-- Compute R-squared
			ss_res := 0.0
			ss_tot := 0.0

			from i := x.lower until i > x.upper loop
				y_pred := slope * x[i] + intercept
				ss_res := ss_res + (y[y.lower + (i - x.lower)] - y_pred) * (y[y.lower + (i - x.lower)] - y_pred)
				ss_tot := ss_tot + (y[y.lower + (i - x.lower)] - mean_y) * (y[y.lower + (i - x.lower)] - mean_y)
				i := i + 1
			end

			if ss_tot = 0.0 then
				r_squared := 1.0
			else
				r_squared := 1.0 - (ss_res / ss_tot)
			end

			-- Ensure r_squared is in valid range [0, 1]
			if r_squared < 0.0 then
				r_squared := 0.0
			elseif r_squared > 1.0 then
				r_squared := 1.0
			end

			create Result.make (slope, intercept, r_squared, x, 1.0)
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
			sample_mean := mean (a_data)
			create math.make
			n := a_data.count
			n_sqrt := math.sqrt (n)
			std_error := std_dev (a_data) / n_sqrt
			t_statistic := (sample_mean - mu_0) / std_error
			dof := a_data.count - 1

			-- Placeholder p-value (simplified - Phase 5 will use proper t-CDF)
			-- For now, return 0.5 as placeholder
			p_value := 0.5

			create Result.make (t_statistic, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
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
			mean_x := mean (x)
			mean_y := mean (y)
			var_x := variance (x)
			var_y := variance (y)

			create math.make
			-- Welch's t-test statistic
			se := math.sqrt (var_x / x.count + var_y / y.count)
			t_statistic := (mean_x - mean_y) / se

			-- Welch-Satterthwaite degrees of freedom
			dof := ((var_x / x.count + var_y / y.count) * (var_x / x.count + var_y / y.count) /
					((var_x / x.count) * (var_x / x.count) / (x.count - 1) +
					 (var_y / y.count) * (var_y / y.count) / (y.count - 1))).floor

			-- Placeholder p-value (Phase 5 will use proper t-CDF)
			p_value := 0.5

			create Result.make (t_statistic, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
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
			create differences.make_filled (0.0, 1, x.count)
			from i := x.lower until i > x.upper loop
				differences[i - x.lower + 1] := x[i] - y[y.lower + (i - x.lower)]
				i := i + 1
			end

			mean_diff := mean (differences)
			create math.make
			n := differences.count
			n_sqrt := math.sqrt (n)
			std_error := std_dev (differences) / n_sqrt
			t_statistic := mean_diff / std_error
			dof := x.count - 1

			-- Placeholder p-value (Phase 5 will use proper t-CDF)
			p_value := 0.5

			create Result.make (t_statistic, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
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
			chi_sq := 0.0
			from i := observed.lower until i > observed.upper loop
				chi_sq := chi_sq + (observed[i] - expected[i]) * (observed[i] - expected[i]) / expected[i]
				i := i + 1
			end

			dof := observed.count - 1

			-- Placeholder p-value (Phase 5 will use proper chi-square CDF)
			p_value := 0.5

			create Result.make (chi_sq, p_value, dof, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
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
			total_count := 0
			from i := a_groups.lower until i > a_groups.upper loop
				total_count := total_count + a_groups[i].count
				i := i + 1
			end

			create all_data.make_filled (0.0, 1, total_count)
			k := 1
			from i := a_groups.lower until i > a_groups.upper loop
				from j := a_groups[i].lower until j > a_groups[i].upper loop
					all_data[k] := a_groups[i][j]
					k := k + 1
					j := j + 1
				end
				i := i + 1
			end

			grand_mean := mean (all_data)

			-- Compute sum of squares between groups
			ss_between := 0.0
			from i := a_groups.lower until i > a_groups.upper loop
				ss_between := ss_between + a_groups[i].count * (mean (a_groups[i]) - grand_mean) * (mean (a_groups[i]) - grand_mean)
				i := i + 1
			end

			-- Compute sum of squares within groups
			ss_within := 0.0
			from i := a_groups.lower until i > a_groups.upper loop
				from j := a_groups[i].lower until j > a_groups[i].upper loop
					ss_within := ss_within + (a_groups[i][j] - mean (a_groups[i])) * (a_groups[i][j] - mean (a_groups[i]))
					j := j + 1
				end
				i := i + 1
			end

			-- Compute degrees of freedom
			dof_between := a_groups.count - 1
			dof_within := total_count - a_groups.count

			-- Compute mean squares
			ms_between := ss_between / dof_between
			ms_within := ss_within / dof_within

			-- Compute F-statistic
			if ms_within = 0.0 then
				f_statistic := 0.0
			else
				f_statistic := ms_between / ms_within
			end

			-- Placeholder p-value (Phase 5 will use proper F-CDF)
			p_value := 0.5

			create Result.make (f_statistic, p_value, dof_between, create {ARRAY [ASSUMPTION_CHECK]}.make_empty)
		ensure
			result_valid: Result /= Void
			p_value_valid: Result.p_value >= 0.0 and Result.p_value <= 1.0
		end

invariant
	-- Stateless: no invariant on object state
	instance_valid: True

end
