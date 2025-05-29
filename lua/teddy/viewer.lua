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
    local cmd = string.format("%s -f %d -l %d -singlefile -png -r %d '%s' '%s/page_%d'", 
      config.pdf_renderer, page, page, config.pdf_dpi, state.pdf_path, cache_dir, page)
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
  
  -- Capture chafa output directly and insert into buffer
  local sixel_cmd = string.format("%s --format symbols --colors 2 --size %dx%d '%s'", 
    config.viewer_cmd, config.chafa_width, config.chafa_height, image_path)
  
  local handle = io.popen(sixel_cmd)
  local chafa_output = handle:read("*a")
  handle:close()
  
  -- Split output into lines and insert into buffer
  local lines = {}
  for line in chafa_output:gmatch("[^\r\n]*") do
    table.insert(lines, line)
  end
  
  -- Add header info
  local info_lines = {
    "=== TEDDY PDF Viewer ===",
    "File: " .. vim.fn.fnamemodify(state.pdf_path, ":t"),
    "Page: " .. page,
    "Controls: j/k or Ctrl-f/Ctrl-b to navigate",
    "========================",
    ""
  }
  
  -- Combine header and image
  for i, line in ipairs(info_lines) do
    table.insert(lines, i, line)
  end
  
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
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

