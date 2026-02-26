# Glossator

Glossator is a Neovim plugin for (mainly myself, but also) anyone who
not only writes texts but also edits them — editors, translators,
reviewers. It adds three things to enhance the writing workflow:
visible inline markings that disappear when exported, a synchronous
note window that runs alongside the text, and a contextual toolbar
menu that makes formatting accessible without keymaps.

I mainly made this because of the synced pane because it makes writing
way easier for me. Later on added stuff I thought was handy. 

- works best with the obsidian.nvim plugin. 

## Annotations and Highlights 

 Inline tags for colour, underline and numbered annotations. Invisible
 in the rendered text, stripable at the touch of a button.

https://github.com/user-attachments/assets/fc394ec8-2eda-439f-b789-f43a94973fc1

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

https://github.com/user-attachments/assets/a83b639c-5016-4643-b6f3-d0605416d490

## KEybinds:

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

Note: The notes pane remaps dd and <CR> to preserve line-to-line
alignment between the two panes.

### Disclaimer

many aspects are vibed, I'd happily take your pr's to make the plugin
better.




