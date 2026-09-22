# dotfiles

Config I want on every machine.

## Skills

`skills/` holds the agent skills I wrote myself.

```sh
bunx skills add Karnak19/dotfiles -g --all
```

On the machine where I edit them, `~/.agents/skills/<name>` is a symlink
straight into this repo instead, so changes are live.

## opencode

```sh
ln -s "$PWD/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -s "$PWD/opencode/oh-my-opencode-slim.json" ~/.config/opencode/oh-my-opencode-slim.json
ln -s "$PWD/opencode/tui.json" ~/.config/opencode/tui.json
ln -s "$PWD/opencode/cli.json" ~/.config/opencode/cli.json
ln -s "$PWD/AGENTS.md" ~/.config/opencode/AGENTS.md
```

`service.json` stays machine-local: it holds a generated password.

## vim

```sh
ln -s "$PWD/vimrc" ~/.vimrc
```

Plugins are vim-plug; `~/.vim/autoload/plug.vim` is downloaded, not tracked.
Run `:PlugInstall` after linking.
