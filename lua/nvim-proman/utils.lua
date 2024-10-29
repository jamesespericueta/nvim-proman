local M ={}

local cwd = vim.fn.getcwd()
local data_dir = vim.fn.stdpath("data") .. "/proman"
local data_file = data_dir .. "/proj-dirs.json"
local Path = require("plenary.path")

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

---@return table|nil result JSON string parsed into a Lua table
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
---@param projects table
---@return table|nil table Populates table with first value index being boolean and second being location containing the directory of project
function M.is_in_project(projects)
    if not projects then
        print("Error loading projects")
        return nil
    end
    for _, project in ipairs(projects) do
        local expanded_dir = vim.fn.expand(project.directory)
        if M.in_proj_subdir(expanded_dir) then
            print("In an existing project directory")
            return {true, project.directory}
        end
    end
    print("Not in existing project directory")
    return {false}
end
---Checks if the project directory is in the 
---(Using the interger as falsy value for logic)
---@return integer | nil index Returns index of directory if in project_list
---@param dir string
function M.is_in_project_list(dir)
    local projects = M.load_projects()
    if projects ~= nil then
        for index, project in ipairs(projects) do
            local expanded_dir = vim.fn.expand(project.directory)
            if dir == expanded_dir then
                return index
            end
        end
        return nil
    else
        print("Projects nil")
    end
    return 1
end

---Creates the prompt for choosing project list
---@param projects table
---@return nil
function M.list_projects(projects)
    if not projects then
        print("Could not load projects")
        return nil
    end
    if #projects == 0 then
        print("No projects. Add current directory to projects with :AddProject")
    else
        local project_name_list = {}
        local project_dir_list = {}
        for _, project in ipairs(projects) do
            table.insert(project_name_list, project.name)
            table.insert(project_dir_list, vim.fn.expand(project.directory))
        end
        vim.ui.select(project_name_list, {prompt = 'Select a project:'}, function(choice, id)
            if choice then
                if M.is_dir_valid(project_dir_list[id]) then
                    vim.cmd("cd " .. vim.fn.expand(project_dir_list[id]))
                    vim.defer_fn(function ()
                        require('nvim-tree.api').tree.open()
                    end, 10)
                else
                    M.remove_project(project_dir_list[id])
                end
            end
        end)
    end
end
-- 
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
    dir = dir or vim.fn.getcwd()
    local projects = M.load_projects()
    if projects ~= nil then
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
    else
        vim.cmd('echo "Unable to fetch projects list"')
    end
end

--- Appends project name and directory the project json list
--- @param project_name string
function M.add_Project(project_name)
    cwd = vim.fn.getcwd()
-- TODO: need to put the new added project at the top
   local projects = M.load_projects()
   if projects ~= nil then
       for _, project in ipairs(projects) do
           local expanded_dir = vim.fn.expand(project.directory)
           if project_name == project.name then
               vim.cmd('echo "Error: Directory already exists with name"')
               return nil
           elseif expanded_dir == cwd then
               vim.cmd('echo "Error: Project directory already exists"')
               return nil
           end
       end
       local new_project = {name = project_name, directory = cwd}
       table.insert(projects, new_project)
       local new_file = io.open(data_file, "w+")
       if new_file == nil then
           vim.cmd('echo "Unable to open file"')
           return nil
       end
       local new_json = vim.json.encode(projects)
       new_file:write(new_json)
       new_file:close()
   elseif projects == nil then
       print("Unable to load projects")
   end
end

---Gets subdirectories of input directory(if any)
---@param input string
---@return table subdirs Table of subdirectories (if the input directory is valid, other wise empty table)
function M.get_subdirectories(input)
    print(input)
    local subdirs = {}
    local is_directory = M.is_dir_valid(input)
    if is_directory then
        local directories = vim.fn.getcompletion(input, "dir")
        for _, directory in ipairs(directories) do
            table.insert(subdirs, directory)
        end
    end
    return subdirs
end

return M
