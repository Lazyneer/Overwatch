AddCSLuaFile()

SWEP.PrintName = "Riot Shield"
SWEP.Author = "Lazyneer"
SWEP.Purpose = "Block yourself and others from incoming fire.\nPress Reload to drop."

SWEP.Slot = 5
SWEP.SlotPos = 0

SWEP.ViewModel = ""
SWEP.WorldModel = Model("models/weapons/riotshield.mdl")
SWEP.ViewModelFOV = 54
SWEP.UseHands = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	if CLIENT then return end
	self:UseTriggerBounds(true, 24)
	self.TargetName = self:GetName()
end

function SWEP:Deploy()
	self:SetNoDraw(true)
	if SERVER then
		if IsValid(self.ent) then return end
		self.ent = ents.Create("prop_dynamic")
		self.ent:SetModel("models/weapons/riotshield.mdl")
		self.ent:SetNoDraw(true)
		self.ent:SetRenderMode(RENDERMODE_NONE)
		self.ent:SetNotSolid(true)

		local child = ents.Create("prop_physics_multiplayer")
		child:SetModel("models/weapons/riotshield.mdl")
		child:SetPos(Vector(25, -9, 42))
		child:SetAngles(Angle(0, 0, 90))
		child:SetParent(self.ent)
		child:SetSolid(SOLID_VPHYSICS)
		child:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self.ent:SetPos(self.Owner:GetPos())
		self.ent:SetAngles(Angle(0, self.Owner:EyeAngles().y, 0))
		self.ent:SetParent(self.Owner)
		self.ent:Fire("SetParentAttachmentMaintainOffset", "forward", 0.01)
		self.ent:Fire("SetParentAttachment", "forward", 0.01)
		timer.Create("MoveShield", 0.02, 1, function()
			if IsValid(self.ent) then
				self.ent:SetLocalPos(Vector(0, 1.3, -56))
				self.ent:SetLocalAngles(Angle(0, -20, 4))
			end
		end)

	end
	return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()
	if SERVER then
		if !IsValid(self.ent) then return end
		self.ent:Remove()
	end
	return true
end

function SWEP:OnDrop()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		if !IsValid(self.ent) then return end
		self.ent:Remove()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		if !IsValid(self.ent) then return end
		self.ent:Remove()
	end
end