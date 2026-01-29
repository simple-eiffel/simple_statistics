# Eiffel Contract Review Request (Claude)

## Context

You are reviewing **Eiffel Design by Contract** specifications for a statistical library (`simple_statistics` v1.0). This is the **SECOND review** in a chain. Ollama has already reviewed these contracts.

## Ollama's Findings

**PASTE OLLAMA'S REVIEW RESPONSE BELOW THIS LINE:**

---

[PENDING: Run Ollama first, then paste response here]

---

## Claude-Specific Review Focus

Claude will evaluate contracts from these angles:

1. **MML Model Queries** (Mathematical Modeling Language)
   - Are collections properly represented with MML?
   - For STATISTICS (stateless): Not applicable - no collections to model
   - For TEST_RESULT: assumption_checks array should have a model query
   - For REGRESSION_RESULT: residuals array should have a model query
   - For CLEANED_STATISTICS: return arrays should have model semantics

2. **Frame Conditions (What Doesn't Change)**
   - Do postconditions say what DID change?
   - Do postconditions use `old` to show previous state?
   - For immutable result classes (TEST_RESULT, REGRESSION_RESULT): All fields must be set once in `make`
   - For queries (mean, median, correlation): Result is derived, input is unchanged

3. **Correctness of Contract Logic**
   - Can the postcondition actually be violated by a wrong implementation?
   - Or is it always true regardless of implementation?
   - Examples:
     - ✗ BAD: `result_valid: True` (always true, doesn't constrain implementation)
     - ✓ GOOD: `result_non_negative: Result >= 0.0` (can be violated)

4. **Old Expressions and Temporal Logic**
   - Do postconditions properly use `old` to reference previous state?
   - Example for two-pass algorithms: Does it verify the algorithm's invariants?

## Full Contracts to Review

[Same contracts as in phase2-ollama-review.md - they are repeated here for Claude's reference]

### File 1: statistics.e
```eiffel
[FULL CONTENT - see phase2-ollama-review.md for complete file]
```

### File 2: test_result.e
```eiffel
[FULL CONTENT - see phase2-ollama-review.md for complete file]
```

### File 3: regression_result.e
```eiffel
[FULL CONTENT - see phase2-ollama-review.md for complete file]
```

### File 4: assumption_check.e
```eiffel
[FULL CONTENT - see phase2-ollama-review.md for complete file]
```

### File 5: cleaned_statistics.e
```eiffel
[FULL CONTENT - see phase2-ollama-review.md for complete file]
```

## Your Task

Given Ollama's findings above, provide Claude's perspective on:

1. **Agreement/Disagreement with Ollama**
   - Which issues does Claude consider more critical?
   - Which are false positives (not actually problems)?

2. **MML and Frame Conditions**
   - Where should MML model queries be added?
   - Where are frame conditions missing?

3. **Contract Quality Issues**
   - Which postconditions are too weak?
   - Where are edge cases not covered?

4. **Suggestions for Strengthening Contracts**
   - Specific contract rewrites
   - MML additions
   - Missing `old` expressions

Format output as:

```
ISSUE: [Description]
LOCATION: [ClassName.feature_name]
SEVERITY: [Critical / High / Medium / Low]
SUGGESTION: [How to fix]
MML REQUIRED: [Yes / No]
OLD EXPRESSION NEEDED: [Yes / No]
```

---

**END OF REVIEW PROMPT**
