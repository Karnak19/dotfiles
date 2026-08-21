---
name: drive
description: Spawn Orca workspaces from the CLI and drive them unattended on a loop — /autonomous seen from outside, across one or several workspaces.
disable-model-invocation: true
---

# Drive

You are the **driver**. The work happens in Orca workspaces you spawn; you never
open their files. Your context is for judgment, the loop, and Basile.

`/autonomous` is one agent doing the work. `/drive` is you outside N workspaces
doing it. They compose: a worker's brief can tell it to run `/autonomous`.

One worker is a legitimate fleet. You keep the conversation, it keeps the
plumbing. Use `orca-cli` for the mechanics.

## 1. Split the work

One worker per unit that can reach a green PR alone. The cost of a second worker
is not tokens, it is overlap: if two units must edit one file, that is one
worker, not two.

Done when each worker has a one-sentence goal and a file set disjoint from every
other worker's.

## 2. Isolate the blast radius

**A worktree bounds the diff, not the blast radius.** Git isolates files, not
what the checkout *points at* — and the pointer rides in with the keys, because
worktree tooling copies gitignored files so the agent gets its credentials.

Read the copied env files for values that *identify* infrastructure rather than
grant access to it: a deployment, database, bucket, project slug, webhook URL.
Then the resources nobody writes down — a fixed dev port, one test account, a
shared cache, and the browser.

The browser is the one that will surprise you: a per-session flag often names a
profile without isolating it, so concurrent workers drive the same window and one
agent's typing lands in the other's page. Verify isolation by driving two workers
at once and looking, not by trusting the flag's name.

Find out whether a write there is **destructive**. A push that replaces a whole
schema or function set does not conflict, it overwrites: no error at either
agent, and the loser's app fails later with a missing-function error that names
nothing about the cause.

Isolate before you coordinate. A lock you hold in your head is the last resort,
and the vendor's per-agent isolation usually exists:

```sh
# Convex — one dev deployment per worktree. docs.convex.dev/cli/agent-mode
npx convex deployment create dev/<slug> --type dev --select --expiration "in 5 days"
```

- A fresh backend is **empty** — a gift for testing onboarding, a cost for
  verifying a read path. Give the populated one to the worker that needs history.
- A fresh backend inherits **no secrets**, and copying them means reading them,
  which will be refused. Hand Basile the exact command with a `!` prefix and keep
  the worker parked until the values land.
- Tell each worker what it now owns and what belongs to someone else, or its
  first instinct on any trouble is to re-point at the deployment it can see.

When isolation is impossible, serialize out loud: name the holder, tell it to
signal release in plain words, tell the waiter to say it is waiting rather than
route around you. Best of all, push the isolation into the repo's setup hook so
the next worktree is born clean and none of this needs knowing.

Done when every shared mutable resource is per-worker, or under a named
serialization with an explicit release signal.

## 3. Launch

```sh
orca worktree create --repo name:<repo> --no-parent --base-branch main \
  --name <kebab-slug> --issue <n> --agent claude --prompt "<brief>" --setup run --json
```

Brief for the **traps, not the goal** — the goal is in the issue and the worker
can read. Spend the brief on what it cannot rediscover: the rule that looks like
an oversight and was a choice, the guard that must not be removed and why, the
bug a comment already records. Then name the files it must not touch, which
shared resource it owns, the build-green bar, and what is out of scope.

Check what the tooling actually made. Orca prefixes the branch itself, so a slug
you prefixed lands doubled — fix it before the worker commits.

Done when every worker is running and you have its terminal handle.

## 4. Set the loop

Nothing above survives you going quiet. `/loop` with no interval, self-paced, is
what makes this unattended.

Each tick: `orca worktree ps --json`, and for each of your workers read `state`,
the preview, and the linked PR. `terminal read` only when that is not enough to
tell thinking from finished. Then act on exactly one of:

- **stuck or idle** — it finished, or it is waiting on you. Unpark it.
- **asking** — answer it, unless the answer is Basile's to give. Then park it.
- **PR opened** — check the review bot is being driven, not ignored.
- **resource released** — hand the lock to whoever was waiting.
- **dead or interrupted** — say so; do not restart it blind.

**Tick every 5 minutes.** The instinct is to pace ticks to how long a worker runs —
tens of minutes — but that is the wrong clock. A tick costs two commands; a worker
sitting blocked on a question costs the whole gap. Pace to how long you are willing
to leave one stuck, not to how long it works. Speak only when something changed: a
quiet tick is `noop: true`, and they collapse in the user's view.

Done when the loop is set with a reason that names what you are watching.

## 5. Drive

Correct the moment a premise turns out to be wrong. A worker running forty
minutes on a stale brief is the expensive failure and the fix is one
`terminal send`: what changed, what is now allowed, what still is not.

Verify the claims that matter yourself. Workers report honestly and
incompletely — a green build is a fact, "the card renders" is a claim.

Answering a worker's question with a guess about product intent is worse than
parking it. Two failed attempts at the same wall is the signal to park.

## 6. Land

You are done when nothing is left holding something: no serialization
unreleased, no worker parked on a wait that is over, every expiring resource
noted with its expiry. What was learned goes in the repo — a rule in `AGENTS.md`
beats remembering, a setup hook beats a rule.

Then the handoff, which is all Basile reads:

```
Shipped   — one line per PR, with the link
Parked    — one line per blocker: what, why it needs him, where the work sits
Assumed   — decisions made on his behalf that he might want back
```
