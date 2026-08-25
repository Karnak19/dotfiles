---
name: github-pr
description: Open a pull request on GitHub and drive the review loop to green. Use when opening a PR, pushing a branch for review, asking what the review bot says, answering review comments, fixing findings from an AI review, or creating a project's `pr` skill (per-repo settings). Covers screenshots, hosting them on the pr-media branch so GitHub renders them, waiting for the review bot, replying to its comments, and pushing fixes that trigger a re-review. GitHub only — GitLab and Azure PRs need their own skills.
---

# GitHub PR handling

The generic, GitHub-scoped skill. **Per-repo settings live in the project's own `pr` skill** (`.claude/skills/pr/` or `.agents/skills/pr/`) — when a project has one, load it first and use its settings wherever they differ from the defaults below. For team projects, **vendor this skill into the repo** (`.claude/skills/github-pr/`) — teammates can't be expected to have a machine-local copy. GitHub only: `main` is protected by a ruleset — PR required, squash-only, no force-push. Everything lands through a PR.

## Settings

Defaults; a project's `pr` skill overrides them. No project skill yet? Creating one is documented in [`references/project-pr-skill.md`](references/project-pr-skill.md) — do that when the repo deviates from these defaults.

- frontend — the project has a UI worth screenshotting; default **no** (skip screenshots entirely)
- target viewport — screenshot size; default **390x844**
- review bot — GitHub App login that reviews on push; default **none** (fall back to CI + human review)
- merge style — default **squash**
- owner/repo — derived from `git remote get-url origin`
- project board — the project number the repo's issues sit on, and the name of its status field; default **none** (skip §5 entirely)

## 1. Before opening

- Branch name: `<your-github-handle>/<lowercase-hyphenated>` (`gh api user --jq .login` for the handle). Assign the issue: `gh issue edit <n> --add-assignee @me`.
- The project's build green, per its AGENTS.md — the build is the bar. Typecheck and lint passing is not enough. Run the project's self-checks touched by the change.
- **A new check must fail on the unfixed code.** Run it against the pre-fix state and watch it go red before you trust it. A check that passes whether or not the bug exists is worse than no check: it makes the next person confident the class is covered. Both directions matter — one shipped check omitted a backslash from its payload, so it passed on a vulnerable dependency *and* would have false-failed once the dependency was fixed.
- **When the fix leans on a library's behaviour, read the installed version, not the docs.** Check `node_modules` (or the lockfile's resolved version). A parameterised query builder that looked correct escaped `'` but not `\` in the version actually installed, so the "fix" was still injectable; the root cause was a version bump, and only the installed source showed it.

## 2. Screenshots

Only when the project has a frontend (`frontend: yes` in the project's `pr` skill; default **no** — libraries, CLIs, backend-only repos skip this entire section). For frontend projects, screenshots are required for any UI change; backend-only diffs (functions, config, deps) skip them — say so in the PR body.

Capture at the target viewport (default **390x844**):

1. Start the dev server (per the project's AGENTS.md) in the background, wait for the app URL.
2. `agent-browser` (the `agent-browser` skill — read `agent-browser skills get core` if you need more than the below):

```sh
agent-browser open                     # launch first, viewport before any nav
agent-browser set viewport 390 844 2   # 2 = retina, shots stay legible
agent-browser open <app-url>/<route>
agent-browser screenshot /tmp/<name>.png
agent-browser close   # when done with every shot
```

3. One shot per screen the diff changes. Before/after only when the change is a redesign of something that already existed — otherwise after is enough.

Host them on the `pr-media` orphan branch (never merged, so PNGs stay out of `main`'s history):

```sh
# first time only
git switch --orphan pr-media && git commit --allow-empty -m "pr media" && git push -u origin pr-media

# per PR — from a temp worktree so the working branch is untouched
git worktree add /tmp/pr-media pr-media
mkdir -p /tmp/pr-media/<branch-slug> && cp shot.png /tmp/pr-media/<branch-slug>/
git -C /tmp/pr-media add -A && git -C /tmp/pr-media commit -m "shots: <branch-slug>" && git -C /tmp/pr-media push
git worktree remove /tmp/pr-media
```

Reference in the body:

```md
<img src="https://raw.githubusercontent.com/<owner>/<repo>/pr-media/<branch-slug>/shot.png" width="320" />
```

`width="320"` — raw 780px-wide images at full size make the PR body unreadable.

## 3. Body

**First line is `Closes #<n>`** (or `Fixes`/`Resolves`). It is not decoration: it populates the issue's timeline, and on a GitHub Project board it fills the `Linked pull requests` field, which is what lets a board be read without opening the PRs page. A PR whose issue link is only prose leaves the board blind.

What changed and why, in the shape the reviewer can check against the diff (an inaccurate description gets called out). Screenshots under a dedicated heading (fitcrew uses `## Écrans`). `gh pr create --fill` then edit, or `--body-file`.

**Declare any file outside the stated scope, in its own section, with why.** An unannounced out-of-scope file is the cheapest way to burn a review round — worst of all in a security PR, where a reviewer has to work out whether the extra file is part of the fix or an accident. Coupled changes are often legitimate (sanitising an error is pointless if it is routed into a monitor that silently drops it); say that rather than hoping nobody notices.

Say plainly which acceptance criteria you could **not** verify, and why. "Could not exercise a refund: the only credentials available are live" is useful. Silence reads as tested.

