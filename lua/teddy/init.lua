local M = {}

local viewer = require("teddy.viewer")
local config = require("teddy.config")

function M.setup(user_config)
  config.setup(user_config)
  viewer.setup()
  
  -- Set up autocommand to handle PDF files automatically if enabled
  if config.options.auto_open then
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = "*.pdf",
      callback = function(args)
        local pdf_buf = args.buf
        local pdf_file = args.file
        
        -- Load the PDF with teddy
        vim.schedule(function()
          M.view_pdf(pdf_file)
          -- Delete the original buffer to avoid confusion
          if vim.api.nvim_buf_is_valid(pdf_buf) then
            vim.api.nvim_buf_delete(pdf_buf, { force = true })
          end
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

