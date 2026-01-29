note
	description: "Core tests for simple_statistics library"
	author: "Simple Eiffel Team"
	license: "MIT"

class LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Core Tests

	test_statistics_make
			-- Test STATISTICS creation.
		local
			l_stats: STATISTICS
		do
			create l_stats.make
			assert ("instance created", l_stats /= Void)
		end

end
