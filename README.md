# dotfiles

Config I want on every machine.

## Skills

`skills/` holds the agent skills I wrote myself.

```sh
bunx skills add Karnak19/dotfiles -g --all
```

On the machine where I edit them, `~/.agents/skills/<name>` is a symlink
straight into this repo instead, so changes are live.

## vim

```sh
ln -s "$PWD/vimrc" ~/.vimrc
```

Plugins are vim-plug; `~/.vim/autoload/plug.vim` is downloaded, not tracked.
Run `:PlugInstall` after linking.
