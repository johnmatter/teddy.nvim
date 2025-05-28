local M = {}

local viewer = require("terminal_pdf.viewer")
local config = require("terminal_pdf.config")

function M.setup(user_config)
  config.setup(user_config)
  viewer.setup()
end

function M.view_pdf(path)
  viewer.load_pdf(path)
end

return M

