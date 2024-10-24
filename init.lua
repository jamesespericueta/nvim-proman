local M = {}

local util = require('proman.utils')

function M.init()
    if not util.file_exists() then
        util.create_file()
    end
    local project_list = util.load_projects()
    if #project_list ==0 then
        vim.defer_fn(function ()
            vim.cmd('echo "Project list empty. Please add project with :AddProject command"')
            require('nvim-tree.api').tree.open()
        end, 50)
    elseif #project_list > 0 then
        local in_project = util.is_in_project(project_list)
        if not in_project then
            util.list_projects(project_list)
        elseif in_project then
            vim.defer_fn(function()
                require('nvim-tree.api').tree.open()
            end, 10)
        end
    end
end

return M
