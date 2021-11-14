--[[
  Sandbox for testing neorg plugins

  see here:
  https://github.com/nvim-neorg/neorg/wiki/Creating-Modules

--]]

require("neorg.modules.base")
require('neorg.events')

-- normal setup consists of 
-- 1. creating a module
-- 2. setup (pre-loading prerequisite modules) - enables module.required[module_name]
-- 3. load (initialization)
local module = neorg.modules.create("utilities.dateinserter")
local log = require('neorg.external.log')

module.setup = function()
	return {
    success = true,
    requires = {
      "core.keybinds",
      "core.norg.dirman",
      "core.autocommands",
      "core.neorgcmd",
      "core.keybinds",
    }
  }
end

module.load = function()
  log.warn("DATEINSERTER loaded!")
  neorg.events.broadcast_event(neorg.events.create(module, "utilities.dateinserter.events.our_event"))
  module.required["core.autocommands"].enable_autocommand("insertenter")
  module.required["core.neorgcmd"].add_commands_from_table({
    definitions = { test_command = {} },
    data = { test_command = { args = 1, name = "our.test_command" } }
  })
  module.required["core.keybinds"].register_keybind(module.name, "my_keybind")
end

-- API
-- public: where functions should go
-- config.public: can be overridden in neorg.setup call
-- config.private: cannot be overloaded in neorg.setup call
module.public = {
  version = '0.1',
  insert_datetime = function()
    vim.cmd("put =strftime('%c')")
  end
}

module.config.public = {
  enable_auto_insertenter = false
}

-- events consist of the following:
-- 1. define an event (module.events.defined)
-- 2. create an event (neorg.events.create)
-- 3. subscribe (module.events.subscribed)/callback (module.on_event)
--
-- events consist of the following:
-- * type: absolute path (split_type splits this at ".event.")
-- * content: table added in neorg.events.create
-- * referrer: source module
-- * others: broadcast, cursor_position, filename, filehead, line_content
--
-- events enable the following:
--
-- keybinds: https://github.com/nvim-neorg/neorg/wiki/Keybinds
-- 1. register_keybind in load (and require in setup)
-- 2. subscribe/write callback
-- -- note that the user is responsible for binding a key to the event
--
-- commands: https://github.com/nvim-neorg/neorg/wiki/Neorg-Command
-- 1. call "core.neorgcmd".add_commands_from_table in load (and require in setup)
--    (the data is the args, the name (defines event), or subcommands)
-- 2. subscribe to event/write callback
--
-- autocommands:
-- 1. enable the autocommand in load (and require "core.autocommands" in setup)
-- 2. subscribe to a "core.autocommands" event (there are a bunch listed in the module)
-- 3. write a callback using vim.schedule (to avoid textlock, see ":h vim.schedule")
--
-- modes: turn off/on modules dynamically (not required for modules to support)
-- 1. add the mode in load (and require the "core.neorgcmd" in setup)
-- 2. subscribe to a "core.mode" event (either mode_set or mode_created)
-- 3. write a callback
--

module.events.defined = {
  our_event = neorg.events.define(module, "our_event")
}
module.events.subscribed = {
  ['utilities.dateinserter'] = { our_event = true },
  ["core.autocommands"] = { insertenter = true },
  ["core.neorgcmd"] = { ["our.test_command"] = true},
  ["core.keybinds"] = { ["utilities.dateinserter.my_keybind"] = true}
}
module.on_event = function(event)

  if event.type == "core.autocommands.events.insertenter" and 
       module.config.public.enable_auto_insertenter then
    vim.schedule(function() module.public.insert_datetime() end)
  elseif event.type == "utilities.dateinserter.events.our_event" then
    log.warn("Rx event:", event)
  elseif event.split_type[1] == "core.neorgcmd" then
    log.warn("received test command with argument " .. event.content[1])
  elseif event.split_type[2] == "utilities.dateinserter.my_keybind" then
    log.warn(event)
  end
end

return module
