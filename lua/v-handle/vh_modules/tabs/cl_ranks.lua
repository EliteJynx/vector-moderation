local Module = {}
Module.Name = "RanksTab"
Module.Description = "Tab containing all Ranks"

function RenderCall(Frame, Table)
end

local RanksTab = _V.MenuLib.VTab:new("Ranks", RenderCall, 1)

vh.RegisterModule(Module)