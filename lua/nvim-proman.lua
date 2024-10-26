local M = {}

local util = require('nvim-proman.utils')
local commands = require("nvim-proman.commands")
local popups   = require("nvim-proman.popups")

function M.init()
    commands.setup()
    if not util.file_exists() then
        util.create_file()
    end

    if vim.fn.argc() == 0 then
        local project_list = util.load_projects()
        if project_list ~= nil then
            if #project_list ==0 then
                vim.defer_fn(function ()
                    require('nvim-tree.api').tree.open()
                    vim.cmd('echo "Project list empty. Please add project with :AddProject command"')
                end, 50)
            elseif #project_list > 0 then
                local in_project = util.is_in_project(project_list)
                if not in_project then
                    vim.defer_fn(function ()
                        popups.open_telescope_picker()
                    end, 10)
                elseif in_project then
                    vim.defer_fn(function ()
                        require('nvim-tree.api').tree.open()
                    end, 10)
                end
            end
        end
    end

end

return M
