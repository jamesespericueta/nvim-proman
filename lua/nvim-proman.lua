local M = {}

local util = require('nvim-proman.utils')
local commands = require("nvim-proman.commands")
local popups   = require("nvim-proman.popups")

function M.init()
    commands.setup()
    if not util.file_exists() then util.create_file() end

    if vim.fn.argc() ~= 0 then return end

    local project_list = util.load_projects()

    if not project_list then return end

    if project_list ~= nil then
        popups.handle_init_popups(project_list)
    end
end

return M
