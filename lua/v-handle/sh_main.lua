--- Add resources --
VH_FileLib.AddResourceDir("materials/v-handle/")

-- Load def configs --
VH_FileLib.IncludeDir("vh-config")

-- Load configs --
function VH_LoadConfigs()
	local Files, Dirs = file.Find("v-handle/vh-config/*.lua", "LUA")
	file.CreateDir("v-handle/config")
	
	for a, b in ipairs(Files) do
		local Data = file.Read("v-handle/config/" .. b .. ".txt", "DATA")
		if Data and Data != "" then
			RunStringEx(Data, "VH-Configs")
		else
			Data = file.Read("v-handle/vh-config/" .. b, "LUA")
			if Data and Data != "" then
				file.Write("v-handle/config/" .. b .. ".txt", Data)
			end
		end
	end
end

VH_LoadConfigs()

-- Load libs --
VH_FileLib.IncludeDir("vh-libs")

-- Load modules --
VH_FileLib.IncludeDir("vh-modules")

hook.Run("VH-PostModule")