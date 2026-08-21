---
name: autonomous
description: Work unattended while Basile is away — ship the current thread or a named task up to a green PR, park what needs him.
disable-model-invocation: true
---

# Unattended

Basile is away. Nobody will answer a question for hours, so every question you
would have asked becomes either an assumption you write down or a **park**.

The ceiling is a **green PR**. Never merge, never push to `main`.

## 1. Pick the work

With an argument (`/autonomous 42`, `/autonomous refactor the drawer`): that is
the work. An issue number wins over guessing — read it.

Without one: continue the thread we were on. If nothing is in flight and no
backlog was named, say so in one line and stop. Inventing work unattended is how
you come back to a diff nobody asked for.

Done when you can name the work in one sentence and, if it is an issue, it is
assigned to `@me`.

## 2. Ship it

Branch `Karnak19/<kebab-summary>`. Follow the project's own rules — they outrank
anything here.

Delegate the implementation; keep your context for judgment. Verify the claims
that matter yourself.

Done when `bun run build` (or the project's equivalent) is green and you have
run the change through the app, with the shots a PR needs.

## 3. Open the PR

Use the project's `pr` skill. Drive the review bot to green: read each finding,
fix or answer it, push, wait for the re-review.

State every assumption you made in the PR body under `## Hypothèses`. An
assumption Basile discovers in the diff is a bug; one he reads in the body is a
decision he can overrule.

Done when the review is green and the PR is open. Then go back to step 1 if more
work was named.

## Park

A blocker is a thing only Basile can settle: an ambiguous spec, a decision with
real product consequences, a credential you don't have, a failure you have
genuinely exhausted.

Park it — do not stop. Leave the work where the next person can pick it up
(pushed branch, draft PR, or nothing at all if nothing was worth keeping), then
take the next unblocked thing.

Two failed attempts at the same wall is the signal. A third is stubbornness, and
you have hours to spend better.

## The handoff

Your final message is what he reads over coffee. Nothing else survives.

```
Shipped   — one line per PR, with the link
Parked    — one line per blocker: what, why it needs you, where the work sits
Assumed   — decisions you made that he might want back
```

If you shipped nothing, say that first and why, in one line.
