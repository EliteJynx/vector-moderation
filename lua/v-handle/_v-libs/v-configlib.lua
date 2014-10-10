_V = _V or {}

_V.ConfigLib = {}

_V.ConfigLib.ConfigLocation = "_V/Config"
-- The directory the file is located in

file.CreateDir(_V.ConfigLib.ConfigLocation) -- Make sure the directories exist

_V.ConfigLib.Containers = {}
-- A table containing a cache of the configs to save on file I/O

_V.ConfigLib.Categories = {
	TEST = 0 -- The category; Number relative to the position of it's object in
			 -- _V.ConfigLib.CategoryObjects
}

_V.ConfigLib.CategoryObjects = {
	[0] = {
		Name = "Test", -- Name of the category used for display
		Desc = "For the test categories!" -- Description of the category for display
	}
}

_V.ConfigLib.ConfigValues = {}
-- A list of ConfigValue objects for use in writing to file

_V.ConfigLib.ConfigValue = {
	Key = nil, -- Key of the value
	Container = nil, -- Container file of the value
	Default = nil, -- Default value
	Desc = nil, -- Description of the value
	Category = nil -- Category the value is under
}

_V.ConfigLib.ValuesParser = {
	number = function(Value) if type(Value) == "string" then return tonumber(Value) else return tostring(Value) end end,
	-- Used to convert from string to number
	boolean = function(Value) if type(Value) == "string" then return string.lower(Value) == "true" else return tostring(Value) end end,
	-- Used to convert from string to boolean
	table = function(Value) if type(Value) == "string" then return ParseTable(Value) else return table.ToString(Value) end end
}

