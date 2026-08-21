# Browser mechanics

Reference for [`SKILL.md`](SKILL.md): getting a usable browser, and the traps that
waste an afternoon.

## Getting signed in

An app behind auth needs the `agent-browser` session authenticated before any
route is worth looking at. How is per-project — most commonly a script that mints
a test session and hands it to the browser:

```sh
<dev-server-command>              # note the port it actually picks
<sign-in-command>                 # authenticates the named session
```

The project's AGENTS.md is the source of truth for its rules — test-key guards,
credential handling, revoking afterwards. Two things it usually leaves out:

**A per-developer identity is yours to be given, not to invent.** Test accounts
often live on a dev auth instance where a work address is rejected outright. When
the identifier is missing, ask for it. Production user tables are off-limits for
this.

**The second stale-session tell.** The obvious one is being bounced to the sign-in
screen. The other reads like a broken build: the page renders its **empty state**,
the element you wait on never appears, the console is clean, and the auth cookies
are *present*. Same cause, same cure — sign in again.

## `eval`

- **Wrap each script in an IIFE.** The page context persists between calls, so a
  bare `const x = …` throws `Identifier 'x' has already been declared` on the
  second run.
- **Quote the heredoc: `<<'EOF'`.** Unquoted, the shell expands backticks and `$…`
  inside your JS — and does the same to a PR body, which is how a Markdown table
  silently loses its values.
- Prefer `eval --stdin` over inline `eval "…"` for anything containing quotes.

## "Element is covered by …"

`agent-browser click` refusing with *covered by …* usually means the target sits
**below the fold**, under a fixed bar, at `scrollY: 0`. Confirm before calling it a
regression:

```sh
cat <<'EOF' | agent-browser --session-name <name> eval --stdin
(()=>JSON.stringify({scrollY, max:document.documentElement.scrollHeight-innerHeight}))()
EOF
```

If the page scrolls, the layout is sound: scroll the element into view and click
again.

## Stacked branches

A shot shows **that layer's** state, so label which layer each shot came from — a
screenshot taken below the layer that changes the nav still shows the old nav.

Switching between stacks that differ in dependencies leaves the other one's
`node_modules` behind, and the build then fails on a missing package. Install after
every checkout.

The same trap catches documentation: a script or CSS property added in one layer
does not exist on the base branch, so anything written from memory of another
branch can describe a world the reader's checkout does not have. Run the command on
the branch you are documenting before writing it down.

## Finishing

```sh
agent-browser --session-name <name> close
```

Stop the dev server you started, and revoke any test session the sign-in step
created. A revoke that answers `Bad Request` because the tool already revoked
itself is success, not failure. Remove any worktree you added.
