# terminal_pdf.nvim

A Neovim plugin for viewing PDF files in the terminal.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "johnmatter/terminal_pdf.nvim",
  config = function()
    require("terminal_pdf").setup({
      -- Optional configuration
      cache_dir = vim.fn.stdpath("cache") .. "/pdf_preview",
      max_cache_size_mb = 100,
      viewer_cmd = "viu",
      pdf_renderer = "pdftoppm",
      page_padding = 2,
    })
  end
}
```

## Usage

```lua
-- View a PDF file
require("terminal_pdf").view_pdf("path/to/your/file.pdf")
```

## Requirements

- `pdftoppm` (from poppler-utils)
- `viu` (terminal image viewer)

## Keybindings

When viewing a PDF:
- `j` or `<C-f>` - Next page
- `k` or `<C-b>` - Previous page 