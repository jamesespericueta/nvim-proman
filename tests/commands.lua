local util = require("nvim-proman.utils")

describe("Command function tests", function ()
  local lua_data
  local json_data
  before_each(function ()
    json_data = ""
    lua_data = {}
  end)


  it("Add Project", function ()
    print("Adding project")
    assert.equals(json_data, util.parse_json())
  end)

  it("Remove Project", function ()
    print("Removing project")
  end)
end)
