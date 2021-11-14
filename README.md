Sandbox for testing neorg plugins

# Installation

Clone this somewhere.

```lua
use {
  'nvim-neorg/neorg', requires = 'path_to_this_repo'
}

local neorg_leader = "<Leader>o"
require('neorg').setup {
  load = {
    ...
    ["utilities.dateinserter"] = {}

    -- only needed if wanting to add custom keybinds
    ["core.keybinds"] = {
        config = {
            default_keybinds = true,
            neorg_leader = neorg_leader
        }
    },

  },
}

-- custom keybinding: https://github.com/nvim-neorg/neorg/wiki/User-Keybinds
local neorg_callbacks = require('neorg.callbacks')
neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
	keybinds.map_event_to_mode(
    "norg",
    {
      n = { -- Bind keys in normal mode
        { neorg_leader .. "d", "utilities.dateinserter.my_keybind" },
      },
    },
    {
      silent = true, noremap = true
    })
end)

```
