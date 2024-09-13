local util = {}

---Get the language phrase for the tool name, usually TOOL:GetMode()
---@param propName string
---@param toolName string
---@return string
function util.getToolPhrase(propName, toolName)
	return language.GetPhrase("tool." .. toolName .. "." .. propName)
end

---Get the convar for the tool name, usually TOOL:GetMode()
---@param convarName string
---@param toolName string
---@return string
function util.getToolConvar(convarName, toolName)
	return toolName .. "_" .. convarName
end

return util