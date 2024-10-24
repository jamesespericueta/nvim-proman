local M ={}

local cwd = vim.loop.cwd()
local data_dir = vim.fn.stdpath("data") .. "/proman"
local data_file = data_dir .. "/proj-dirs.json"

function M.file_exists()
    local f = io.open(data_file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

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
    file:write("[]")
    file:close()
end

-- create file if doesnt exist
function M.load_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        print("Could not open file")
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

function M.parse_content(content)
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


function M.load_projects()
    local content = M.load_file(data_file)
    local parsed_content = M.parse_content(content)
    return parsed_content
end

function M.is_in_project(projects)
    if not projects then
        print("Error loading projects")
        return nil
    end
    for _, project in ipairs(projects) do
        local expanded_dir = vim.fn.expand(project.directory)
        expanded_dir = expanded_dir:sub(1, -2)
        if cwd == expanded_dir then
            print("In an existing project directory")
            return true
        end
    end
    print("Not in existing project directory")
    return false
end

function M.list_projects(projects)
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

-- function M.add_Project()
--    local projects = M.load_projects()
--    local current_dir = cwd
--    if projects then
--     
--    end
-- end

return M
