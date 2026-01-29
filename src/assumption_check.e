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
