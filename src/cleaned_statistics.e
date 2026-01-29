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

	remove_nan (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all NaN values removed.
		require
			input_valid: data /= Void
		local
			i: INTEGER
			result_list: ARRAYED_LIST [REAL_64]
			k: INTEGER
		do
			create result_list.make (0)
			from i := data.lower until i > data.upper loop
				-- NaN is not equal to itself
				if data[i] = data[i] then
					result_list.force (data[i])
				end
				i := i + 1
			end
			-- Convert list to array
			create Result.make_filled (0.0, 1, result_list.count)
			k := 1
			across result_list as ic loop
				Result[k] := ic.item
				k := k + 1
			end
		ensure
			result_valid: not has_nan (Result)
			result_size: Result.count <= data.count
		end

	remove_infinite (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Return array with all infinite values removed.
		require
			input_valid: data /= Void
		local
			i: INTEGER
			result_list: ARRAYED_LIST [REAL_64]
			two_times: REAL_64
			k: INTEGER
		do
			create result_list.make (0)
			from i := data.lower until i > data.upper loop
				-- Infinite value when doubling equals itself
				two_times := data[i] * 2.0
				if data[i] /= two_times then
					result_list.force (data[i])
				end
				i := i + 1
			end
			-- Convert list to array
			create Result.make_filled (0.0, 1, result_list.count)
			k := 1
			across result_list as ic loop
				Result[k] := ic.item
				k := k + 1
			end
		ensure
			result_valid: not has_infinite (Result)
			result_size: Result.count <= data.count
		end

	clean (data: ARRAY [REAL_64]): ARRAY [REAL_64]
			-- Remove all NaN and infinite values.
		require
			input_valid: data /= Void
		do
			Result := remove_infinite (remove_nan (data))
		ensure
			result_valid: not has_nan (Result) and not has_infinite (Result)
			result_size: Result.count <= data.count
		end

feature {NONE} -- Helper Queries

	has_nan (arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any NaN values?
		require
			arr_not_void: arr /= Void
		local
			i: INTEGER
		do
			Result := False
			from i := arr.lower until i > arr.upper or Result loop
				-- NaN is not equal to itself (IEEE 754 property)
				if arr[i] /= arr[i] then
					Result := True
				end
				i := i + 1
			end
		ensure
			result_correct: Result = (across arr as a some a.item /= a.item end)
		end

	has_infinite (arr: ARRAY [REAL_64]): BOOLEAN
			-- Does array contain any infinite values?
		require
			arr_not_void: arr /= Void
		local
			i: INTEGER
			two_times: REAL_64
		do
			Result := False
			from i := arr.lower until i > arr.upper or Result loop
				-- Check if doubling value equals itself (true for infinite, false otherwise)
				two_times := arr[i] * 2.0
				if arr[i] = two_times then
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
