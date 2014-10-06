local Command = _V.CommandLib.Command:new("Heal", _V.CommandLib.UserTypes.Admin, "Heal the player(s) or sets player(s) health to amount specified.", "")
Command:addArg(_V.CommandLib.ArgTypes.Players, {required = false})
Command:addArg(_V.CommandLib.ArgTypes.Number, {required = false})
Command:addAlias("!heal")

Command.Callback = function(Sender, Alias, Targets, Amount)
	local Targets = Targets or {Sender}
	
	for _, ply in ipairs(Targets) do
		ply:SetHealth(Amount or ply:GetMaxHealth())
	end
	
	if Amount or Amount == 100 then
		_V.CommandLib.SendCommandMessage(Sender, "healed", Targets, "")
	else
		_V.CommandLib.SendCommandMessage(Sender, "set the health of", Targets, "to _reset_ "..Amount)
	end
	
	return ""
end