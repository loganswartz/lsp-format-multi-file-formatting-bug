# Formatting bug in lsp-format.nvim

Sometimes when formatting multiple files within a short time of each other,
lsp-format seems to save the formatting result of one file over top of the other
file.

## How to Reproduce

Clone this repo, and open Neovim with the included vimrc (`nvim -u vimrc.lua`).
Then, do `:ReproduceBug`. That command just runs the following commands with
consistent timing:

1. `:e a.lua`
2. `:w`
3. `:e b.lua`
4. `:w`
5. `:e a.lua`

Sometimes it doesn't work for me until after restarting Neovim once after the
lazy.nvim installs.

It seems like this is caused by some sort of interference of lua_ls (or any LSP)
with null-ls/none-ls, combined with system load and/or a race condition of some
sort. Oddly enough, builtin formatting sources for null-ls don't seem to cause
problems for me, but code_action sources do. See the `none-ls` section of the
vimrc for some additional information.

Possibly worth noting, when I was writing up the `:ReproduceBug` command, the
bug didn't seem to occur if I used `vim.uv.sleep`. It only happened when using
`:sleep` (but that might not stand up to scrutiny). Since this seems to be a
timing issue, you might have to tweak the delay time; 250ms seems to be the
sweet spot for my environment, but even that seems to be a bit dependent on
system load, etc.

## Misc

The vimrc configures lazy.nvim to install itself into this folder, so this
example should be entirely self-contained.
