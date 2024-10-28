local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local util = require('nvim-proman.utils')
local entry_display = require "telescope.pickers.entry_display"
local action_state = require "telescope.actions.state"
local Path = require('plenary.path')


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

function M.not_in_project_popup()
    print("Not in an existing project, would you like to")
end
-- might use later when i learn how tf args are passed
--local function input_filter_cb(prompt_buf, input)
--    local results = {}
--    if Path:new(input):is_dir() then
--        results = util.get_subdirectories(input)
--    end
--    local current_picker = action_state.get_current_picker(prompt_buf)
--    current_picker:refresh(
--        finders.new_table({
--            results = results,
--            entry_maker = function(entry)
--                return {
--                    value =entry,
--                    display = entry,
--                    ordinal = entry
--                }
--            end,
--        }),
--        {reset_prompt = false}
--    )
--end
M.subdir_picker = function (opts)
    opts = opts or {}
    local prompt_buf
    local init_root_dir = "~/"
    local init_dirs = util.get_subdirectories(init_root_dir)
    pickers.new(opts, {
        prompt_title = "Directory being added",
        finder = finders.new_table({
            results = init_dirs,
            entry_maker = function (entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function (prompt_bufnr, map)
            prompt_buf = prompt_bufnr
            actions.select_default:replace( function ()
                actions.close(prompt_bufnr)
                print("Your selected: " .. action_state.get_selected_entry())
            end)
            return true
        end,
        on_input_filter_cb = function (input)
            local results = {}
            local valid_path = util.is_dir_valid(input)
            if valid_path then
                results = util.get_subdirectories(input)
            end
            action_state.get_current_picker(prompt_buf):refresh(
                finders.new_table({
                    results = results,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry,
                            ordinal = entry
                        }
                    end
                }),
                {
                    reset_prompt = false
                }
            )
        end
    }):find()
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
