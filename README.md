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

## Keybinds:

### Global
| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Visual | Open Toolbar |
| `<leader>gs` | Normal | Open Glossator Pane |

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


## Install (lazy)

```lua
-- ~/.config/nvim/lua/plugins/glossator-nvim.lua
return {
	"jbuck95/glossator-nvim",
	ft  = "markdown",
	keys = {
		{ "<leader>e",  "<Plug>(GlossatorToolbar)", mode = "v", ft = "markdown" },
		{ "<leader>gs", "<Plug>(GlossatorPane)",    mode = "n", ft = "markdown" },
	},
	config = function()
		
			-- ── Annotation Storage ───────────────────────────────────────────────────
			-- Option A: Fixed Folder 
			notes_dir = "~/Documents/glossator",

			-- Option B: resolve (overrides notes_dir)
			-- resolve = function(filepath)
			-- 	local dir  = vim.fn.fnamemodify(filepath, ":h")
			-- 	local name = vim.fn.fnamemodify(filepath, ":t:r")
			-- 	return dir .. "/" .. name .. ".annotations.md"     -- Set specific name for your files
			-- end,

			-- ── Highlight Tags (background color) ───────────────────────────────────
			hl_tags = {
				{ key = "r", tag = "[hr]", group = "ETRed",    hl = { bg = "#a02b2b", fg = "#ffffff" } },
				{ key = "g", tag = "[hg]", group = "ETGreen",  hl = { bg = "#0f700c", fg = "#ffffff" } },
				{ key = "b", tag = "[hb]", group = "ETBlue",   hl = { bg = "#2b6ba0", fg = "#ffffff" } },
				{ key = "y", tag = "[hy]", group = "ETYellow", hl = { bg = "#b5a40c", fg = "#ffffff" } },
				{ key = "p", tag = "[hp]", group = "ETPurple", hl = { bg = "#25184c", fg = "#ffffff" } },
			},

			-- ── Underline Tags ───────────────────────────────────────────────────────
			ul_tags = {
				{ key = "R", tag = "[ur]", group = "ETRedUL",    hl = { underline = true, sp = "#a02b2b" } },
				{ key = "G", tag = "[ug]", group = "ETGreenUL",  hl = { underline = true, sp = "#0f700c" } },
				{ key = "B", tag = "[ub]", group = "ETBlueUL",   hl = { underline = true, sp = "#2b6ba0" } },
				{ key = "Y", tag = "[uy]", group = "ETYellowUL", hl = { underline = true, sp = "#ddce23" } },
				{ key = "P", tag = "[up]", group = "ETPurpleUL", hl = { underline = true, sp = "#7c5cbf" } },
				{ key = "a", tag = "ANT",  group = "ETAnnotate", hl = { underline = true, sp = "#00A6FF" } },
			},

			-- ── Toolbar UI Colors ────────────────────────────────────────────────────
			toolbar_hl = {
				ETHeader     = { fg = "#7f849c", bold = true },
				ETKey        = { fg = "#cdd6f4", bold = true },
				ETSep        = { fg = "#45475a" },
				ETAnnotateID = { fg = "#00ffff", bold = true },
				ETComment    = { fg = "#6c7086", italic = true },
				ETAnnotate   = { underline = true, sp = "#0a477e" },
			},

		})
		vim.schedule(function()
			require("glossator-nvim").load_highlights()
		end)
	end,
}
```

## Disclaimer

Note: The notes pane remaps ``dd`` and ``<CR>`` to preserve line-to-line
alignment between the two panes.


Many aspects are vibed, I'd happily take your pr's to make the plugin
better.




