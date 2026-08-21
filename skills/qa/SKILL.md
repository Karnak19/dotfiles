---
name: qa
description: Drive a change through the running app and bring back evidence. Use when asked to QA, dogfood, verify or test a change for real rather than in the abstract; to prove a write survives a reload, that a new UI state renders, or that an agent actually calls a new tool; to capture screenshots of a change for a PR; or to create a project's own `qa` skill (per-project settings). Browser-driven — not a substitute for unit tests.
---

# QA

**Drive** the change: make it happen through the UI, the way a user reaches it. A
green build says the code compiles and a screenshot says a screen rendered once —
neither says the write survived a reload, that the branch you added is reachable,
or that the model calls the tool you registered. Driving produces **evidence**;
inspecting produces an impression.

Browser mechanics — signing in, `eval` traps, cleanup — are in
[`reference.md`](reference.md). Read it before the first `agent-browser` command.
Getting the shots into a PR is the `github-pr` skill's job.

## Settings

Defaults; **a project's own `qa` skill overrides them** (`.claude/skills/qa/` or
`.agents/skills/qa/`) — load it first when the project has one. Writing one is
documented in [`references/project-qa-skill.md`](references/project-qa-skill.md).

- dev server — command that starts the app, and the URL it serves; default from the project's AGENTS.md
- target viewport — default **390x844 @2**
- session name — `agent-browser --session-name <name>`; default the project directory name
- sign-in — command that authenticates the browser session; default **none** (public app)
- ready condition — a DOM query that is only true once the app has hydrated *and* loaded its data
- self-checks — command that runs the project's fast checks; default the test script in its AGENTS.md
- dev overlay — selector for the dev-server badge to hide; default `nextjs-portal` for Next.js, none otherwise

## 1. Drive it

Ask what the change makes *happen*, then make it happen through the UI. Reaching
into the database to set state, or calling the function directly, tests the
function — that is a unit test's job, and it is not what was asked for.

| change | how you drive it |
|---|---|
| a new agent tool | talk to the agent until it calls the tool |
| a nav change | navigate — back button, deep link, tap the route you are already on |
| a guard or refusal | violate it and read what comes back |
| a write path | write, reload, look again |
| a state machine | every branch, empty and error included |

**A new agent tool** is the case that looks obviously right in the diff, so drive
all four:

1. **The model calls it.** Write a message that should trigger it. Prose instead of
   a tool call is a finding — in the prompt, and a real one. Registering a tool
   does not make it called.
2. **Its output renders as intended.** Tool-call renderers typically switch on a
   **string** name with the payload typed `unknown`, so a misspelled tool name
   compiles, lints, builds, and quietly falls through to the generic branch. Cover
   every state the renderer declares, the streaming and error ones included.
3. **The write landed.** The agent saying it saved is not evidence. Read the screen
   that reads the data, after a reload.
4. **An empty result stays quiet.** Feed it something that finds nothing, and check
   nothing is claimed about output that does not exist.

Keep it to the two or three messages that actually hit the path — every turn is a
billed model call.

**Done when** every path the diff touches has been driven through the UI.

## 2. Capture

```sh
agent-browser --session-name <name> open                    # launch first
agent-browser --session-name <name> set viewport 390 844 2  # before navigating
agent-browser --session-name <name> open <app-url>/<route>
```

Hide the dev overlay every time — it sits over exactly the bottom-anchored UI you
are trying to show:

```sh
cat <<'EOF' | agent-browser --session-name <name> eval --stdin
(()=>{const s=document.createElement('style');
s.textContent='nextjs-portal{display:none !important}';
document.head.appendChild(s);return 'ok'})()
EOF
```

Wait for a **condition**, never a delay: a fixed `sleep` catches the app
mid-request and captures an empty state no user ever sees.

```sh
until [ "$(agent-browser --session-name <name> eval 'document.querySelectorAll("nav").length' 2>/dev/null)" != "0" ]; do sleep 2; done
```

Pick a condition that can only be true once the app is really ready — an element
that renders only for a signed-in user proves auth hydrated; the screen's own data
needs its own wait. Components that only exist at another breakpoint need their own
shot at their own viewport.

**Done when** each screen the diff changes has a shot at the target viewport with
the overlay hidden.

## 3. Measure

Geometric and structural claims survive in numbers, not pictures. Read them from
the DOM and put them in the PR body:

```sh
cat <<'EOF' | agent-browser --session-name <name> eval --stdin
(()=>{const p=document.querySelector('[data-slot="popup"]');
const r=p.getBoundingClientRect(), cs=getComputedStyle(p);
return JSON.stringify({maxH:cs.maxHeight, fits:r.bottom<=innerHeight&&r.top>=0})})()
EOF
```

What this catches that no build does: a real `max-height` on a popup, proving the
custom property its class reads actually resolved and keeps the panel on a 390px
screen; `nestedButton: false`, proving an `asChild` trigger produced one element
rather than a button inside a button; `aria-valuenow`, proving a progress bar
forwards its value at all.

Read the selector or property name out of the component rather than from memory — a
stale name silently returns nothing, which reads exactly like a pass.

Where emulation cannot reach, write that down instead of implying coverage. The
standing case is the **installed iOS PWA safe area**: Chrome does not reproduce
`env(safe-area-inset-bottom)` in standalone mode, so it needs a real phone.

**Done when** every claim in the PR body is either a number read from the DOM or
named as unverified.

## Before the browser

Run the project's fast checks first — they are quicker than a click-through, and a
failing check makes every screenshot suspect.
