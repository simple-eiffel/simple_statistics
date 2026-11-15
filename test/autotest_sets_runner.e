note
	description: "[
		Runs the tests in simple_statistics's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 3 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 3 in all.
		do
			run_lib_tests
			run_test_statistics
		end

feature {NONE} -- Test sets

	run_lib_tests
		local
			l_evaluator: EQA_TEST_EVALUATOR [LIB_TESTS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {LIB_TESTS}.test_statistics_make), "LIB_TESTS.test_statistics_make")
		end

	run_test_statistics
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_STATISTICS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_STATISTICS}.test_mean_precondition_empty_array), "TEST_STATISTICS.test_mean_precondition_empty_array")
			report (l_evaluator.execute (agent {TEST_STATISTICS}.test_correlation_precondition_length_mismatch), "TEST_STATISTICS.test_correlation_precondition_length_mismatch")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
