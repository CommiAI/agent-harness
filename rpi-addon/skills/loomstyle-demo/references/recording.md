# Recording demo flows with agent-browser (visible cursor)

How to capture clean, user-facing demo clips of a web app with the **agent-browser** skill. The headline problem: Playwright video renders no mouse pointer, so you inject and animate one. The rest is gotchas learned the hard way — generic ones first, then a worked example.

## Visible cursor (the headline change)

Clicks are synthetic CDP events, so no pointer appears on the recording. Simulate one:

**Inject once per page context** — after every `record start` and after every full page load / `open` / reload (SPA route changes keep it). Append a single reused `#ab-cursor` (arrow SVG, `position:fixed`, max `z-index`, `pointer-events:none`, soft `drop-shadow`) plus a `#ab-ripple` element.

**Avoid trailing/ghosting:** animate ONE reused element with a per-frame `requestAnimationFrame` tween (ease-in-out), updating `left/top` each frame. Do **not** rely on CSS `transition` for the glide — it ghosts in capture.

**Per interaction** (run via `eval --stdin`):
1. Compute the target element's viewport center.
2. `tween(x, y, ~650ms)` to glide the cursor there.
3. `ripple()` (a quick expanding ring) + a small "press" nudge on the arrow.
4. THEN perform the real agent-browser action (`click @ref` / `fill`) on that same element.

Keep the working choreography (single `#ab-cursor`, rAF tween, ripple, `centerOf`/`byText` helpers; tunables: cursor ~26px, ripple color/size, glide duration) in a scratch file you can re-source. Add small `sleep`s between steps so the motion reads on video.

## Recording mechanics

- Use a named session: `agent-browser --session <name> ...`.
- Record: `... record start <abs>.webm "<url>"` then `... record stop`. `record start` makes a **fresh** browser context but **preserves cookies** (you stay logged in); the cursor overlay is gone after it — re-inject and re-`snapshot -i -c` (refs reset).
- After any page change / SPA route / reload, re-`snapshot -i -c` (refs go stale). `wait --url` sometimes hangs — prefer `sleep` + `get url`.
- `.webm` plays in browsers but not QuickTime. Convert with ffmpeg, e.g. GIF:
  `ffmpeg -y -i in.webm -vf "fps=15,scale=900:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" out.gif`

## React-controlled login forms

`fill` alone often does **not** register with React state, so the submit button no-ops (no network request, stays on the page). Set each input via the **native value setter + dispatched events**, in one `eval`:
`nativeSetter.call(el, value); el.dispatchEvent(new Event('input',{bubbles:true})); el.dispatchEvent(new Event('change',{bubbles:true}))`
Then click the actual button **ref**, `sleep`, and confirm the post-login URL. Save auth (`state save <path>`) and restore on expiry rather than re-logging-in each take.

Use `localhost`, not `127.0.0.1`, if the app's auth trusted-origin is `localhost` (a `127.0.0.1` mismatch fails login silently).

## Common UI gotchas

- **Modal SAVE below the fold:** `scrollintoview @<saveRef>` FIRST, then click — else the click lands on the backdrop and closes the modal with no save.
- **Row → detail:** click the inner content (`.flex-1`), not the bare row ref, which may hit a child button. Scroll the row into view first.
- **Views that fetch on mount (transcripts, history):** after navigation, wait for the work to finish, then re-`open` the same URL to force the fetch, then re-inject the cursor.
- **Native confirm dialogs** (delete, etc.) can freeze the automation daemon — auto-accept them or verify the result via DB.
- **Rate limits:** space out repeated actions (one past build limited a "run now" to once per 60s).

## Worked example — PNSB HR Agent (3 flows)

The original build recorded three flows, each demonstrating one user-visible win:

1. **Automatic check** — create a "monitor" from a template chip → run it → reload the run view to show each step → see it in history.
2. **Inbox summary** — run the check → a badge appears live on the messages mascot → open it to read the plain-language summary.
3. **Ask an uploaded report** — in chat, upload a **PDF** (vision read; xlsx broke the model call) → ask in plain English → show the headline figures.

Login persona was a neutral demo user (display name + avatar set in seed config, not a real account). Clips were 1280×578, ~10fps, silent — the narration is added later in step 3, so silent footage is fine and expected.
