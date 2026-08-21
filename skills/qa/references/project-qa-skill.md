# Writing a project's `qa` skill

The generic skill holds the method; the project skill holds the values. Write one
when a repo deviates from the defaults in `SKILL.md` — which in practice is every
repo with auth or a dev server on a non-obvious port.

Put it at `.claude/skills/qa/SKILL.md` in the project. For a team repo, vendor the
generic skill in alongside it (`.claude/skills/qa-generic/` or wherever the project
keeps them) so teammates do not need a machine-local install, and point at that
copy instead of the installed one.

Keep it to a settings table plus the traps that are genuinely specific to this
codebase. Anything that would be true of another app belongs upstream in the
generic skill, not here.

````markdown
---
name: qa
description: Drive a <project> change through the running app and bring back evidence. Use when asked to QA, dogfood or test a change for real, to prove a write sticks, or when a PR needs its screenshots.
---

# QA — <project>

Per-repo settings for the `qa` skill. Read `<path-to-generic>/SKILL.md` and run its
procedure with these values:

| Setting | Value |
|---|---|
| dev server | `bun run dev` — port detected, 3000–3005 |
| app url | http://localhost:3000 |
| target viewport | 390x844 @2 |
| session name | `<project>` |
| sign-in | `bun run agent-login -- --browser` |
| ready condition | `document.querySelectorAll("nav").length` — the nav renders only for a signed-in user |
| self-checks | `for f in $(find . -name '*.check.ts'); do bun "$f" || break; done` |
| dev overlay | `nextjs-portal` |
| secondary viewport | `1280 900 2` for the desktop rail |

## Traps specific to this repo

- Which components keep state in a live subscription, so a reload cannot resurrect
  a spent form — and are therefore worth reloading with the card open.
- Any fixture gallery that covers renderer states without a model call, what it
  does prove, and what it does not.
- Emulation gaps this app actually hits, with the issue number.
````
