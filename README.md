# teddy.nvim

TEDDY: TErminal Document DisplaY - A Neovim plugin for viewing PDF files in the terminal.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "johnmatter/teddy.nvim",
  config = function()
    require("teddy").setup({
      -- Optional configuration
      cache_dir = vim.fn.stdpath("cache") .. "/pdf_preview",
      max_cache_size_mb = 100,
      viewer_cmd = "viu",
      pdf_renderer = "pdftoppm",
      page_padding = 2,
      auto_open = true,  -- Automatically open PDFs with teddy (default: true)
    })
  end
}
```

## Usage

### Automatic PDF Opening

By default, teddy.nvim will automatically handle PDF files when you open them in Neovim (e.g., `:e document.pdf` or opening from file managers). This replaces the default behavior of reading PDFs as binary text.

To disable automatic PDF handling:
```lua
require("teddy").setup({
  auto_open = false,
})
```

### Manual PDF Viewing

```lua
-- View a PDF file manually
require("teddy").view_pdf("path/to/your/file.pdf")
```

## Requirements

- `pdftoppm` (from poppler-utils)
- `viu` (terminal image viewer)

### macOS
```
brew install viu poppler
```

## Keybindings

When viewing a PDF:
- `j` or `<C-f>` - Next page
- `k` or `<C-b>` - Previous page
