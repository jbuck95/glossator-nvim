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
vim.keymap.set("n", "<leader>gs", function() require("glossator-nvim").open_glossator() end)
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


## Verify

`:checkhealth glossator-nvim`

## Dependencies

No external dependencies. The directory `~/Documents/glossator/` is auto-created on first use.

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

## Disclaimer

Note: The notes pane remaps ``dd`` and ``<CR>`` to preserve line-to-line
alignment between the two panes.


Many aspects are vibed, I'd happily take your pr's to make the plugin
better.




