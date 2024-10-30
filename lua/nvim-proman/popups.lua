local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local util = require('nvim-proman.utils')
local entry_display = require "telescope.pickers.entry_display"
local action_state = require "telescope.actions.state"
local Popup = require('plenary.popup')

local results = {}


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
    Popup.create({
        "Testing",
        "heres some more"
    }, {
        padding = {3,3,3,3},
        border = {},
        title = "Add Directory?",
        enter = false
    })
end

M.subdir_picker = function (opts)
    opts = opts or {}
    local init_root_dir = "~/"
    local init_dirs = util.get_subdirectories(init_root_dir)
    local current_picker
    local prev_prompt
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
            current_picker = action_state.get_current_picker(prompt_bufnr)
            actions.select_default:replace( function ()
            actions.close(prompt_bufnr)
            vim.defer_fn(function ()
                util.cd_to_dir(action_state.get_selected_entry().value)
            end, 10)
            end)
            return true
        end,
        on_input_filter_cb = function (input)
            vim.defer_fn(function ()
                input = current_picker:_get_prompt()
                local valid_path = util.is_dir_valid(input)
                local repeating = input == prev_prompt
                if valid_path and not repeating then
                    prev_prompt = input
                    results = util.get_subdirectories(input)
                    current_picker:refresh(
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
            end, 10)
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

function M.handle_init_popups(project_list)
    if #project_list ==0 then
        vim.defer_fn(function ()
            require('nvim-tree.api').tree.open()
            vim.cmd('echo "Project list empty. Please add project with :AddProject command"')
        end, 50)
    elseif #project_list > 0 then
        local in_project = util.is_in_project()
        if in_project == nil then
            print("Project check failed")
        elseif not in_project[1] then
            vim.defer_fn(function ()
                M.open_telescope_picker()
            end, 10)
        elseif in_project then
            vim.defer_fn(function ()
                util.cd_to_dir(in_project[2])
            end, 10)
        end
    end
end
return M
