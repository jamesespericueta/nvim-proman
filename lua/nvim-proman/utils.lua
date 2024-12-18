local M ={}

local cwd = vim.fn.getcwd()
local data_dir = vim.fn.stdpath("data") .. "/proman"
local data_file = data_dir .. "/proj-dirs.json"

---Checks if the project list file exists and returns boolean
---@return boolean
function M.file_exists()
    local f = io.open(data_file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

---Creates a json file for local storage of directory data
---@return nil
function M.create_file()
    -- checking directory viability
    if vim.fn.isdirectory(data_file) then
        print("Creating parent directories")
        vim.fn.mkdir(data_dir, "p")
    end
    print("'proj-dirs' file does not exist. Creating file...")
    local file = io.open(data_file, "w")
    if not file then
        print("'projdirs' file failed to open")
        return nil
    end
    file:write("{}")
    file:close()
end

--- returns a string of the user json file
---@return string|nil content loads JSON config file
function M.load_json()
    local file = io.open(data_file, "r")
    if not file then
        print("Could not open file")
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

--- Takes json file string and converts to lua table
---@return table|nil result JSON in Lua table format
function M.parse_json(content)
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

--- Gets projects table and parses content from JSON
---@return table|nil parsed_content Projects table
function M.load_projects()
    local content = M.load_json()
    local parsed_content = M.parse_json(content)
    return parsed_content
end

---Checks if current dir is subdirectory of possible parent
---@param parent_dir any
---@return boolean
function M.in_proj_subdir(parent_dir)
    cwd = vim.fn.getcwd()
    parent_dir = vim.fn.expand(parent_dir)
    local expanded_cwd = vim.fn.expand(cwd)
    return expanded_cwd:sub(1, #parent_dir) == parent_dir
end


---Checks if current nvim instance is within one of the project list directories
---@return table|nil table Populates table with first value index being boolean and second being location containing the directory of project
function M.is_in_project()
    local is_in = {false}
    M.iterate_projects(function(project)
        local expanded_dir = vim.fn.expand(project.directory)
        if M.in_proj_subdir(expanded_dir) then
            print("In an existing project directory")
            is_in = {true, project.directory}
        end
    end)
    return is_in
end

---safely change to directory using nvim-tree
---@param dir string directory to cd to
function M.cd_to_dir(dir)
    if M.is_dir_valid(dir) then
        vim.defer_fn(function ()
            require('nvim-tree.api').tree.open()
            require('nvim-tree.actions').root.change_dir.fn(dir,true)
        end, 10)
    else
        M.remove_project(dir)
    end
end

--- Checks if directory exists
---@param dir string
---@return boolean|nil stat Returns true if directory is accessible, otherwise false
function M.is_dir_valid(dir)
    local expanded_dir = vim.fn.expand(dir)
    local stat = vim.loop.fs_stat(expanded_dir)
    local is_valid = stat and stat.type == "directory"
    return is_valid
end

---Removes project from project listing
---@param dir string | nil
function M.remove_project(dir)
    local projects = M.load_projects()
    dir = dir or vim.fn.getcwd()

    if projects == nil then return end

    local new_project_list = {}
    for _, project in ipairs(projects) do
        local expanded_dir = vim.fn.expand(project.directory)
        local current_proj_table = {name = project.name, directory = expanded_dir}
        if dir ~= expanded_dir then
            table.insert(new_project_list, current_proj_table)
        end
    end
    local new_json = vim.json.encode(new_project_list)
    local json_file = io.open(data_file, "w+")
    if json_file ~= nil then
        json_file:write(new_json)
        json_file:close()
    end
end

--- Appends project name and directory the project json list
--- @param project_name string
function M.add_Project(project_name, directory)
    local projects = M.load_projects()
    if directory == nil then directory = vim.fn.getcwd() end
    cwd = vim.fn.getcwd()
    if project_name == "" then
        project_name = vim.fs.basename(cwd)
    end
    if projects == nil then
        print("could not load projects")
        return
    end
    local exists = false
    M.iterate_projects(function (project)
        local expanded_dir = vim.fn.expand(project.directory)
        if project_name == project.name then
            print("Error: Directory already exists with name")
            exists = true
            return
        elseif expanded_dir == cwd then
            print("Error: Project directory already exists")
            exists = true
            return
        end
    end)
    if exists then return end

    local new_project = {name = project_name, directory = cwd}
    table.insert(projects,1, new_project)
    local new_file = io.open(data_file, "w+")
    if new_file == nil then
        vim.cmd('echo "Unable to open file"')
        return nil
    end
    local new_json = vim.json.encode(projects)
    new_file:write(new_json)
    new_file:close()
end
---comment
---@param directory string directory of recent project
---@param name string recently project name
function M.updateProjects(directory, name)
    M.remove_project(directory)
    vim.defer_fn(function ()
        M.add_Project(name, directory)
    end, 10)
end

---Gets subdirectories of input directory(if any)
---@param input string
---@return table subdirs Table of subdirectories (if the input directory is valid, other wise empty table)
function M.get_subdirectories(input)
    local subdirs = {}
    local is_directory = M.is_dir_valid(input)

    if not is_directory then return subdirs end

    local directories = vim.fn.getcompletion(input, "dir")
    for _, directory in ipairs(directories) do
        table.insert(subdirs, directory)
    end
    return subdirs
end

function M.iterate_projects(func)
    local projects = M.load_projects()
    if projects == nil then return end
    for _, project in ipairs(projects) do
        func(project)
    end
end

return M
