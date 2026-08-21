# Writing a project's `qa` skill

This skill is a seed, not a runtime dependency. Which of the two shapes a project
gets depends on who has to run it.

**A repo other people clone: standalone.** Copy the method into
`.claude/skills/qa/SKILL.md` and edit it down to this project — its values inline,
its traps, nothing generic left over. A teammate must get a working skill from the
clone alone; a project skill that reads "see the generic skill" is broken for
everyone who never installed it. The two copies then drift, and that is the right
trade: a stale sentence is cheaper than a skill that does not load.

**A repo only you work in: a settings file.** Point at the installed copy
(`~/.agents/skills/qa/SKILL.md`) and override only what differs. Fixes upstream
reach it for free.

Either way, write down the values below — with a standalone copy they replace the
Settings block; with a settings file they are the whole file.

````markdown
---
name: qa
description: Drive a <project> change through the running app and bring back evidence. Use when asked to QA, dogfood or test a change for real, to prove a write sticks, or when a PR needs its screenshots.
---

# QA — <project>

Per-repo settings for the `qa` skill (settings-file shape — a standalone copy inlines
these instead). Read `~/.agents/skills/qa/SKILL.md` and run its
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
