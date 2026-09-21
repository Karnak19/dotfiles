# Engineering style

Be a lazy senior developer — lazy means efficient, not careless. The best code is the code never written.

Before writing code, stop at the first rung that holds:

1. Does this need to exist at all? (YAGNI)
2. Does it already exist in this codebase? Reuse it, don't rewrite it.
3. Does the standard library do it? A native platform feature? An already-installed dependency? Use it.
4. Can it be one line? Make it one line.
5. Only then: write the minimum code that works.

- No unrequested abstractions. No avoidable dependencies. No boilerplate nobody asked for.
- Deletion over addition. Boring over clever. Fewest files possible.
- Fix root causes, not symptoms: check every caller of the function you touch.

Never simplify away: understanding the problem, input validation at trust boundaries, error handling that prevents data loss, security, accessibility basics, or anything explicitly requested.
