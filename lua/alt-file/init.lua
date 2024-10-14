local notify = require'notify'

local M = {}
M.altGroups = {}

-- Check for an altGroup that has an extension matching
-- the given file. Return the group, match index within that group,
-- and the stem (basename without extension)
local findAltGroup = function(basename)
  for g,altGroup in ipairs(M.altGroups) do
    for m,ext in ipairs(altGroup) do
      -- does the file match regex *<ext?>
      local i,j = string.find(basename,ext)
      if ( i ~= nil ) then
        local result = {}
        result.altGroup = altGroup 
        result.extIndex = m
        -- 'base' filename
        result.stem = string.sub(basename,0,i-1)
        return result
      end
    end
  end
  return nil
end

M.addAltGroup = function(altGroup)
  table.insert(M.altGroups,altGroup)
end

-- if the filename matches as an altgroup, open the next file in the altgroup
-- in the current window
-- split can be { "none", "vertical", "horizontal" }
-- where "none" will open the next file in the current  window
M.swap = function(split)

  if ( split == nil ) then
    split = "none"
  end

  if ( not (split == "none" or split == "vertical" or split == "horizontal") ) then
    split = "none"
  end

  local bufname = vim.fn.bufname()
  local basename = vim.fs.basename(bufname)
  local i,j = string.find(bufname,basename)
  local dirname = string.sub(bufname,0,i-1)

  local matchResult = findAltGroup(basename)

  if ( matchResult == nil ) then
    return
  end

  -- lua indicies start at 1
  local newExtIndex = math.fmod(matchResult.extIndex,#matchResult.altGroup) + 1
  local altFile = dirname .. matchResult.stem .. matchResult.altGroup[newExtIndex]

  if ( split == "none" ) then
    vim.cmd.edit(altFile)
  end
  if ( split == "vertical" ) then
    vim.cmd.vnew(altFile)
  end
  if ( split == "horizontal" ) then
    vim.cmd.new(altFile)
  end

end

M.setup = function(opts, groups)

  for g,altGroup in ipairs(groups) do
    M.addAltGroup(altGroup)
  end

  if ( opts.defaultGroups ~= false )  then
    notify.notify("alt-file setup adding defaults")
    M.addAltGroup({
      ".jsx",
      ".module.css"
    })
  end

end

return M
