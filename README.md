# dotfiles

Config I want on every machine.

## Agent skills

`agents/skills/` holds the skills I wrote myself. Claude Code and other agents
read them from `~/.agents/skills`, so `./install.sh` symlinks them there.

```sh
./install.sh
```

Third-party skills installed by a package manager are not tracked here.
