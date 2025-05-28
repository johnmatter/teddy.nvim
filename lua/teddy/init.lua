local M = {}

local viewer = require("teddy.viewer")
local config = require("teddy.config")

function M.setup(user_config)
  config.setup(user_config)
  viewer.setup()
  
  -- Set up autocommand to handle PDF files automatically if enabled
  if config.options.auto_open then
    vim.api.nvim_create_autocmd("BufReadPre", {
      pattern = "*.pdf",
      callback = function(args)
        -- Prevent normal buffer reading
        vim.api.nvim_buf_set_option(args.buf, "readonly", true)
        vim.api.nvim_buf_set_option(args.buf, "modifiable", false)
        
        -- Load the PDF with teddy
        vim.schedule(function()
          M.view_pdf(args.file)
        end)
      end,
      group = vim.api.nvim_create_augroup("TeddyPDF", { clear = true })
    })
  end
end

function M.view_pdf(path)
  viewer.load_pdf(path)
end

return M

