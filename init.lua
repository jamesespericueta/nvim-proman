-- ~/.config/nvim/lua/my_plugin/init.lua
local M = {}
local data_file = "proj-dirs.json"
local cwd = vim.loop.cwd()

-- check file exists
local function file_exists()
    local f = io.open(data_file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

local function create_file()
    print("'proj-dirs' file does not exist. Creating file...")
    local file = io.open(data_file, "w")
    if not file then
        print("'proj-dirs' file failed to open")
        return nil
    end
    file:write("")
    file:close()
end

-- create file if doesnt exist
local function load_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        print("Could not open file")
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function parse_content(content)
    if not content then
        print("Error: File content is nil")
        return nil
    elseif content == "" then
        print("JSON empty, please add a directory with :addProject")
        return {}
    else
        local ok, result = pcall(vim.json.decode, content)
        if not ok then
            print("Error parsing json: ".. result)
            return nil
        end
        return result
    end
end


local function load_projects()
    local content = load_file(data_file)
    local parsed_content = parse_content(content)
    return parsed_content
end

local function is_in_project(projects)
    if not projects then
        print("Error loading projects")
        return nil
    end
    for _, project in ipairs(projects) do
        local expanded_dir = vim.fn.expand(project.directory)
        expanded_dir = expanded_dir:sub(1, -2)
        print("cwd:", cwd, "expanded:", expanded_dir)
        print("expanded == cwd:", (expanded_dir == cwd))
        if cwd == expanded_dir then
            print("In an existing project directory")
            return true
        end
    end
    print("Not in existing project directory")
    return false
end

local function list_projects(projects)
    if not projects then
        print("Could not load projects")
        return nil
    end
    if #projects == 0 then
        print("No projects. Add current directory to projects with :AddProject")
    else
        vim.ui.select(projects, {prompt = 'Select a project:'}, function(choice)
            if choice then
                vim.cmd("cd " .. vim.fn.expand(choice))
            end
        end)
    end
end
--
-- local function add_Project()
--    local projects = load_projects()
--    local current_dir = cwd
--    if projects then
--     
--    end
-- end
--
function M.init()
    if not file_exists() then
        create_file()
    end
    local project_list = load_projects()
    local in_project = is_in_project(project_list)
    if not in_project then
        list_projects(project_list)
    elseif in_project then
        vim.defer_fn(function()
            require('nvim-tree.api').tree.open()
        end, 10)
    end
end

return M
