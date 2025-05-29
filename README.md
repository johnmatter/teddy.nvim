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
- `viu` (terminal image viewer with sixel support)

### macOS
```
brew install viu poppler
```

**Note**: Make sure your terminal supports sixel graphics. Most modern terminals like iTerm2, Alacritty, and WezTerm support sixel.

### Alternative Image Viewers

If you have issues with `viu`, you can try these alternatives:

```lua
-- Using img2sixel (dedicated sixel converter)
require("teddy").setup({
  viewer_cmd = "img2sixel",
})

-- Using chafa with sixel output
require("teddy").setup({
  viewer_cmd = "chafa --format sixel",
})

-- Using chafa (often works better in some terminals)
require("teddy").setup({
  viewer_cmd = "chafa --size 80x24",
})

-- Using img2txt (from libcaca-dev)
require("teddy").setup({
  viewer_cmd = "img2txt -W 80 -H 24",
})
```

Install alternatives:
```bash
# For img2sixel
brew install libsixel

# For chafa
brew install chafa

# For img2txt (libcaca)
brew install libcaca
```

## Keybindings

When viewing a PDF:
- `j` or `<C-f>` - Next page
- `k` or `<C-b>` - Previous page
