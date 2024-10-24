local M = {}

local util = require('proman.utils')

function M.setup()
    vim.api.nvim_create_user_command(
    'AddProject',
    function (opts)
        local project_name = opts.args
        util.add_Project(project_name)
    end,
    {
        nargs = 1,
        desc = "Add a project to the project manager list"
    })
end

return M
