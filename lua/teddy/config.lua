local M = {}

M.options = {
  cache_dir = vim.fn.stdpath("cache") .. "/pdf_preview",
  max_cache_size_mb = 100,
  viewer_cmd = "viu",
  pdf_renderer = "pdftoppm",
  page_padding = 2,
  auto_open = true,
}

function M.setup(user_config)
  M.options = vim.tbl_deep_extend("force", M.options, user_config or {})
end

return M

