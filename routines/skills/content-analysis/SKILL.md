---
name: content-analysis
description: Monthly content analysis over a batch of emails (default the "Waiting Analysis" Gmail label) — scan a month or two of accumulated mail for trends, patterns, emerging values, and opportunities using the Thinkertoys content-analysis method, produce a written report, then clear the batch so the next cycle starts fresh. Use for a monthly inbox trend scan or when asked to analyze a parked set of emails.
---

# Content Analysis (monthly)

Run a periodic (monthly) trend scan over a batch of emails the user has let accumulate — by default everything labeled `Waiting Analysis` by the `email-triage` skill. The output is a written report of patterns and opportunities, **not** email actions. After reporting, clear the batch so it doesn't blur into next month's.

This is the back half of the inbox routine: `email-triage` parks low-value mail daily; this skill mines the pile monthly.

Uses the **Gmail connector** (MCP): `list_labels`, `search_threads`, `get_thread`, `label_thread`, `unlabel_thread`, `create_label`.

## Method — Thinkertoys "Content Analysis"

The premise (from Michael Michalko's *Thinkertoys*): your junk and routine mail, viewed in **bulk over a month or two**, reveals trends that any single email hides. Patterns emerge from repetition. The exercise is worth more than paid trend services *if* you actually look for connections to your own work.

Read the batch as a corpus and look for:

- **Recurring senders / sources** — who emails you most, and is that shifting vs. prior months?
- **Product & market trends** — what new products, features, launches, pricing moves keep appearing? What category is heating up?
- **Marketing & messaging trends** — what angles, value props, and language are vendors converging on? What new values or anxieties are they appealing to?
- **Emerging themes** — topics that went from 0 → many mentions this period.
- **Shifts vs. last period** — what's in your "in-basket" now vs. the same window last month/last year? More of what, less of what? Where is your professional world heading?
- **The overlap** — the most interesting signal is where a sender crossed from promo → personal outreach, or where junk-mail trends intersect a real project you're working on.
- **Opportunities** — for each pattern, pump for ideas: business possibilities, things to try, people to talk to, gaps in the market.

## Workflow

1. **Resolve the batch.** Default scope = the `Waiting Analysis` label. Resolve its ID via `list_labels`, then:
   ```
   search_threads(query='label:<Waiting Analysis id>', view=THREAD_VIEW_METADATA_ONLY, pageSize=50)
   ```
   Paginate via `nextPageToken` until exhausted. If the user names a different scope (a sender, `category:promotions`, a date range like `newer_than:60d`), use that query instead.
2. **Sample for depth.** Metadata (sender, subject, date) is enough for most pattern-finding. For threads that look thematically important, `get_thread` to read the body. Don't read all of them — read enough to ground each claimed trend in real examples.
3. **Analyze** against the method above. Quantify where you can ("11 of 40 were dev-tooling launches"). Tie every trend to at least one concrete example sender/subject.
4. **Write the report** (see format below).
5. **Clear the batch** so next cycle is clean:
   - Remove the `Waiting Analysis` label from the analyzed threads (`unlabel_thread`).
   - **Optionally** add a dated archive label `Analyzed YYYY-MM` (create it if missing) so each month's batch stays recoverable.
   - Do **not** delete or move to Spam/Trash. Confirm with the user before clearing if the batch is large.

## Report format

- **Summary** — 2-3 sentences: the shape of this month's mail.
- **Top trends** — bulleted, each with: the pattern, how strong (counts), 1-2 example senders/subjects, and what it might mean.
- **Shifts vs. last period** — what changed (only if a prior `Analyzed YYYY-MM` batch exists to compare against).
- **Opportunities & ideas** — concrete prompts for the user: things to build, try, watch, or follow up on, especially where a trend touches their actual work.
- **Housekeeping** — count analyzed, count cleared, and the archive label used (if any).

## Notes

- Runs **on demand / monthly** — it does not schedule itself. A scheduled task would invoke it with a prompt like: *"Use the content-analysis skill on the emails labeled Waiting Analysis, produce the report, then remove the label."*
- General-purpose: point it at any label, sender, or date range — it isn't hardwired to `Waiting Analysis`, that's just the default that pairs with `email-triage`.
- Connector availability in headless/scheduled runs is not guaranteed — verify before trusting a schedule.
