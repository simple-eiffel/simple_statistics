# Eiffel Contract Review Request (Gemini)

## Context

You are reviewing **Eiffel Design by Contract** specifications for a statistical library (`simple_statistics` v1.0). This is the **FINAL review** in a 4-AI chain. Ollama, Claude, and Grok have already reviewed these contracts.

## Previous Reviews

### Ollama's Findings

**PASTE OLLAMA'S REVIEW RESPONSE BELOW THIS LINE:**

---

[PENDING: Paste Ollama response]

---

### Claude's Findings

**PASTE CLAUDE'S REVIEW RESPONSE BELOW THIS LINE:**

---

[PENDING: Paste Claude response]

---

### Grok's Findings

**PASTE GROK'S REVIEW RESPONSE BELOW THIS LINE:**

---

[PENDING: Paste Grok response]

---

## Gemini-Specific Review Focus

Gemini will synthesize and adjudicate between reviewers, providing:

1. **Consensus Building**
   - Which issues do all AIs agree on (highest confidence)?
   - Which are disputed?
   - Which are false positives?

2. **Priority Ranking**
   - Which issues must be fixed before Phase 4?
   - Which can be addressed later?
   - Which are "nice-to-have" improvements?

3. **Contract Completeness Audit**
   - Are there entire classes missing contracts?
   - Are there common patterns of weak contracts?
   - Are there systemic issues (e.g., all postconditions too vague)?

4. **Eiffel Best Practices**
   - Do these contracts follow Eiffel Design by Contract idioms?
   - Are invariants properly expressed?
   - Is the contract-to-implementation ratio reasonable?

5. **Risk Assessment for Implementation**
   - Overall implementation risk: Low / Medium / High?
   - Which features are highest risk?
   - What could break during Phase 4?

## Your Task

As the final reviewer, synthesize all previous reviews and provide:

1. **Issues Consensus**
   - Issues agreed upon by multiple AIs (highest priority)
   - Issues raised by single AIs (lower confidence)
   - Issues that appear to be false positives

2. **Corrected Issues List**
   - Master list of all unique issues (removing duplicates)
   - Severity and priority ranking
   - Suggested fixes (taking best suggestion from previous AIs)

3. **Recommendations for Phase 4**
   - Contract changes required before implementation
   - Contract changes recommended but not required
   - Contracts that are acceptable as-is

4. **Overall Quality Assessment**
   - Can these contracts guide Phase 4 implementation?
   - Any show-stoppers or blockers?
   - Confidence level that Phase 4 will succeed with these contracts

Format final output as:

```
CONSOLIDATED ISSUE: [Description]
SOURCES: [Which AIs found this: Ollama / Claude / Grok]
CONFIDENCE: [Very High / High / Medium / Low]
SEVERITY: [Critical / High / Medium / Low]
MUST_FIX: [Yes / No / Recommended]
LOCATION: [ClassName.feature_name]
FINAL_SUGGESTION: [Best fix from all suggestions]
```

---

**END OF REVIEW PROMPT**
