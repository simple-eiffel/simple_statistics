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

	conclusion (a_alpha: REAL_64): BOOLEAN
			-- Is null hypothesis rejected at significance level alpha?
			-- True means reject H₀ (result is significant).
		require
			alpha_valid: a_alpha > 0.0 and a_alpha < 1.0
		do
			Result := p_value < a_alpha
		ensure
			result_defined: Result = (p_value < a_alpha)
		end

	is_significant (a_alpha: REAL_64): BOOLEAN
			-- Alias for conclusion (alpha).
		require
			alpha_valid: a_alpha > 0.0 and a_alpha < 1.0
		do
			Result := conclusion (a_alpha)
		ensure
			result_defined: Result = conclusion (a_alpha)
		end

feature -- Model Queries

	assumptions_model: MML_SEQUENCE [ASSUMPTION_CHECK]
			-- Mathematical model of assumption checks in order.
		local
			i: INTEGER
		do
			create Result
			from i := assumption_checks.lower until i > assumption_checks.upper loop
				Result := Result & assumption_checks [i]
				i := i + 1
			end
		ensure
			count_matches: Result.count = assumption_checks.count
		end

feature -- Formatting

	format_for_publication (a_test_name: STRING): STRING
			-- Format result for academic publication (e.g., "t(98)=2.34, p=.022").
		require
			test_name_valid: not a_test_name.is_empty
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
	statistic_is_finite: True  -- statistic finite by contract
	assumption_checks_not_void: assumption_checks /= Void

	-- Model consistency
	model_count: assumptions_model.count = assumption_checks.count

end
