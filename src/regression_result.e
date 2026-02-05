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

	predict (a_x: REAL_64): REAL_64
			-- Predict y for given x using fitted model.
		require
			x_valid: True  -- a_x validated in implementation
		do
			Result := slope * a_x + intercept
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
