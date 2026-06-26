---
name: ticket-curation
description: Curate a product development ticket through a 10-section template (motivation, user story, design/flow, functional requirements, QA notes, out-of-scope, links, affected ventures, affected platforms, CC) so the thinking is finished before development starts. Use when the user wants to write or draft a new ticket, refine or review a ticket draft, turn a feature idea or bug report into a ticket, set up a ticket template, or groom a backlog item.
---

# Ticket Curation

A ticket is a **living document**, not a form to clear. You curate it by walking ten sections, each a **lens** that activates a different perspective — business, user, designer, developer, breaker, historian. The lenses are how you find the holes; the document is the residue.

The whole skill rides one gate:

> **A section you can't fill is unfinished thinking, not an optional field.**

Getting stuck is the signal working as intended — it means there's a question still to ask, not a heading to delete. So the completion criterion is exhaustive: **every section holds real content or an explicit, owned open question** — never blank, never hand-waved.

## Getting Started

When invoked:
1. Gather what exists — the user's idea, an existing draft, a linked issue, a Slack thread. If curating an existing ticket, read it first and map its current content onto the ten sections.
2. Copy the template as the working skeleton:
   `Read(${CLAUDE_SKILL_DIR}/references/ticket-template.md)`
3. Walk the sections in order. Each section below names the lens it puts on and what finished looks like.

## The ten lenses

1. **Motivation & Business Impact** — *the why.* What triggered this, the business context, and how impact gets measured. Reach for Hypothesis-Driven framing: *We believe <capability> · will result <outcome> · we'll have confidence to proceed when <measurable signal>.* No measurable signal means the value is still vague.

2. **User Story & High-Level Acceptance Criteria** — *the user's outcome.* Translate the business goal into one frame — Classic ("As a … I want … so that …"), BDD ("Given … When … Then …"), or Job ("When <situation> I want <motivation> …") — and list the acceptance criteria that make it true.

3. **User Interaction / Design / Flow** — *the experience.* Step through the journey, current state vs. proposed, with mockups or screenshots. Apply *Don't Make Me Think*: every message, button, and field self-explanatory to a first-time user.

4. **Functional Requirements & Developer Notes** — *the build.* Co-author with a developer during grooming. Validations, data types, accepted inputs, edge values; schemas, diagrams, or a BPM table where rules branch.

5. **QA Notes** — *test to break.* Switch from happy path to "what could go wrong? what could the user do unintentionally?" Cases this lens surfaces that the sections above don't cover are **new requirements** — push them back up, don't bury them here.

6. **Not in Scope, Questions & Answers** — *the boundary and the memory.* State what's deliberately excluded, and record decisions as *question → answer + why*. Pay it forward: the rationale is for the colleague who reads this in six months. Keep unresolved items as owned open questions.

7. **Links & References** — *the context.* Earlier tickets, specs, Drive/Confluence docs, anything new this work created. Spare the next person the incomplete-context struggle.

8. **Affected Ventures** — *blast radius, products.* Which apps or product ventures this change touches.

9. **Affected Platforms** — *blast radius, systems.* Other systems, services, or platforms in the ecosystem that need involvement or a heads-up.

10. **CC / "To Be Informed"** — *the people.* Tag those who should be aware but aren't building it: PM, support, business, area reps.

## Hand back

Deliver the filled ticket. Then surface, plainly, **where you got stuck** — every section left as an open question — because that list is the unfinished thinking the gate exists to expose, and it's what the user works through next.
