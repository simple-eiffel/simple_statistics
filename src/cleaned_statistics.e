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

	remove_nan (a_data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all NaN values removed.
		require
			input_valid: a_data /= Void
		local
			i: INTEGER
			l_result_list: ARRAYED_LIST [REAL_64]
			k: INTEGER
		do
			create l_result_list.make (0)
			from i := a_data.lower until i > a_data.upper loop
				-- NaN is not equal to itself
				if a_data[i] = a_data[i] then
					l_result_list.force (a_data[i])
				end
				i := i + 1
			end
			-- Convert list to array
			create Result.make_filled (0.0, 1, l_result_list.count)
			k := 1
			across l_result_list as ic loop
				Result[k] := ic.item
				k := k + 1
			end
		ensure
			result_valid: not has_nan (Result)
			result_size: Result.count <= a_data.count
		end

	remove_infinite (a_data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all infinite values removed.
		require
			input_valid: a_data /= Void
		local
			i: INTEGER
			l_result_list: ARRAYED_LIST [REAL_64]
			l_two_times: REAL_64
			k: INTEGER
		do
			create l_result_list.make (0)
			from i := a_data.lower until i > a_data.upper loop
				-- Infinite value when doubling equals itself
				l_two_times := a_data[i] * 2.0
				if a_data[i] /= l_two_times then
					l_result_list.force (a_data[i])
				end
				i := i + 1
			end
			-- Convert list to array
			create Result.make_filled (0.0, 1, l_result_list.count)
			k := 1
			across l_result_list as ic loop
				Result[k] := ic.item
				k := k + 1
			end
		ensure
			result_valid: not has_infinite (Result)
			result_size: Result.count <= a_data.count
		end

	clean (a_data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Remove all NaN and infinite values.
		require
			input_valid: a_data /= Void
		do
			Result := remove_infinite (remove_nan (a_data))
		ensure
			result_valid: not has_nan (Result) and not has_infinite (Result)
			result_size: Result.count <= a_data.count
		end

feature {NONE} -- Helper Queries

	has_nan (a_arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any NaN values?
		require
			arr_not_void: a_arr /= Void
		local
			i: INTEGER
		do
			Result := False
			from i := a_arr.lower until i > a_arr.upper or Result loop
				-- NaN is not equal to itself (IEEE 754 property)
				if a_arr[i] /= a_arr[i] then
					Result := True
				end
				i := i + 1
			end
		ensure
			result_correct: Result = (across a_arr as a some a.item /= a.item end)
		end

	has_infinite (a_arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any infinite values?
		require
			arr_not_void: a_arr /= Void
		local
			i: INTEGER
			l_two_times: REAL_64
		do
			Result := False
			from i := a_arr.lower until i > a_arr.upper or Result loop
				-- Check if doubling value equals itself (true for infinite, false otherwise)
				l_two_times := a_arr[i] * 2.0
				if a_arr[i] = l_two_times then
					Result := True
				end
				i := i + 1
			end
		ensure
			result_is_boolean: True
		end

invariant
	-- Stateless: no invariant on object state
	instance_valid: True

end
