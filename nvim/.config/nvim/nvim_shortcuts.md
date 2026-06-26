
### Neovim Shortcuts and Keybindings
Leader Key

Leader is set to Space. Most custom shortcuts start with Space.

General Navigation

<Esc>: Clear search highlights
<leader>q: Open diagnostic quickfix list
<C-h>: Move focus to left window
<C-l>: Move focus to right window
<C-j>: Move focus to lower window
<C-k>: Move focus to upper window
<t><Esc><Esc>: Exit terminal mode

File and Project Management

<leader>e: Toggle file explorer (Nvim-Tree)
<leader>sf: Fuzzy find files (Telescope)
<leader><leader>: Switch between open buffers (Telescope)
<leader>sn: Search Neovim config files
<leader>s.: Search recent files

Search and Navigation

<leader>sh: Search help tags
<leader>sk: Search keymaps
<leader>sg: Live grep across project
<leader>sd: Search diagnostics
<leader>sr: Resume last Telescope search
<leader>sw: Search current word
<leader>/: Fuzzy search in current buffer
<leader>s/: Live grep in open files
grd: Go to definition (LSP)
grr: Go to references (LSP)
gri: Go to implementation (LSP)
grD: Go to declaration (LSP)
grt: Go to type definition (LSP)
gO: Open document symbols (LSP)
gW: Open workspace symbols (LSP)

Editing and LSP

<leader>w: Save file
grn: Rename symbol (LSP)
gra: Trigger code action (LSP, normal and visual mode)
<leader>th: Toggle inlay hints (LSP)

Debugging (nvim-dap)

<F5>: Start/Continue debugging
<F10>: Step over
<F11>: Step into
<F12>: Step out
<leader>b: Toggle breakpoint
<leader>du: Toggle DAP UI
<leader>dt: Open Telescope DAP commands
<leader>r: Compile and run C file (add to init.lua if not present)

Productivity

<leader>f: Format buffer (for non-C files)

