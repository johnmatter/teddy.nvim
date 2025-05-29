local config = require("teddy.config").options
local uv = vim.loop
local M = {}

local state = {
  pdf_path = nil,
  total_pages = nil,
  current_page = 1,
  bufnr = nil,
}

local function render_page(page)
  local cache_dir = config.cache_dir .. "/" .. vim.fn.fnamemodify(state.pdf_path, ":t:r")
  vim.fn.mkdir(cache_dir, "p")
  local image_path = string.format("%s/page_%d.png", cache_dir, page)

  if vim.fn.filereadable(image_path) == 0 then
    local cmd = string.format("%s -f %d -l %d -singlefile -png -r 300 '%s' '%s/page_%d'", config.pdf_renderer, page, page, state.pdf_path, cache_dir, page)
    os.execute(cmd)
  end

  -- Create new buffer for displaying the image
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    -- Delete the existing buffer
    vim.api.nvim_buf_delete(state.bufnr, { force = true })
  end
  
  state.bufnr = vim.api.nvim_create_buf(false, true)

  -- Set buffer options before termopen potentially makes it nomodifiable
  vim.api.nvim_buf_set_option(state.bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
  
  vim.api.nvim_set_current_buf(state.bufnr)
  
  -- Use sixel output for better image display
  local sixel_cmd = string.format("%s '%s'", config.viewer_cmd, image_path)
  vim.fn.termopen(sixel_cmd, { 
    buffer = state.bufnr,
    on_exit = function()
      -- Add info after sixel renders
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(state.bufnr) then
          local info_lines = {
            "",
            "=== TEDDY PDF Viewer ===",
            "File: " .. vim.fn.fnamemodify(state.pdf_path, ":t"),
            "Page: " .. page,
            "Controls: j/k or Ctrl-f/Ctrl-b to navigate",
            "========================"
          }
          
          vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
          vim.api.nvim_buf_set_lines(state.bufnr, -1, -1, false, info_lines)
          vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
        end
      end)
    end
  })
end

local function redraw()
  render_page(state.current_page)
  setup_keymaps(state.bufnr)
end

function M.load_pdf(path)
  state.pdf_path = vim.fn.fnamemodify(path, ":p")
  state.current_page = 1
  -- total page count is optional for now
  redraw()
end

function setup_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "j", function()
    state.current_page = state.current_page + 1
    redraw()
  end, opts)
  vim.keymap.set("n", "k", function()
    state.current_page = math.max(1, state.current_page - 1)
    redraw()
  end, opts)
  vim.keymap.set("n", "<C-f>", function()
    state.current_page = state.current_page + 1
    redraw()
  end, opts)
  vim.keymap.set("n", "<C-b>", function()
    state.current_page = math.max(1, state.current_page - 1)
    redraw()
  end, opts)
end

function M.setup()
  vim.fn.mkdir(config.cache_dir, "p")
end

return M