function ParseTable(Value)
	local Exploded = string.Explode(",", string.sub(Value, 2, #Value - 2))
	for _, v in pairs(Exploded) do
		Exploded[_] = string.sub(v, 2, #v - 1)
	end
	return Exploded
end

function _V.ConfigLib.ConfigValue:Get() -- Returns the current value of the ConfigValues key
	return _V.ConfigLib.Get(self.Key, self.Container, self.Default, self)
end

function _V.ConfigLib.ConfigValue:ToString(Value) -- Returns the ConfigValue as a nicely formatted string
	local Text = self.Key .. " = "
	local ValueAsString = _V.ConfigLib.ParseValue(Value, type(Value))
	Text = Text .. type(Value) .. " = " .. ValueAsString
	if self.Desc then
		Text = Text .. " --" .. self.Desc
	end
	return Text
end

function _V.ConfigLib.ConfigValue:FromString(String) -- Returns the key and value of a ConfigValues string
	local SplitA = string.Explode(" --", String)
	if SplitA and SplitA[1] then
		local SplitB = string.Explode(" = ", SplitA[1])
		if SplitB and SplitB[1] and SplitB[2] and SplitB[3] then
			-- Gets the key [1], value type [2] and value [3]
			local Value = _V.ConfigLib.ParseValue(SplitB[3], SplitB[2])
			return {Key = SplitB[1], Value = Value}
		end
	end
end

function _V.ConfigLib.ConfigValue:new(Key, Container, Default, Desc, Category)
	-- Makes a new config value and initializes it. USE THIS FOR NEW CONFIGVALUES
	-- Desc and category are option
	-- Category should be the number relative to the CategoryObjects position within the table
	local Object = table.Copy(self)
	Object.Key = Key or Object.Key
	Object.Container = Container or Object.Container
	Object.Default = Default or Object.Default
	Object.Desc = Desc or Object.Desc
	Object.Category = Category or Object.Category
	_V.ConfigLib.ConfigValues[Key] = Object
	return Object
end

function _V.ConfigLib.ParseValue(Value, Type)
	-- Corrects a value to the type specified
	local FixedValue = Value
	if _V.ConfigLib.ValuesParser[Type] then
		FixedValue = _V.ConfigLib.ValuesParser[Type](Value)
	end
	return FixedValue
end

function _V.ConfigLib.ReadConfig(Location)
	-- Reads the config from file and formats it correctly
	local Data = file.Read(_V.ConfigLib.ConfigLocation .. "/" .. Location .. ".txt", "DATA")
	if Data and Data != "" then
		local ConfigValues = {}
		Data = string.Explode("\n",Data)
		for a, b in pairs(Data) do
			if b == "" then continue end
			local ConfigValue = _V.ConfigLib.ConfigValue:FromString(b)
			if ConfigValue then
				ConfigValues[ConfigValue.Key] = ConfigValue.Value
			end
		end
		return ConfigValues
	end
end

function _V.ConfigLib.WriteConfig(Location, Data)
	-- Writes the config to file and formats it correctly
	local Formatted = ""
	
	local Sorted = {}
	
	for a, b in pairs(Data) do
		local ConfigVal = _V.ConfigLib.ConfigValues[a]
		if ConfigVal and ConfigVal.Category then
			Sorted[ConfigVal.Category] = Sorted[ConfigVal.Category] or {}
			Sorted[ConfigVal.Category][a] = b
		else
			Sorted["None"] = Sorted["None"] or {}
			Sorted["None"][a] = b
		end
	end
	
	for a, b in pairs(Sorted) do
		local Category = _V.ConfigLib.CategoryObjects[a]
		if Category then
			Formatted = Formatted .. "\n-- " .. Category.Name .. " - " .. Category.Desc .. " --\n\n"
			for c, d in pairs(b) do
				local ConfigVal = _V.ConfigLib.ConfigValues[c]
				if ConfigVal then
					Formatted = Formatted .. ConfigVal:ToString(d) .. "\n"
				else
					Formatted = Formatted .. c .. " = " .. type(d) .. " = " .. _V.ConfigLib.ParseValue(d, type(d)) .. " --No valid ConfigValue found\n"
				end
			end
		else
			Formatted = Formatted .. "\n-- No Category --\n\n"
			for c, d in pairs (b) do
				local ConfigVal = _V.ConfigLib.ConfigValues[c]
				if ConfigVal then
					Formatted = Formatted .. ConfigVal:ToString(d) .. "\n"
				else
					Formatted = Formatted .. c .. " = " .. type(d) .. " = " .. _V.ConfigLib.ParseValue(d, type(d)) .. " --No valid ConfigValue found\n"
				end
			end
		end
	end
	
	file.Write(_V.ConfigLib.ConfigLocation .. "/" .. Location .. ".txt", Formatted)
end

function _V.ConfigLib.ReloadConfig()
	-- Will effectively reload the config from file, requires the script to have already been loaded
	_V.ConfigLib.Containers = {}
	for a, b in pairs(_V.ConfigLib.ConfigValues) do
		b:Get()
	end
end

function _V.ConfigLib.Get(Key, ConKey, Default, ConfigValue)
	-- Returns the value of the key (KEY) within the specificied config (CONKEY)
	-- If value or config file is not found it returns default and saves file
	if Key == nil or ConKey == nil or Default == nil then return end
	-- Nil check
	
	local Container = _V.ConfigLib.Containers[ConKey]
	if Container != nil then -- Check if the config is cached
		if Container[Key] then
			if type(Container[Key]) != type(Default) then
				-- Make sure the data is valid
				Container[Key] = Default
				_V.ConfigLib.WriteConfig(ConKey, Container)
				-- Save the default value
			end
			return Container[Key]
		else
			Container[Key] = Default
			_V.ConfigLib.WriteConfig(ConKey, Container)
			-- Save the default value
			return Default
		end
	else
		local Data = _V.ConfigLib.ReadConfig(ConKey)
		if Data and Data != "" then
			_V.ConfigLib.Containers[ConKey] = Data
			return _V.ConfigLib.Get(Key, ConKey, Default)
			-- Runs the function again to save on repetitive code
		else
			Container = {} -- Creates the config file with default value
			Container[Key] = Default
			_V.ConfigLib.Containers[ConKey] = Container
			_V.ConfigLib.WriteConfig(ConKey, Container) -- Saves the file
			return Default
		end
	end
end

hook.Run( "_V-PostConfig" )

hook.Add( "_V-PostModule", "_V-ConfigInitialisation", function( )
	for a, b in pairs(_V.ConfigLib.ConfigValues) do
		b:Get()
	end
end )