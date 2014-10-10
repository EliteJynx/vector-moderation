local Blacklist = _V.ConfigLib.ConfigValue:new("ChatBlacklist", "SpamFilter", {"PutBlacklistWordsHere", "LikeTheseWords"}, "Add words you want blacklisted into the table, requires a comma at end.")
local MaxWordLength = _V.ConfigLib.ConfigValue:new("MaxWordLength", "SpamFilter", 15, "Maximum length of words.")
local CapsPercentage = _V.ConfigLib.ConfigValue:new("CapsPercentage", "SpamFilter", 70, "Maximum percentage of capitals per word.")
local CensorPercentage = _V.ConfigLib.ConfigValue:new("CensorPercentage", "SpamFilter", 70, "Maximum percentage of censoring per word.")
local LetterDragging = _V.ConfigLib.ConfigValue:new("LetterDragging", "SpamFilter", 3, "Maximum letters in a row.")
local AdvancedFiltering = _V.ConfigLib.ConfigValue:new("AdvancedFiltering", "SpamFilter", true, "Checks for common letter changes to bypass filters, e.g using @ instead of a.")
local ExtremeFiltering = _V.ConfigLib.ConfigValue:new("ExtremeFiltering", "SpamFilter", true, "Checks for similarities in words that bypass filters, allows 1 difference per 4 letters compared to blacklisted words.")

local CapitalLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

local AdvancedFilters = {{"a", "@", "2"}, {"3", "#"}, {"s", "$", "4"}, {"5", "%"}, {"6", "^"}, {"7", "&"}, {"8", "*"}, {"9", "("}, {"0", ")"}, {"i", "1", "!", "|"}, {"o", "0"}, {"ate", "8"}, {"e", "3"}, {"l", "|"}}

local function WordDifferences(WordA, WordB)
	local Differences = 0
	local ShortestWord = (#WordA < #WordB) and WordA or WordB
	local LongestWord = (#WordA < #WordB) and WordB or WordA
	if #ShortestWord ~= #LongestWord then
		Differences = Differences + #LongestWord - #ShortestWord
	end
	local LongTable = string.ToTable(LongestWord)
	for i, v in pairs(string.ToTable(ShortestWord)) do
		if v ~= LongTable[i] then
			Differences = Differences + 1
		end
	end
	return Differences
end

local function WordSimilar(WordA, WordB)
	local WordA = string.lower(WordA)
	local WordB = string.lower(WordB)
	if WordA == WordB then
		return true
	end
	if AdvancedFiltering:Get() then
		if string.len(WordA) == string.len(WordB) then
			local NewWordA = WordA
			local NewWordB = WordB
			for _, v in ipairs(AdvancedFilters) do
				for i, x in ipairs(v) do
					if i == 1 then continue end
					NewWordA = string.Replace(NewWordA, v[i], v[1])
					NewWordB = string.Replace(NewWordB, v[i], v[1])
				end
			end
			if NewWordA == NewWordB then
				return true
			end
		end
	end
	if ExtremeFiltering:Get() then
		local Differences = WordDifferences(WordA, WordB)
		if Differences <= #WordA/4 then
			return true
		end
	end
	return false
end

function PlayerTalk(Player, Message, TeamChat)
	if string.StartWith(Message, "!") then return end
	local Return = Message
	local BlacklistTable = Blacklist:Get()
	local Explode = string.Explode(" ", Return)
	local TotalCensored = 0
	for i, word in pairs(Explode) do
		if string.len(word) > MaxWordLength:Get() then
			Return = string.Replace(Return, word, string.sub(word, 1, MaxWordLength:Get() - 2).."..")
		else
			local Caps = 0
			local Repeats = 0
			local LastLetter = ""
			local NewWord = ""
			for _, v in pairs(string.ToTable(word)) do
				if table.HasValue(CapitalLetters, v) then
					Caps = Caps + 1
				end
				if v == LastLetter then
					Repeats = Repeats + 1
					if Repeats < LetterDragging:Get() then
						NewWord = NewWord..v
					end
				else
					LastLetter = v
					Repeats = 0
					NewWord = NewWord..v
				end
			end
			Return = string.Replace(Return, word, NewWord)
			
			local Percent = math.Round((Caps / string.len(word)) * 100)
			if Percent >= CapsPercentage:Get() and string.len(word) > 2 then
				Return = string.Replace(Return, word, string.lower(word))
			end
			for _, v in pairs(BlacklistTable) do
				if WordSimilar(word, v) then
					Return = string.Replace(Return, word, "****")
					TotalCensored = TotalCensored + string.len(word)
				end
			end
		end
	end
	local Percent = math.Round((TotalCensored / string.len(Message)) * 100);
	if Percent >= CensorPercentage:Get() then
		return ""
	end
	return Return
end

hook.Add("PlayerSay", "PlayerTalk", PlayerTalk)