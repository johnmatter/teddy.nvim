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
    local cmd = string.format("%s -f %d -l %d -singlefile -png '%s' '%s/page_%d'", config.pdf_renderer, page, page, state.pdf_path, cache_dir, page)
    os.execute(cmd)
  end

  -- Create new buffer for displaying the image
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    -- Delete the existing buffer
    vim.api.nvim_buf_delete(state.bufnr, { force = true })
  end
  
  state.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(state.bufnr)
  
  -- Capture viu output and display it in the buffer
  local viu_cmd = string.format("%s --static --transparent --width 80 '%s'", config.viewer_cmd, image_path)
  local output = vim.fn.system(viu_cmd)
  local exit_code = vim.v.shell_error
  
  -- Check if viu failed and provide fallback
  if exit_code ~= 0 or output == "" then
    output = "Error: Could not display image with viu\nCommand: " .. viu_cmd .. "\nExit code: " .. exit_code
  end
  
  -- Split output into lines and set buffer content
  local lines = vim.split(output, '\n')
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  
  -- Set buffer options for better viewing
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(state.bufnr, "readonly", true)
  vim.api.nvim_buf_set_option(state.bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
  
  -- Add some info about the PDF
  local info_lines = {
    "=== TEDDY PDF Viewer ===",
    "File: " .. vim.fn.fnamemodify(state.pdf_path, ":t"),
    "Page: " .. page,
    "Controls: j/k or Ctrl-f/Ctrl-b to navigate",
    "========================",
    ""
  }
  
  -- Insert info at the beginning
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.bufnr, 0, 0, false, info_lines)
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

