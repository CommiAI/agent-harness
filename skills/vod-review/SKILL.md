---
name: vod-review
description: End-of-day coding session review
---

You are tasked with doing a end of day sessions review with the user.
You are doing this with the user because shipping code with AI degrades understanding of concepts tremendously, this serves as a bridge to fill those gaps and ensure that the user are able to learn and grow with AI instead of technical skill atrophy.

## Steps to follow to do vod review with user
1. **Identify today's sessions and their locations:**
    - Session metadata in `~/.claude/sessions/*.json`
    - Session messages in `~/.claude/projects/<project-path>/<sessionId>.jsonl`
    - Aggregated stats in `~/.claude/stats-cache.json`

2. **Spawn parallel sub-agents to analyze each session on:**
    - **Decisions Made**: What did the user choose AND what did they reject? Skip obvious decisions. Only surface ones where an alternative would have been reasonable.
    - **Gaps Revealed**: Where did the user struggle, go in circles, or get corrected? What concept would have made the struggle shorter?
    - **Code You Now Own**: What patterns, APIs, or techniques are baked into the code the user wrote today? These aren't "concepts to study" — they're "things that will break at 2am and you need to understand why."

3. **Present analysis to user:**

    #### Decision Trees
    For each non-obvious decision, show the fork visually:
    ```
    [Problem that needed a decision]
    ├─ Option A: [what it was] — [trade-off]
    ├─ Option B: [what it was] — [trade-off]
    └─ Option C: [what was chosen] ← YOU CHOSE THIS
       └─ Why: [the reasoning]
       └─ Trade-off: [what you gave up]
       └─ Alternative worth knowing: [a fundamentally different approach from a different concept/paradigm that solves the same problem]
    ```

    #### Mistakes → Fast Paths
    For each significant struggle:
    ```
    [Bug or problem description]

    Your path ([time spent]):
      [theory 1]? → no
      [theory 2]? → no
      [correct theory] → YES ✓

    Fast path ([estimated time]):
      [the signal that pointed to the answer]
      → [correct theory] → YES ✓

    Pattern to internalize:
      "[symptom]" = check [this] FIRST
    ```

    #### Code You Now Own
    For each significant pattern introduced today:
    - What it does and why it exists (plain English)
    - The one line/function to check first if it breaks
    - What would cause it to break (the failure mode)

    #### Growth Edge
    1-2 specific reflexes the user is missing, backed by today's evidence:
    - The specific gap (not a vague "learn more about X")
    - What it cost today (in minutes or wrong turns)
    - The reflex to build: "When you see [signal], reach for [approach] before [what you did instead]"