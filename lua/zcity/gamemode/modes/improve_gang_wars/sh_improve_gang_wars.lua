local MODE = MODE

MODE.name = "impgw"
MODE.PrintName = "Improved Gang Wars"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 9999
MODE.LootSpawn = false
MODE.GuiltDisabled = true

MODE.ZoneShrinkTime = 240
MODE.FinalZoneRadius = 800

zb.Points = zb.Points or {}
zb.Points.HMCD_TDM_CT = zb.Points.HMCD_TDM_CT or { Color = Color(0,0,150), Name = "HMCD_TDM_CT" }
zb.Points.HMCD_TDM_T  = zb.Points.HMCD_TDM_T  or { Color = Color(150,95,0), Name = "HMCD_TDM_T" }

function MODE:CanLaunch()
	return true
end

function MODE:CheckAlivePlayers()
	local teams = zb:CheckAliveTeams(true)
	return {
		[0] = teams[0] or {},
		[1] = teams[1] or {}
	}
end

function MODE:ShouldRoundEnd()
	local alive = self:CheckAlivePlayers()
	if #alive[0] == 0 or #alive[1] == 0 then
		return true
	end
	return false
end

--reused code from gwars 