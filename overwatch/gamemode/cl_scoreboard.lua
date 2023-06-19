local PLAYER_LINE = {
	Init = function(self)
		self.AvatarButton = self:Add("DButton")
		self.AvatarButton:Dock(LEFT)
		self.AvatarButton:SetSize(32, 32)
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar = vgui.Create("AvatarImage", self.AvatarButton)
        self.Avatar:SetSize(32, 32)
		self.Avatar:SetMouseInputEnabled(false)

		self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("Overwatch.Scoreboard")
		self.Name:SetTextColor(Color(255, 255, 255))
		self.Name:DockMargin(8, 0, 0, 0)

		self.Mute = self:Add("DImageButton")
		self.Mute:SetSize(32, 32)
        self.Mute:Dock(RIGHT)
        self.Mute:SetZPos(1)

		self.Ping = self:Add("DLabel")
		self.Ping:Dock(RIGHT)
		self.Ping:SetWidth(40)
		self.Ping:SetFont("Overwatch.Scoreboard")
        self.Ping:SetTextColor(Color(255, 255, 255))
        self.Ping:SetContentAlignment(6)
        self.Ping:SetZPos(0)

		self:Dock(TOP)
		self:DockPadding(3, 3, 11, 3)
		self:SetHeight(32 + 3 * 2)
		self:DockMargin(1, 0, 1, 0)
	end,
	Setup = function(self, pl)
		self.Player = pl
		self.Avatar:SetPlayer(pl)
		self:Think(self)
		--local friend = self.Player:GetFriendStatus()
		--MsgN(pl, " Friend: ", friend)
	end,
	Think = function(self)
		if !IsValid(self.Player) then
			self:SetZPos(9999) -- Causes a rebuild
			self:Remove()
			return
        end
        
        if self.Player:Team() == TEAM_SPECTATOR then
            self:SetZPos(9999) -- Causes a rebuild
			self:Remove()
			return
        end

		if (self.PName == nil || self.PName != self.Player:Nick()) then
			self.PName = self.Player:Nick()
			self.Name:SetText(self.PName)
		end
		if (self.NumPing == nil || self.NumPing != self.Player:Ping()) then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText(self.NumPing)
		end
		--
		-- Change the icon of the mute button based on state
		--
        if (self.Muted == nil || self.Muted != self.Player:IsMuted()) then

            self.Muted = self.Player:IsMuted()
			if (self.Muted) then
				self.Mute:SetImage("icon32/muted.png")
			else
				self.Mute:SetImage("icon32/unmuted.png")
			end

			self.Mute.DoClick = function(s) self.Player:SetMuted(!self.Muted) end
			self.Mute.OnMouseWheeled = function(s, delta)
				self.Player:SetVoiceVolumeScale(self.Player:GetVoiceVolumeScale() + (delta / 100 * 5))
				s.LastTick = CurTime()
			end

            self.Mute.PaintOver = function(s, w, h)
                if IsValid(self.Player) && self.Player:IsPlayer() then
                    local a = 255 - math.Clamp(CurTime() - (s.LastTick or 0), 0, 3) * 255
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, a * 0.75))
                    draw.SimpleText(math.ceil(self.Player:GetVoiceVolumeScale() * 100) .. "%", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
		end
		--
		-- This is what sorts the list. The panels are docked in the z order,
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
        --self:SetZPos((self.NumKills * -50) + self.NumDeaths + self.Player:EntIndex())

        local order = 1
        if self.Player:Team() == TEAM_OVERWATCH then
            order = -1
        elseif self.Player:Team() == TEAM_REBELS then
            order = self.Player:EntIndex()
        end
        self:SetZPos(order)
	end,
	Paint = function(self, w, h)
		if (!IsValid(self.Player)) then
			return
		end
		--
		-- We draw our background a different colour based on the status of the player
		--
        if !self.Player:Alive() then
            surface.SetDrawColor(255, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
        end
	end
}
PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

local TEAM_OVERWATCH_LINE = {
    Init = function(self)
        --[[self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("Overwatch.Scoreboard")
		self.Name:SetTextColor(Color(0, 0, 0))
        self.Name:DockMargin(8, 0, 0, 0)
        self.Name:SetText("Overwatch")]]

        --[[self.Players = self:Add("DLabel")
		self.Players:Dock(RIGHT)
		self.Players:SetWidth(26)
		self.Players:SetFont("Overwatch.Scoreboard")
		self.Players:SetTextColor(Color(0, 0, 0))
		self.Players:SetContentAlignment(5)]]

        self:Dock(TOP)
		self:DockPadding(3, 3, 3, 3)
		self:SetHeight(32 + 3 * 2)
    end,
    Think = function(self)
        self.playersInTeam = 0
        for _, ply in pairs(player.GetAll()) do
            if ply:Team() == TEAM_OVERWATCH then
                self.playersInTeam = self.playersInTeam + 1
            end
        end
        self:DockMargin(1, 0, 1, 0)
        if self.playersInTeam == 0 then
            self:DockMargin(1, 0, 1, 38)
        end
        --self.Players:SetText(self.playersInTeam)
        self:SetZPos(-2)
    end,
    Paint = function(self, w, h)
        surface.SetDrawColor(team.GetColor(TEAM_OVERWATCH))
        surface.DrawRect(0, 0, w, h)
        draw.SimpleTextOutlined("Overwatch", "Overwatch.Scoreboard", 11, 8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(self.playersInTeam, "Overwatch.Scoreboard", w - 11, 8, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    end
}
TEAM_OVERWATCH_LINE = vgui.RegisterTable(TEAM_OVERWATCH_LINE, "DPanel")

local TEAM_REBELS_LINE = {
    Init = function(self)
        --[[self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("Overwatch.Scoreboard")
		self.Name:SetTextColor(Color(0, 0, 0))
        self.Name:DockMargin(8, 0, 0, 0)
        self.Name:SetText("Resistance")]]

        --[[self.Players = self:Add("DLabel")
		self.Players:Dock(RIGHT)
		self.Players:SetWidth(26)
		self.Players:SetFont("Overwatch.Scoreboard")
		self.Players:SetTextColor(Color(0, 0, 0))
		self.Players:SetContentAlignment(5)]]

        self:Dock(TOP)
		self:DockPadding(3, 3, 3, 3)
		self:SetHeight(32 + 3 * 2)
		self:DockMargin(1, 0, 1, 0)
    end,
    Think = function(self)
        self.playersInTeam = 0
        for _, ply in pairs(player.GetAll()) do
            if ply:Team() == TEAM_REBELS then
                self.playersInTeam = self.playersInTeam + 1
            end
        end
        --self.Players:SetText(self.playersInTeam)
        self:SetZPos(0)
    end,
    Paint = function(self, w, h)
        surface.SetDrawColor(team.GetColor(TEAM_REBELS))
        surface.DrawRect(0, 0, w, h)
        draw.SimpleTextOutlined("Resistance", "Overwatch.Scoreboard", 11, 8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(self.playersInTeam, "Overwatch.Scoreboard", w - 11, 8, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    end
}
TEAM_REBELS_LINE = vgui.RegisterTable(TEAM_REBELS_LINE, "DPanel")

local SCORE_BOARD = {
    Init = function(self)
        self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(100)

		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("Overwatch.ScoreboardTitle")
		self.Name:SetTextColor(Color(255, 255, 255, 255))
		self.Name:Dock(TOP)
		self.Name:SetHeight(99)
		self.Name:SetContentAlignment(5)

		self.Scores = self:Add("DScrollPanel")
        self.Scores:Dock(FILL)

        self.Spectators = self:Add("DLabel")
        self.Spectators:SetFont("Overwatch.ScoreboardFooter")
        self.Spectators:Dock(BOTTOM)
        self.Spectators:SetTextColor(Color(255, 255, 255))
        self.Spectators:DockMargin(8, 4, 8, 4)

        self.Combine = self:Add("DLabel")
        self.Combine:SetFont("Overwatch.ScoreboardFooter")
        self.Combine:Dock(BOTTOM)
        self.Combine:SetTextColor(Color(255, 255, 255))
        self.Combine:DockMargin(8, 4, 8, 4)
    end,
    PerformLayout = function(self)
		self:SetSize(700, ScrH() - 200)
        self:SetPos(ScrW() / 2 - 350, 100)
    end,
    Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(18, 18, 21)
        surface.DrawOutlinedRect(0, 0, w, 100)
        surface.DrawOutlinedRect(0, 0, w, h)

        surface.SetDrawColor(100, 255, 255, 100)
        surface.SetMaterial(Material("vgui/menu/ow_logo.vmt"))
        surface.DrawTexturedRect((w / 2) - 256, 214 + ((h - 214) / 2) - 256, 512, 512)

        local curMap = SanitizeMapName(game.GetMap())
        local nextMap = ""
        if GAMEMODE.NextMap != nil then
            nextMap = " - Next: " .. SanitizeMapName(GAMEMODE.NextMap)
        end
        local subtitle = curMap .. nextMap
        
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(8, 73) 
        surface.SetFont("Overwatch.Menu")
        surface.DrawText(subtitle)

        subtitle = ""
        local maxrounds = GAMEMODE.ConVars.maxrounds.client
        local timelimit = GAMEMODE.ConVars.timelimit.client

        if maxrounds > 0 then
            local played = GAMEMODE.ConVars.maxrounds.played
            subtitle = "Rounds Left: " .. math.Clamp(maxrounds - played, 0, 255)
        end
        
        if maxrounds > 0 && timelimit > 0 then
            subtitle = subtitle .. " - "
        end

        if timelimit > 0 then
            local start = GAMEMODE.ConVars.timelimit.start
            if start > 0 then
                local time = start + timelimit
                time = time - math.floor(CurTime())
                subtitle = subtitle .. "Time Left: " .. SecondsToTimer(time)
            else
                subtitle = subtitle .. "Time Left: " .. SecondsToTimer(timelimit)
            end
        end

        draw.DrawText(subtitle, "Overwatch.Menu", w - 9, 73, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	end,
	Think = function(self, w, h)
        self.Name:SetText(GetHostName())
        
        if !IsValid(LocalPlayer().Overwatch_Line) then
            LocalPlayer().Overwatch_Line = vgui.CreateFromTable(TEAM_OVERWATCH_LINE, LocalPlayer().Overwatch_Line)
            self.Scores:AddItem(LocalPlayer().Overwatch_Line)
        end
        if !IsValid(LocalPlayer().Rebel_Line) then
            LocalPlayer().Rebel_Line = vgui.CreateFromTable(TEAM_REBELS_LINE, LocalPlayer().Rebel_Line)
            self.Scores:AddItem(LocalPlayer().Rebel_Line)
        end

        local firstCombine = true
        local firstSpectator = true
        local combine = ""
        local spectators = ""
        local plyrs = player.GetAll()
        for id, pl in pairs(plyrs) do
            if pl:Team() == TEAM_OVERWATCH || pl:Team() == TEAM_REBELS then
                if (IsValid(pl.ScoreEntry)) then continue end
                pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE, pl.ScoreEntry)
                pl.ScoreEntry:Setup(pl)
                self.Scores:AddItem(pl.ScoreEntry)
            elseif pl:Team() == TEAM_COMBINE then
                if firstCombine then
                    combine = "Combine: " .. pl:GetName()
                    firstCombine = false
                else
                    combine = combine .. ", " .. pl:GetName()
                end
            else
                if firstSpectator then
                    spectators = "Spectators: " .. pl:GetName()
                    firstSpectator = false
                else
                    spectators = spectators .. ", " .. pl:GetName()
                end
            end
        end
        
        self.Combine:SetText(combine)
        self.Spectators:SetText(spectators)
	end
}
SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD, "EditablePanel")

function GM:ScoreboardShow()
	if (!IsValid(g_Scoreboard)) then
		g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
	end
	if (IsValid(g_Scoreboard)) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled(false)
	end
end

function GM:ScoreboardHide()
	if (IsValid(g_Scoreboard)) then
		g_Scoreboard:Hide()
	end
end