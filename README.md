# Glossator

Glossator is a Neovim plugin for (mainly myself, but also) anyone who
not only writes but also edits text — editors, translators,
reviewers. It adds three things to enhance the writing workflow:
visible inline markings that disappear when exported, a synchronous
note window that runs alongside the text, and a contextual toolbar
menu that makes formatting accessible without keymaps.

I mainly made this because of the synced pane because it makes writing
way easier for me. Later on added stuff I thought was handy. 

- works best with the obsidian.nvim plugin. 

<img width="1919" height="1079" alt="Image" src="https://github.com/user-attachments/assets/1f3f529b-2f78-4133-8875-df46a51fd539" />

## Annotations and Highlights 

 Inline tags for colour, underline and numbered annotations. Invisible
 in the rendered text, stripable at the touch of a button.


## Synced Commenting-Pane

Vertical split that scrolls synchronously with the lines — notes live
alongside the text, not within it. Synced Elements: #markdown-header
and [ax] annotations - all content below these elements will be synced
accordingly. When you save the main file, elements on the right pane
will sync to match the texts line numbers.

https://github.com/user-attachments/assets/ea84ff35-db27-47da-b4af-17c68362f8b7

## Editing-Toolbar

<img width="634" height="56" alt="Image" src="https://github.com/user-attachments/assets/368badb1-84b2-4aa7-8ee6-726e37e1ccec" />

Contextual float menu via visual select — formatting, wrapping and annotation.
Highlight or annotate content and delete the marks. You will be asked
to backup your file before deleting the marks. 

**Annotate:**

https://github.com/user-attachments/assets/a83b639c-5016-4643-b6f3-d0605416d490

**Delete Marks & Backup:**

https://github.com/user-attachments/assets/fc394ec8-2eda-439f-b789-f43a94973fc1

## Commands

| Command | Action |
|---------|--------|
| `:Glossator toolbar` | Open the formatting toolbar |
| `:Glossator pane`    | Open the synchronous notes pane |

## Keymaps

No global keymaps are set automatically. Map the `<Plug>` stubs to
keys of your choice:

```lua
vim.keymap.set("v", "<leader>e",  "<Plug>(GlossatorToolbar)", { desc = "Glossator: toolbar" })
vim.keymap.set("n", "<leader>gs", "<Plug>(GlossatorPane)",    { desc = "Glossator: pane" })
```

Or call the Lua API directly:

```lua
local g = require("glossator-nvim")

g.open_glossator()      -- Open synced notes pane
g.open_toolbar()        -- Open formatting toolbar
g.load_highlights()     -- Re-run highlight rendering
g.setup({ ... })        -- Optional configuration
```

### Toolbar
| Key | Action |
|-----|--------|
| `i / f / s` | Italic / Bold / Strikethrough |
| `" ' ( [ {` | Wrap in matching characters |
| `r g b y p` | Highlight tag (color) |
| `R G B Y P` | Underline tag (color) |
| `a` | Create annotation (opens input prompt) |
| `d` | Strip all marks (backup + confirm) |
| `q / <Esc>` | Close toolbar |


## Requirements

No external dependencies. The directory `~/Documents/glossator/` is auto-created on first use.

Verify: `:checkhealth glossator-nvim`  |  Help: `:h glossator-nvim`

## Install

The plugin works out of the box — no `setup()` call required.
Conceallevel is set automatically for markdown buffers.

**Minimal** (lazy.nvim):

```lua
{
  "jbuck95/glossator-nvim",
  ft = "markdown",
  keys = {
    { "<leader>e",  "<Plug>(GlossatorToolbar)", mode = "v" },
    { "<leader>gs", "<Plug>(GlossatorPane)",    mode = "n" },
  },
}
```

**With configuration** (all fields optional):

