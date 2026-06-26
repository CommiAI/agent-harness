---
name: loomstyle-demo
description: Turn app screen-recordings into a narrated, self-contained Loom-style HTML showcase for non-technical stakeholders (a boss, a customer). Records flows with agent-browser, narrates with product-launch-video, wraps in one shareable .html.
disable-model-invocation: true
---

# Loom-style demo

The deliverable is **one shareable `.html` file** — Loom-style — that wraps a short narrated walkthrough of an app for someone non-technical. The **footage is the hero**; copy, captions, and chrome stay out of its way. The page is **self-contained**: it plays by double-click with no external files.

Three things to get right, in order — clean footage → a narrated video → the page — plus one rule that governs all three.

## The plain rule (governs every script line, caption, and card)

Translate every internal term into what a *user* would say. Never ship the engineer's word. Examples from past builds:

- "monitor" → "an automatic daily check / set it once, it runs on its own"
- "run transcript / run viewer" → "you can see exactly what it did, step by step"
- "portal notification (SSE)" → "the summary arrives right in your inbox"
- "vision/PDF parse, threadId, agent, SSE, coachmark" → drop entirely; say what the user gets

If you can't phrase a beat without a system word, you don't yet understand the user's view of it. The page is factual, not markety: a one-line lede and 2–3 numbered feature cards, not a sales pitch.

## 1. Get clean footage

**Branch — already have clips? Skip to step 2.** Otherwise record each flow with the **agent-browser** skill.

agent-browser/Playwright video renders **no mouse pointer** (clicks are synthetic events), so a viewer can't follow the action. You must inject and animate a **visible cursor** yourself, then perform the real action. This and the other capture gotchas (React forms that ignore `fill`, modal SAVE below the fold, transcripts that need a reload, rate limits) lose hours if rediscovered — read [`references/recording.md`](references/recording.md) before the first capture.

**Completion:** each flow is one clip where the cursor visibly glides to every action and each headline moment is legible at 1× playback.

## 2. Trim to the beats

Live captures carry dead air — loading spinners, the ~30s an agent thinks, pauses where nothing moves. Freeze-detect and keep only the head + tail of each beat (a small ffmpeg/python trim does this; keep a reusable copy).

**Completion:** every clip is tight — no stretch where the frame sits still and nothing is happening.

## 3. Narrate the walkthrough

Use the **product-launch-video** skill in **no-capture mode** — you already have footage, nothing to crawl. It mounts your clips as footage scenes, generates the voiceover + optional light BGM + title/caption cards, and renders one MP4.

- **Voice:** local **Kokoro** (`af_heart`, a warm female default) keeps it free and offline. Only voice a language your TTS has phonemes for.
- **Script:** one short beat per feature, in the plain rule. Map beats to scenes; a closing title card is fine.
- **On-screen text may be a second language** even when the VO is English (past build: English VO + Bahasa Melayu captions). Match the audience.
- **Pacing is the #1 redo.** Give each scene **~8–11s** so a viewer can read it; too-fast cuts are the complaint reviewers always raise. Cap/speed footage *per scene* to fit the narration, not the other way around.

**Completion:** one MP4 where the VO matches each beat and no scene flashes by before it can be read.

## 4. Wrap it in the page

Copy [`assets/wrapper-template.html`](assets/wrapper-template.html); fill in brand, title, lede, and 2–3 feature cards; embed the MP4 **and a poster still** as **base64 data URIs** so the file stands alone. The base64 build command and the bilingual-toggle gotcha are in [`references/wrapper.md`](references/wrapper.md).

- An honest "not yet" card (a limitation, stated plainly) builds more trust than omitting it.
- **Bilingual:** the EN/BM toggle flips `body.lang-ms`. Never give the body class the same name as the text-hiding class (`.ms`) — `.ms{display:none}` would then match the body and blank the whole page. This bug shipped once; the template already avoids it.

**Completion:** the `.html` opens by double-click with **no other files present**, the video plays, the copy carries no jargon, and any toggle works **both** directions — verified in a real browser (agent-browser), not assumed.

## Deliver

Hand over the single self-contained `.html` for email / Slack / Drive. If recipients also need the raw MP4, additionally give a lightweight variant that *references* the external file instead of embedding it (smaller, but no longer one file).
