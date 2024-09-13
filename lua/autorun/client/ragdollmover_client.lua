---@module "ragdollmover.util"
local rgmUtil = include("ragdollmover/util.lua")

local getToolConvar = rgmUtil.getToolConvar
TOOL_MODE = "ragdollmover"

hook.Add("InitPostEntity", "rgmClientSetup", function()

	if ConVarExists(getToolConvar("rotatebutton", TOOL_MODE)) then
		local BindRot = GetConVar(getToolConvar("rotatebutton", TOOL_MODE)):GetInt()

		if util.NetworkStringToID("RAGDOLLMOVER_META") ~= 0 then
			net.Start("RAGDOLLMOVER_META")
			net.WriteUInt(0, 1)
			net.WriteInt(BindRot, 8)
			net.SendToServer()
		end
	end

	if ConVarExists(getToolConvar("scalebutton", TOOL_MODE)) then
		local BindScale = GetConVar(getToolConvar("scalebutton", TOOL_MODE)):GetInt()

		if util.NetworkStringToID("RAGDOLLMOVER_META") ~= 0 then
			net.Start("RAGDOLLMOVER_META")
			net.WriteUInt(1, 1)
			net.WriteInt(BindScale, 8)
			net.SendToServer()
		end
	end
end)