```lua
{
  "jbuck95/glossator-nvim",
  ft = "markdown",
  keys = {
    { "<leader>e",  "<Plug>(GlossatorToolbar)", mode = "v" },
    { "<leader>gs", "<Plug>(GlossatorPane)",    mode = "n" },
  },
  config = function()
    require("glossator-nvim").setup({
      -- Annotation storage
      notes_dir = "~/Documents/glossator",       -- default
      -- resolve = function(filepath) ... end,   -- custom path resolver

      hl_tags = {                                 -- highlight tags
        { key = "r", tag = "[hr]", group = "ETRed",    hl = { bg = "#a02b2b", fg = "#ffffff" } },
        { key = "g", tag = "[hg]", group = "ETGreen",  hl = { bg = "#0f700c", fg = "#ffffff" } },
        { key = "b", tag = "[hb]", group = "ETBlue",   hl = { bg = "#2b6ba0", fg = "#ffffff" } },
        { key = "y", tag = "[hy]", group = "ETYellow", hl = { bg = "#b5a40c", fg = "#ffffff" } },
        { key = "p", tag = "[hp]", group = "ETPurple", hl = { bg = "#25184c", fg = "#ffffff" } },
      },

      ul_tags = {                                 -- underline tags
        { key = "R", tag = "[ur]", group = "ETRedUL",    hl = { underline = true, sp = "#a02b2b" } },
        { key = "G", tag = "[ug]", group = "ETGreenUL",  hl = { underline = true, sp = "#0f700c" } },
        { key = "B", tag = "[ub]", group = "ETBlueUL",   hl = { underline = true, sp = "#2b6ba0" } },
        { key = "Y", tag = "[uy]", group = "ETYellowUL", hl = { underline = true, sp = "#ddce23" } },
        { key = "P", tag = "[up]", group = "ETPurpleUL", hl = { underline = true, sp = "#7c5cbf" } },
      },

      toolbar_hl = {                              -- toolbar UI colors
        ETHeader     = { fg = "#7f849c", bold = true },
        ETKey        = { fg = "#cdd6f4", bold = true },
        ETSep        = { fg = "#45475a" },
        ETAnnotateID = { fg = "#00ffff", bold = true },
        ETComment    = { fg = "#6c7086", italic = true },
        ETAnnotate   = { underline = true, sp = "#00ffff" },
      },

      fmt_actions = {                             -- formatting actions
        { key = "i", label = "Italic", wrap = { "*",  "*"  } },
        { key = "f", label = "Bold",   wrap = { "**", "**" } },
        { key = "s", label = "Strike", wrap = { "~~", "~~" } },
      },

      par_actions = {                             -- wrapping actions
        { key = '"', label = '""', wrap = { '"', '"' } },
        { key = "'", label = "''", wrap = { "'", "'" } },
        { key = "(", label = "()", wrap = { "(", ")" } },
        { key = "[", label = "[]", wrap = { "[", "]" } },
        { key = "{", label = "{}", wrap = { "{", "}" } },
      },
    })
  end,
}
```

## Configuration

| Option | Description |
|--------|-------------|
| `notes_dir` | Directory for annotation files (default: `~/Documents/glossator`) |
| `resolve` | Custom path resolver function |
| `hl_tags` | Highlight tag definitions (key, tag, group, hl) |
| `ul_tags` | Underline tag definitions (key, tag, group, hl) |
| `toolbar_hl` | Toolbar UI highlight groups |
| `fmt_actions` | Formatting actions (italic, bold, strikethrough) |
| `par_actions` | Wrapping actions (quotes, brackets, etc.) |

## Minimal Config for Issues

```lua
vim.cmd([[set rtp+=~/.local/share/nvim/lazy/glossator-nvim]])
vim.bo.conceallevel = 2
```

## Credits

Inspired by various editor annotation and inline-comment tools.

## License

MIT

## Disclaimer

Note ``dd`` and ``<CR>`` remaps have been removed; the notes pane now relies
on SQLite-backed UUID linking which survives file moves and renames. ``:w``
in the main pane also saves the notes pane, and ``:q``/``:wq`` closes both.

Built for my personal master's thesis workflow.
AI was used extensively in development.




