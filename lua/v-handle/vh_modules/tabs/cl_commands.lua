local Module = {}
Module.Name = "CommandsTab"
Module.Description = "Tab containing all commands"

local CommandOpen = nil

function RenderCall(Frame, Table)
	local CurrentCommands = 0
	print(CommandOpen)
	if CommandOpen then
		Table[i].BackButton = vgui.Create("DButton", Table[i])
		Table[i].BackButton:SetPos(Table[i]:GetWide() - 90, 10)
		Table[i].BackButton:SetSize(80, 30)
		Table[i].BackButton:SetText("")
		Table[i].BackButton.Paint = function()
			_V.MenuLib.DrawTrapezoidFancy(0, 0, Table[i].BackButton:GetWide(), Table[i].BackButton:GetTall(), _V.MenuLib.GetSettings().Colors.SecondaryButton, 2, 2)
			draw.SimpleText("<", "VHUIFont", Table[i].BackButton:GetWide()/2, Table[i].BackButton:GetTall()/2 - 4, Color(50, 50, 50, 255), 1, 1)
		end
		Table[i].BackButton.DoClick = function()
			CommandOpen = nil
			RenderCall(Frame, Table)
		end
	else
		for _, a in pairs(vh.Modules) do
			if (!a["Commands"]) then continue end
			for i, v in pairs(a.Commands) do
				Table[i] = vgui.Create("DButton", Frame)
				Table[i]:SetPos(Frame:GetWide() * 0.2 - (3 * CurrentCommands), 10 + (35 * CurrentCommands))
				Table[i]:SetSize(Frame:GetWide() * 0.6, 30)
				Table[i]:SetText("")
				Table[i].Paint = function()
					_V.MenuLib.DrawTrapezoidFancy(0, 0, Table[i]:GetWide(), Table[i]:GetTall(), _V.MenuLib.GetSettings().Colors.MainButton, 2, 2)
					draw.SimpleText(i, "VHUIFontSmall", Table[i]:GetWide()/2, Table[i]:GetTall()/2 - 4, Color(50, 50, 50, 255), 1, 1)
				end
				Table[i].DoClick = function()
					CommandOpen = v
					RenderCall(Frame, Table)
				end
				CurrentCommands = CurrentCommands + 1
			end
		end
	end
end

local CommandsTab = _V.MenuLib.VTab:new("Commands", RenderCall, 1)

vh.RegisterModule(Module)