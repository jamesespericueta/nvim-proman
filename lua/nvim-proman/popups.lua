local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local util = require('nvim-proman.utils')
local entry_display = require "telescope.pickers.entry_display"


local displayer = entry_display.create {
    separator = " ",
    items = {
        { width = 20 },
        { remaining = true },
    }
}

local make_display = function (entry)
    return displayer {
        entry.name,
        entry.directory
    }
end

M.open_telescope_picker = function(opts)
    local projects = util.load_projects()
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Projects",
        finder = finders.new_table {
            results = projects,
            entry_maker = function(entry)
                return {
                    value = entry.directory,
                    display = make_display,
                    ordinal = entry.name,
                    directory = entry.directory,
                    name = entry.name
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            vim.defer_fn(function ()
                util.cd_to_dir(selection.directory)
            end, 10)
          end)
          return true
        end,
    }):find()
end

return M
