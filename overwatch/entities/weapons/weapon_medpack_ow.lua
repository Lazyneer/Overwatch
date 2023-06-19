
AddCSLuaFile()

SWEP.PrintName = "Medpack"
SWEP.Author = "Lazyneer"
SWEP.Purpose = "Heal others with your primary attack, or yourself with the secondary.\nPress Reload to drop."

SWEP.Slot = 5
SWEP.SlotPos = 0

SWEP.ViewModel = Model("models/weapons/c_medkit.mdl")
SWEP.WorldModel = Model("models/weapons/w_medkit.mdl")
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 20
SWEP.MaxAmmo = 100

local HealSound = Sound("HealthKit.Touch")
local DenySound = Sound("WallHealth.Deny")

function SWEP:Initialize()
	self:SetHoldType("slam")
	self:SetModelScale(2)
	if CLIENT then return end

	self:UseTriggerBounds(true, 24)
	self.TargetName = self:GetName()
	timer.Create("medkit_ammo" .. self:EntIndex(), 1, 0, function()
		if self:Clip1() < self.MaxAmmo then
			self:SetClip1(math.min(self:Clip1() + 2, self.MaxAmmo))
		end
	end)
end

function SWEP:Equip(newOwner)
	if newOwner:IsPlayer() then
		local model = newOwner:GetModel()
		model = string.Replace(model, "/group03/", "/group03m/")
		newOwner:SetModel(model)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then

		if self.Owner:IsPlayer() then
			self.Owner:LagCompensation(true)
		end

		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 128,
			filter = self.Owner
		})

		if self.Owner:IsPlayer() then
			self.Owner:LagCompensation(false)
		end

		local ent = tr.Entity
		if !IsValid(ent) then
			tr = util.TraceHull({
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 128,
				filter = self.Owner,
				mins = Vector(-16, -16, -16),
                maxs = Vector(16, 16, 16)
			})
			ent = tr.Entity
		end

		local need = self.HealAmount
		if IsValid(ent) then
			need = math.min(ent:GetMaxHealth() - ent:Health(), self.HealAmount)
		end

		if IsValid(ent) && ent:IsPlayer() && ent:Health() < ent:GetMaxHealth() then
			need = math.min(self:Clip1(), need)
			self:TakePrimaryAmmo(need)

			ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + need))
			ent:EmitSound(HealSound)

			if self.Owner.VoiceLineCooldown < CurTime() then
				self.Owner.VoiceLineCooldown = CurTime() + 10
				if self.Owner.Gender == GENDER_MALE then
					self.Owner:EmitSound(GAMEMODE.VoiceLines[VOICE_HEAL]["male"][math.random(#GAMEMODE.VoiceLines[VOICE_HEAL]["male"])])
				else
					self.Owner:EmitSound(GAMEMODE.VoiceLines[VOICE_HEAL]["female"][math.random(#GAMEMODE.VoiceLines[VOICE_HEAL]["female"])])
				end
			end

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

			self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + 0.5)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Create("weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function()
				if IsValid(self) then
					self:SendWeaponAnim(ACT_VM_IDLE)
				end
			end)
		else
			self.Owner:EmitSound(DenySound)
			self:SetNextPrimaryFire(CurTime() + 1)
		end
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		local ent = self.Owner
		local need = self.HealAmount
		if IsValid(ent) then
			need = math.min(ent:GetMaxHealth() - ent:Health(), self.HealAmount)
		end

		if IsValid(ent) && ent:Health() < ent:GetMaxHealth() then
			need = math.min(self:Clip1(), need)
			self:TakePrimaryAmmo(need)

			ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + need))
			ent:EmitSound(HealSound)

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

			self:SetNextSecondaryFire(CurTime() + self:SequenceDuration() + 0.5)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Create("weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function()
				if IsValid(self) then
					self:SendWeaponAnim(ACT_VM_IDLE)
				end
			end)
		else
			ent:EmitSound(DenySound)
			self:SetNextSecondaryFire(CurTime() + 1)
		end
	end
end

function SWEP:OnRemove()
	timer.Stop( "medkit_ammo" .. self:EntIndex() )
	timer.Stop( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Holster()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
	return true
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay
end