## 4. The review loop

If the project has a review bot (fitcrew: `fouine-review`), it reviews automatically on push. When there are no CI checks, the bot is the gate. It re-reviews the same SHA if nothing was pushed, and it says so, so **key on the head SHA, not on review count**.

Wait for it — run the wait in the background if a foreground `sleep` is blocked, 30 attempts of 30s, then give up and tell the author rather than hanging:

```sh
SHA=$(git rev-parse HEAD)
for _ in $(seq 1 30); do
  n=$(gh pr view <n> --json reviews --jq \
    "[.reviews[]|select(.author.login==\"<review-bot>\" and .commit.oid==\"$SHA\")]|length")
  [ "$n" != 0 ] && break
  sleep 30
done
[ "$n" = 0 ] && echo "no review on $SHA after 15 min"
gh pr view <n> --json reviews --jq '.reviews[-1].body'
gh api repos/<owner>/<repo>/pulls/<n>/comments --jq '.[]|{id,path,line,body}'
```

**A red check is a claim too.** Before debugging it, confirm the failure is yours: read the failing job and check whether the failing tests touch files in your diff. Suites that stand up databases, seed fixtures or drive browsers fail for environmental reasons, and a project's AGENTS.md often names its known flakes. Rerun the failed jobs first:

```sh
gh run rerun <run-id> --failed
```

If the same tests fail again, say so — but **never debug CI infrastructure from inside a feature PR**. That is a separate change with a separate reviewer, and a feature branch is the worst place to discover it.

**Verify each finding against the code before acting on it.** Review bots run on mid-tier models picked for price/performance — they hallucinate. They cite lines that don't exist, claim a function is unused when a caller is two files over, and misread control flow. Open the file it names, confirm the claim is true at that line, and only then decide. A finding is a hypothesis, not a defect report.

Then triage every finding. The review footer counts them (`Blocking: 0 · Nits: 3 · Questions: 0`).

- **Blocking** → fix. Non-negotiable.
- **Nit** → fix if the fix is smaller than the argument. Duplication findings almost always are.
- **Question** → answer it in a reply; don't change code to preempt a question.
- **Wrong or hallucinated** → reply with the evidence (the actual line, the caller it missed) and change nothing. Never edit correct code to make the review quiet — that's how a hallucination becomes a real bug.

While you're in there: if a finding names a class of problem, grep for the rest of that class in the diff and fix those too. The bot notices when you do, and it's a smaller total diff than three rounds of the same nit.

Reply to each inline comment, one reply per comment:

```sh
gh api repos/<owner>/<repo>/pulls/<n>/comments/<comment-id>/replies -f body='...'
```

Then one summary comment stating what was fixed and in which commit — a table of `finding | fix` reads best. Push the fix as a **new commit** (no amend, no force-push — the ruleset blocks force-push on `main` only, but the bot diffs against the SHA it reviewed).

Pushing triggers a new review → back to the top of this section. Cap at **3 rounds**; if round 3 still has blocking findings, stop and bring it to the author instead of looping.

Done when the bot is `APPROVED`, or when the only open findings are nits you deliberately declined and replied to.

**Approval is not the same as no open threads, and green CI is not the same as ready.** A bot can approve while inline threads it opened are still unresolved, and checks pass on fixes that do not work. List the unresolved threads and account for every one before calling it done:

```sh
gh api graphql -f query='{repository(owner:"<owner>",name:"<repo>"){pullRequest(number:<n>){
  reviewThreads(first:50){nodes{isResolved path line comments(first:1){nodes{author{login} body}}}}}}}'
```

Resolve what you fixed, reply to what you declined, leave nothing silently open.

**No review bot configured** (the default): the same gate is CI checks + human review — wait for checks, apply the same triage to human comments, and treat approval as done.

## 5. Board status

Only when the project has a board (`project board` set). **Keeping it current is yours, not a background job's** — you know your own state exactly, at the moment it changes, which no poller does.

Set the linked issue's status twice:

- **when you open the PR** → the "work in flight" value (`In review`)
- **when the review loop ends green and only a merge is left** → the "waiting on a human" value (`Blocked`)

```sh
PROJ=<project-number>; OWNER=<owner>
# item id for the issue this PR closes
gh project item-list $PROJ --owner $OWNER --format json   | jq -r '.items[] | select(.content.number==<issue>) | .id'
gh project item-edit --id <item-id> --project-id <project-id>   --field-id <status-field-id> --single-select-option-id <option-id>
```

Field and option ids come from `gh project field-list $PROJ --owner $OWNER --format json`.

Needs the `project` scope on the token. If the call fails on scope, **say so in your report** — do not skip it silently; a board nobody updates is worse than no board, because it looks current.

Two things you must not do: never invent a status value that is not already an option, and never touch an issue your PR does not close.

This is also why the first body line matters (§3): the board reads the PR through that link.

**A dead agent cannot report its own death**, so do not rely on any status meaning "stalled" — nothing sets it when an agent is working alone. Read it from data instead: an item still in the in-flight value with an old `Updated` timestamp is a stalled agent. A view filtered to the in-flight values and sorted by `Updated` oldest-first is the stalled list, and it stays true whether or not anyone remembered to write a status.

## 6. Merge

Squash only (the ruleset allows nothing else). `gh pr merge <n> --squash --delete-branch` once approved — ask the author first unless they already said to merge.
