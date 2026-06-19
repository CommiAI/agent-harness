# Template — `fun-facts.md`

**Purpose:** trivia that a code reader would find **genuinely surprising** — the
"huh, weird" facts that only fall out of actually reading the repo. Not marketing.

## Skeleton

```markdown
# Fun facts

<1 line: "A handful of trivia about this codebase.">

## <Punchy claim as a heading>

<1 short paragraph explaining it, with the exact file / line / commit / number
that makes it true. Include a code snippet when the fact IS a snippet.>

## <Punchy claim as a heading>

<...>
```

Each fact = a **`##` heading that states the surprising claim**, followed by a
short paragraph (and optionally a code block) that proves it.

## Notes

- Every fact must be **specific and verifiable** — a path, a line count, a
  hardcoded value, a commit. "Grafana is popular" is not a fun fact; "the version
  in `main.go` is hardcoded wrong on purpose" is.
- Best sources of fun facts:
  - **Surprising constants** (a fallback version literal that isn't the real version).
  - **Biggest / oldest / weirdest file** (largest hand-written file is a schema
    converter; largest TS file is a mock fixture).
  - **Misleading names** (`ngalert` isn't next-gen anymore).
  - **Embedded surprises** (a pub/sub server embedded as a library in-process).
  - **Format/age oddities** ("the dashboard JSON format is older than React").
  - **Collisions** (three independent things all called "provisioning").
- 8–12 facts is a good page. Keep each to a tight paragraph.

## Real excerpt (grafana)

> ## The Grafana version in main.go is wrong on purpose
>
> `pkg/cmd/grafana/main.go` hardcodes `var version = "9.2.0"`. This isn't the
> actual version — it's a fallback. The real version is injected at build time via
> `-ldflags "-X main.version=..."`. The literal `9.2.0` is left so unit tests have
> something to read.
>
> ## "ngalert" is not next-generation anything anymore
>
> The unified alerting backend is named `ngalert` from when it was the
> "next-generation" engine. The legacy engine has been gone for years; `ngalert`
> is just "alerting" now. The name stays because rename PRs would be enormous.
