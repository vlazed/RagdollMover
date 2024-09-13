---@module "ragdollmover.util"
local rgmUtil = include("ragdollmover/util.lua")
local getToolConvar = rgmUtil.getToolConvar

include("shared.lua")

TOOL_MODE = "ragdollmover"
local VECTOR_FRONT = RGM_Constants.VECTOR_FRONT
local COLOR_RGMGREEN = RGM_Constants.COLOR_GREEN
local COLOR_RGMBLACK = RGM_Constants.COLOR_BLACK
local OUTLINE_WIDTH = RGM_Constants.OUTLINE_WIDTH
local ANGLE_ARROW_OFFSET = Angle(0, 90, 90)
local ANGLE_DISC = Angle(0, 90, 0)

-- This is unused, so do we really need to get convar?
local Fulldisc = GetConVar(getToolConvar("fulldisc", TOOL_MODE))

local pl

function ENT:DrawLines(scale, width)
	if not pl then pl = LocalPlayer() end

	local rotate = RAGDOLLMOVER[pl].Rotate or false
	local modescale = RAGDOLLMOVER[pl].Scale or false
	local start, last = 1, 7
	if rotate then start, last = 8, 11 end
	if modescale then start, last = 12, 17 end
	-- print(self.Axises)

	local gotselected = false
	for i = start, last do
		local moveaxis = self.Axises[i]
		local yellow = false
		if moveaxis:TestCollision(pl, scale) and not gotselected then
			yellow = true
			gotselected = true
		end
		moveaxis:DrawLines(yellow, scale, width)
	end

	self.width = width
end

function ENT:DrawDirectionLine(norm, scale, ghost)
	local pos1 = self:GetPos():ToScreen()
	local pos2 = (self:GetPos() + (norm * scale)):ToScreen()
	local grn = 255
	if ghost then grn = 150 end
	surface.SetDrawColor(0, grn, 0, 255)
	surface.DrawLine(pos1.x, pos1.y, pos2.x, pos2.y)
end

local mabs, mround = math.abs, math.Round

function ENT:DrawAngleText(axis, hitpos, startAngle)
	local pos = WorldToLocal(hitpos, angle_zero, axis:GetPos(), axis:GetAngles())
	local overnine
	pos = WorldToLocal(pos, pos:Angle(), vector_origin, startAngle:Angle())

	local localized = Vector(pos.x, pos.z, 0):Angle()

	if(localized.y > 181) then
		overnine = 360
	else
		overnine = 0
	end

	local textAngle = mabs(mround((overnine - localized.y) * 100) / 100)
	local textpos = hitpos:ToScreen()
	draw.SimpleTextOutlined(textAngle, "RagdollMoverAngleFont", textpos.x + 5, textpos.y, COLOR_RGMGREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, OUTLINE_WIDTH, COLOR_RGMBLACK)
end

function ENT:Draw()
end
function ENT:DrawTranslucent()
end

local lastang = nil

function ENT:Think()
	if not pl or not RAGDOLLMOVER[pl] then return end
	if self ~= RAGDOLLMOVER[pl].Axis then return end

	local ent = RAGDOLLMOVER[pl].Entity
	if not IsValid(ent) or not RAGDOLLMOVER[pl].Bone or not self.Axises then return end

	if not RAGDOLLMOVER[pl].Moving then -- Prevent whole thing from rotating when we do localized rotation
		if RAGDOLLMOVER[pl].Rotate then
			if not RAGDOLLMOVER[pl].IsPhysBone then
				local manipang = ent:GetManipulateBoneAngles(RAGDOLLMOVER[pl].Bone)
				if manipang ~= lastang then
					self.DiscP.LocalAng = Angle(0, 90 + manipang.y, 0) -- Pitch follows Yaw angles
					self.DiscR.LocalAng = Angle(0 + manipang.x, 0 + manipang.y, 0) -- Roll follows Pitch and Yaw angles
					lastang = manipang
				end
			else
				self.DiscP.LocalAng = ANGLE_DISC
				self.DiscR.LocalAng = angle_zero
				lastang = nil
			end
		else
			self.DiscP.LocalAng = ANGLE_DISC
			self.DiscR.LocalAng = angle_zero
			lastang = nil
		end
	end

	local pos, poseye = self:GetPos(), pl:EyePos()

	local viewent = pl:GetViewEntity()
	if IsValid(viewent) and viewent ~= pl then
		poseye = viewent:GetPos()
	end

	local ang = (pos - poseye):Angle()
	ang = self:WorldToLocalAngles(ang)
	self.DiscLarge.LocalAng = ang
	self.ArrowOmni.LocalAng = ang

	pos, poseye = self:WorldToLocal(pos), self:WorldToLocal(poseye)
	local xangle, yangle = (Vector(pos.y, pos.z, 0) - Vector(poseye.y, poseye.z, 0)):Angle(), (Vector(pos.x, pos.z, 0) - Vector(poseye.x, poseye.z, 0)):Angle()
	local XAng, YAng, ZAng = Angle(0, 0, xangle.y + 90) + VECTOR_FRONT:Angle(), ANGLE_ARROW_OFFSET - Angle(0, 0, yangle.y), Angle(0, ang.y, 0) + vector_up:Angle()
	self.ArrowX.LocalAng = XAng
	self.ScaleX.LocalAng = XAng
	self.ArrowY.LocalAng = YAng
	self.ScaleY.LocalAng = YAng
	self.ArrowZ.LocalAng = ZAng
	self.ScaleZ.LocalAng = ZAng
end
