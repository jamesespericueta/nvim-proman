local M = {}

local util = require('nvim-proman.utils')
local popups = require('nvim-proman.popups')

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
    vim.api.nvim_create_user_command(
    'RemoveProject',
    function ()
        util.remove_project()
    end,
    {
        nargs=0,
        desc = "Remove current project listing (if current project is in the listing)"
    })
    vim.api.nvim_create_user_command(
    'PromanPopUp',
    function ()
        popups.open_telescope_picker()
    end,
    {
        nargs = 0,
        desc = "Opens up the project previewer"
    }
    )
end


return M
