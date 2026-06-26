# Building the self-contained page

`assets/wrapper-template.html` is the Loom-style shell. Fill the `{{PLACEHOLDERS}}`, embed the media as base64, verify in a browser.

## What to fill in

- `{{TITLE}}`, `{{WORDMARK}}`, `{{EYEBROW}}`, `{{LEDE}}` — brand + one-line factual intro.
- Brand tokens in `:root` — `--cobalt` (primary), `--ink`, `--slate`, `--gold` (sparing accent). Pull the real values from the app so the page matches the product. Keep grays neutral; expose the accent (gold) as a token used *sparingly* (a footer rule, a divider), never bleeding into body text.
- 2–3 feature `.card`s — number, `h3`, one plain-language sentence each (see the plain rule in SKILL.md).
- `{{POSTER_BASE64}}` and `{{VIDEO_BASE64}}` — see below.

## Embedding media as base64

The page must stand alone, so the MP4 and a poster still go inline as data URIs:

```bash
# poster still (1s in), then base64 each asset
ffmpeg -y -ss 1 -i video.mp4 -frames:v 1 poster.jpg
base64 -i poster.jpg -o poster.b64
base64 -i video.mp4 -o video.b64
```

Inject `data:image/jpeg;base64,<poster.b64>` into the `<video poster="...">` and `data:video/mp4;base64,<video.b64>` into `<source src="...">`. A ~5 MB MP4 becomes a ~7 MB HTML — fine for email/Drive. Because the base64 string is huge, the Read/Edit tools may choke on the finished file; do the final injection and any later text tweaks with targeted shell edits (grep to locate, sed/python to replace a specific tag), not by re-reading the whole file.

## Bilingual toggle — the collision gotcha

The toggle flips a class on `<body>` and CSS swaps `.en`/`.ms` spans. The bug that shipped once: the body class was named `ms`, the same as the text-hiding class, so `.ms{display:none}` matched `<body class="ms">` and blanked the entire page.

**The fix (already in the template):** the body class is `lang-ms`, distinct from the span class `.ms`:

```css
.ms{display:none}
body.lang-ms .en{display:none}
body.lang-ms .ms{display:revert}
```

The toggle JS does `body.classList.toggle("lang-ms", lang === "ms")`. To make the page **single-language**, delete the `.lang` toggle markup, the `<script>`, every `.ms` span, and the three rules above.

## Verify before sending

Open the finished `.html` by double-click (or via agent-browser) with **no sibling files present**: the video must play from base64, and if bilingual, clicking EN→BM→EN must swap copy both directions and never blank the page. Confirm in a real browser — don't assume.
