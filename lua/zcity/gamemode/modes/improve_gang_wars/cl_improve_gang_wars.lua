local MODE = MODE
MODE.name = "impgw"

local ZonePos = Vector(0,0,0)
local ZoneStartRadius = 10000
local roundend = false

net.Receive("impgw_start", function()
	roundend = false
	ZonePos = net.ReadVector()
	ZoneStartRadius = net.ReadFloat()

	surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")       --music froom dm
	sound.PlayFile("sound/music_themes/ghetto_loop.wav", "noblock noplay", function(station)
		if IsValid(station) then
			MODE.LoopStation = station
			station:EnableLooping(true)
			station:SetVolume(0.65)
		end
	end)

	hg.DynaMusic:Start("mirrors_edge")
end)

net.Receive("impgw_end", function()
	roundend = CurTime()
	if IsValid(MODE.LoopStation) then
		MODE.LoopStation:SetVolume(0.2)
	end
	CreateEndMenu(net.ReadInt(8))
end)

function MODE:GetCurrentZoneRadius()
	if not MODE.ZoneShrinking then 
		return ZoneStartRadius 
	end
	local progress = math.Clamp((CurTime() - (MODE.ZoneStartTime or CurTime())) / MODE.ZoneShrinkTime, 0, 1)
	return Lerp(progress, ZoneStartRadius, MODE.FinalZoneRadius or 800)
end

local mat = Material("hmcd_dmzone")

function MODE:PostDrawTranslucentRenderables(bDepth, bSkybox)
	if bSkybox then return end
	local radius = self:GetCurrentZoneRadius()
	render.SetMaterial(mat)
	render.DrawSphere(ZonePos, -radius, 48, 48, Color(255, 60, 60, 55))
end

function MODE:RenderScreenspaceEffects()
	if zb.ROUND_START + 8 > CurTime() then
		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
	end
end

function MODE:HUDPaint()
	local lply = LocalPlayer()

	if zb.ROUND_START + 15 > CurTime() then
		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
		draw.SimpleText("Improved Gang Wars", "ZB_HomicideMediumLarge", sw*0.5, sh*0.12, Color(0,162,255,255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		if lply:Team() == 0 then
			draw.SimpleText("You are a Bloodz Member", "ZB_HomicideMediumLarge", sw*0.5, sh*0.45, Color(190,0,0,255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("You are a Groove Member", "ZB_HomicideMediumLarge", sw*0.5, sh*0.45, Color(0,190,0,255*fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		return
	end

	if MODE.ZoneShrinking then
		local timeLeft = math.max(0, MODE.ZoneShrinkTime - (CurTime() - (MODE.ZoneStartTime or 0)))
		local txt = "Zone shrinking: " .. string.FormattedTime(timeLeft, "%02i:%02i")
		draw.SimpleText(txt, "ZB_InterfaceMediumLarge", sw*0.5, sh*0.07, Color(255, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Zone will start shrinking in 15 seconds...", "ZB_InterfaceMedium", sw*0.5, sh*0.07, Color(255,200,80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)   --this shit doesnt work rn
	end

	if not lply:Alive() then return end
end

-- End Menu
local hmcdEndMenu
local function CreateEndMenu(winnerTeam)
	if IsValid(hmcdEndMenu) then hmcdEndMenu:Remove() end

	hmcdEndMenu = vgui.Create("ZFrame")
	hmcdEndMenu:SetSize(ScrW()/2.4, ScrH()/1.3)
	hmcdEndMenu:Center()
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:ShowCloseButton(false)

	local winnerName = winnerTeam == 0 and "Bloodz" or "Groove"

	hmcdEndMenu.PaintOver = function(self, w, h)
		draw.SimpleText(winnerName .. " WON THE WAR!", "ZB_InterfaceMediumLarge", w/2, 25, Color(255,215,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(15, 80)
	DScrollPanel:SetSize(hmcdEndMenu:GetWide() - 30, hmcdEndMenu:GetTall() - 110)

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, 50)
		but:Dock(TOP)
		but:DockMargin(8, 6, 8, -1)
		but:SetText("")

		but.Paint = function(self, w, h)
			local alive = ply:Alive()
			local col1 = alive and Color(130,10,10) or Color(85,85,85)
			local col2 = alive and Color(160,30,30) or Color(75,75,75)

			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h/2, w, h/2)

			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(255,255,255)
			local name = ply:Name() or "Unknown"
			local tx, ty = surface.GetTextSize(name)
			surface.SetTextPos(15, h/2 - ty/2)
			surface.DrawText(name .. (not alive and " - Dead" or ""))

			local frags = ply:Frags() or 0
			local fx, fy = surface.GetTextSize(frags)
			surface.SetTextPos(w - fx - 15, h/2 - fy/2)
			surface.DrawText(frags)
		end

		but.DoClick = function()
			gui.OpenURL("https://steamcommunity.com/profiles/" .. ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	local close = vgui.Create("DButton", hmcdEndMenu)
	close:SetText("Close")
	close:AlignBottom(10)
	close:CenterHorizontal()
	close.DoClick = function() hmcdEndMenu:Remove() end
end

function MODE:RoundStart()
	if IsValid(hmcdEndMenu) then hmcdEndMenu:Remove() end
	MODE.ZoneShrinking = false
end

