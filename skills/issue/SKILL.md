---
name: issue
description: Create or improve a GitHub issue when the user asks for a feature, bug report, product idea, or issue-quality rewrite. Use this before running gh issue create or gh issue edit so the result is a decision-ready specification grounded in the repository. Also covers labelling, priority, milestone and adding the issue to a project board at creation time.
---

# GitHub issues

An issue is a small product and engineering brief, not a sentence describing a future task. It should let someone implement the work without rediscovering the product problem, the existing design decisions, or the dangerous edge cases.

Generic and GitHub-scoped. **Per-project settings live in the project's own `issue` skill** (`.claude/skills/issue/` or `.agents/skills/issue/`) — when a project has one, load it first and use its values wherever they differ from the defaults below. Keep another project's specifics out of this skill.

## Settings

Defaults; a project's own `issue` skill overrides them.

- owner/repo — derived from `git remote get-url origin`
- title prefixes — `feat:` / `fix:` / `chore:`
- heading language — English
- priority labels — none; skip the priority step if the repo has no scheme
- project board — none; skip the board step if the repo has no board

## Workflow

1. **Research first.** Inspect at least three related issues, including any issue numbers the user names. Read the relevant code, schema, routes, and existing self-checks. Search for prior art before proposing a new table, component, dependency, or interaction. Completion means you can state what exists today, what is missing, which issues it depends on, and which constraints are already deliberate.
2. **Choose the issue type and title.** Short imperative title with the repository convention: `feat: ...` for a product capability, `fix: ...` for a broken behaviour, `chore: ...` for maintenance or infrastructure.
3. **Describe the product problem.** Start with the user's situation and the current behaviour. Explain why the gap matters and what becomes possible when it is fixed. Name dependencies and deliberate non-goals instead of hiding them in implementation notes.
4. **Make the proposal concrete.** State the intended semantics and the important trade-offs. A proposal can leave a genuine product decision open, but it must name the decision and its consequences rather than saying only "TBD".
5. **Write the risk boundary.** Call out the traps that can make a plausible implementation wrong: authorization and privacy, data ownership, legacy rows, migrations and old clients, concurrency, limits and cost, time zones, failure and fallback states, and interactions with existing product rules. Include only risks relevant to this issue, but do not omit a known hard one.
6. **Make acceptance observable.** Use checkboxes. Each criterion must describe something a user, a query, or an automated test can verify. Include the important negative cases and automated coverage when the change has logic, persistence, parsing, permissions, or external I/O.
7. **Close the scope.** Add `Out of scope` with explicit follow-ups and tempting adjacent work that this issue does not include.
8. **File it triaged** — see below. An untriaged issue is invisible.
9. **Self-review before publishing.** Check that the issue has a concrete context, a proposed direction, repository prior art or an explicit statement that none exists, named traps, testable acceptance criteria, and an out-of-scope boundary. Remove generic bullets, solutionless wishes, and claims not supported by the repository.

## File it triaged

Do this **at creation**, not in a cleanup pass later. Bare issues accumulate until someone has to triage several dozen at once, and until then the urgent ones are indistinguishable from the wishlist — a backlog where nothing is prioritised is a backlog nobody can act on.

- **Labels** — type (`bug` / `enhancement` / `chore`) plus the domain label if the repo has one. `gh label list` first; propose a new label only when a cluster genuinely lacks one.
- **Priority** — if the repo has priority labels, set one. Reserve the top level for *live in production*: exploitable, losing money, or actively wrong for users. "Important and unbuilt" is the next level down, not the top one.
- **Milestone** — when the issue belongs to a cluster with a milestone. Leave spikes and investigations **unmilestoned**: putting one in a milestone reads as a commitment to ship it.
- **Project board** — add it (`gh project item-add <n> --owner <owner> --url <issue-url>`). This needs the `project` scope on the token; if it is missing, `gh auth refresh -s project` is an interactive flow the user must run, so ask rather than skipping silently.

```sh
gh issue create --repo <owner>/<repo> --title "feat: ..." --body-file <file> \
  --label <type> --label <domain> --milestone "<milestone>"
```

**A follow-up issue names its parent** in the title or first line (`suite de #161`), so the pair is legible without reading both bodies.

## Recommended shape

```md
## Context

Who is affected, what happens today, why it matters, and which issue or product decision this follows.

## Proposed solution

The smallest coherent product behaviour, including the key trade-off.

## Prior art in the repo

Relevant files, functions, tables, indexes, components, and existing conventions to reuse.

## Traps worth naming up front

The product, data, security, performance, compatibility, and failure cases that need an explicit answer.

## Acceptance criteria

- [ ] Observable user behaviour works.
- [ ] Important negative case is handled.
- [ ] Automated coverage protects the risky logic.

## Out of scope

Adjacent work deliberately left for another issue.
```

Add a decision section between the proposal and the traps when the product decision is real and blocking. Do not force a `Prior art` section to invent relevance: state that no reusable primitive was found and explain why a new one is justified.

## Generic checks

Apply these whatever the stack; a project reference adds its own.

- Read the data model before proposing persistence. Identify ownership, indexes, bounded reads, versioning, and legacy optional fields.
- Treat deployed server functions and their existing clients as an API. Do not suggest deleting or tightening one without an expand/contract rollout.
- Separate a user's current state from historical, archived, or completed state. Say which one the feature reads or mutates.
- Preserve user isolation. A lookup must derive the authenticated user server-side; an identifier supplied by the model or client is not authorization.
- **Name the enforcement boundary.** If the datastore has its own access rules, app-side checks are not the boundary — say which layer actually enforces the rule, and whether the rule has to change too.
- Bound any list, search, prompt payload, external call, or migration batch. Explain the fallback when the bound is reached.
- Name tests for lineage and legacy data, auth boundaries, empty and ambiguous results, and failure states when they apply.
- **Say when fixing the code is not the whole remediation.** Legacy rows already written, a manual production step, a credential to rotate: put it in acceptance criteria, or merging the PR will look like closing the issue when the problem is still live.

## Publishing

For a rewrite, preserve the issue number and use `gh issue edit <number>`. After either operation, verify the title, body, labels, milestone and open state with `gh issue view <number>`.
