AddCSLuaFile()

ENT.Base = "base_filter"
ENT.Type = "filter"

ENT.Author = "Lazyneer"
ENT.PrintName = "Overwatch Team Filter"
ENT.Category		= "Overwatch"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:KeyValue(key, value)
    if key == "filterteam" then
        self.Team = tonumber(value)
    elseif key == "Negated" then
        if value == "1" then
            self.Negated = true
        else
            self.Negated = false
        end
    end
end

function ENT:PassesFilter(caller, ent)
    if ent:IsPlayer() then
        local result = ent:Team() == self.Team
        if self.Negated then
            result = !result
        end
        return result
    end
    return false
end