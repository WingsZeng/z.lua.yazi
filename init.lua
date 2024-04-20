local function fail(s, ...) ya.notify { title = "z.lua", content = string.format(s, ...), timeout = 5, level = "error" } end

local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         return true
      end
   end
   return ok, err
end

local function entry()
  local script = os.getenv("ZLUA_SCRIPT")
  if not script or not exists(script) then
    return fail("Could not find z.lua, please make sure $ZLUA_SCRIPT is set to absolute path of z.lua.")
  end

  local value, event = ya.input {
    title = "z.lua",
    position = { "top-center", y = 2, w = 50 },
  }

  if event == 0 then
    return fail("unknown error")
  elseif event == 1 and value ~= "" then
    local output, err = Command("lua")
        :args({ script, "-e", value })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if not output then
    	return fail("Spawn `z.lua` failed with error code %s. Do you have it installed?", err)
    end

    local target = output.stdout:gsub("\n$", "")
    if target == "" then
      return fail('Could not match "%s"', value)
    end
   	ya.manager_emit("cd", { target })

  end
end

return { entry = entry }
