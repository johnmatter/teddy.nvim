local M = {}

local viewer = require("teddy.viewer")
local config = require("teddy.config")

function M.setup(user_config)
  config.setup(user_config)
  viewer.setup()
end

function M.view_pdf(path)
  viewer.load_pdf(path)
end

return M

