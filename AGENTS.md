# Working in this repo

Basile's dotfiles. Two kinds of content, both linked into `$HOME` rather than
copied, so **editing a file here changes the live config immediately** — there is
no install step to run after a change.

| path | linked from | notes |
|---|---|---|
| `skills/<name>/` | `~/.agents/skills/<name>` | agents read skills from there; `~/.claude/skills/<name>` links on to it |
| `vimrc` | `~/.vimrc` | vim-plug plugins, `:PlugInstall` after a fresh link |

The repo is **public** so a friend can `bunx skills add Karnak19/dotfiles`. Never
commit credentials, private hostnames, machine-local absolute paths, or client
material. Basile's own project names are fine.

## Skills

Only skills Basile wrote himself belong here. Third-party ones are installed by
the `skills` CLI into `~/.agents/skills` and tracked by its own lock file — do
not copy those in.

A skill is `skills/<name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: <same as the directory>
description: <what it does, then when to use it — this is the only thing an agent
  sees before loading the skill, so it has to carry the trigger words>
---
```

The `description` is a matcher, not a summary. If it does not name the situations
and phrasings that should pull the skill in, the skill never fires. Longer
material goes in sibling files (`reference.md`, `references/*.md`) that `SKILL.md`
links to, so the body stays cheap to read.

The `writing-great-skills` skill (installed globally) has the full guidance —
read it before adding or restructuring one.

## Conventions

- Files keep the undotted name (`vimrc`, not `.vimrc`); the dot is added by the symlink.
- Branches: `Karnak19/<lowercase-hyphenated>`.
- Commit subjects in the imperative, no scope prefix — this repo is not a product.
