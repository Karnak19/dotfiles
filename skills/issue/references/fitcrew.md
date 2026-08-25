# FitCrew

Project settings for the `issue` skill. Repo: `govroumvroum/fitcrew`.

- repo — `govroumvroum/fitcrew`
- title prefixes — `feat:` / `fix:` / `chore:`
- headings — mixed French/English is the house style; keep `Contexte`, `Prior art dans le repo`,
  and `À trancher avant d'implémenter` in French
- stack — Convex, Clerk, Bun, Next.js

## Project-specific checks

- Read the data model before proposing persistence. Identify ownership, indexes, bounded reads, versioning, and legacy optional fields.
- Treat Convex functions and their existing clients as an API. Do not suggest deleting or tightening a function without an expand/contract rollout.
- Separate a user's current state from historical, archived, or completed state. Say which one the feature reads or mutates.
- For Coach or Chef work, state what enters the system prompt, what is fetched on demand, what the model may mutate, and how the tool behaves when context is absent or ambiguous.
- Preserve user isolation. A lookup must derive the authenticated user server-side; an identifier supplied by the model or client is not authorization.
- Bound any list, search, prompt payload, external call, or migration batch. Explain the fallback when the bound is reached.
- Name tests for lineage and legacy data, auth boundaries, empty and ambiguous results, and failure states when they apply.

## Publishing

```sh
gh issue create --repo govroumvroum/fitcrew --title "feat: ..." --body-file <file>
```
