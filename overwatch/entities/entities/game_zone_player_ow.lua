AddCSLuaFile()

ENT.Type = "brush";
ENT.Base = "base_brush";

function ENT:Initialize()
    if CLIENT then return end
    
    self:SetTrigger(true)
    self.Players = {}
end

function ENT:KeyValue(key, value)
    if(key == "PlayersInCount") then
        self:StoreOutput(key, value)
    elseif(key == "PlayersOutCount") then
        self:StoreOutput(key, value)
    elseif(string.Left(key, 2) == "On") then
        self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if StrEqual(inputName, "CountPlayersInZone") then
        local totalPlayers = 0
        local alivePlayers = 0
        for _, ply in ipairs(player.GetAll()) do
            if (ply:Alive() && ply:Team() == TEAM_REBELS) then
                totalPlayers = totalPlayers + 1
            end
        end

        for _, ply in ipairs(self.Players) do
            if (ply:Alive() && ply:Team() == TEAM_REBELS) then
                alivePlayers = alivePlayers + 1
            end
        end

        if totalPlayers > 0 then
            self:TriggerOutput("OnPlayersOutZone", self)
        end

        if alivePlayers > 0 then
            self:TriggerOutput("OnPlayersInZone", self)
        end

        self:TriggerOutput("PlayersInCount", self, alivePlayers)
        self:TriggerOutput("PlayersOutCount", self, totalPlayers - alivePlayers)
    end
end

function ENT:StartTouch(entity)
    if entity:IsPlayer() && entity:IsValid() then
        if entity:Team() == TEAM_REBELS then
            table.insert(self.Players, entity)
        end
    end
end

function ENT:EndTouch(entity)
    if entity:IsPlayer() && entity:IsValid() then
        if entity:Team() == TEAM_REBELS then
            table.RemoveByValue(self.Players, entity)
        end
    end
end