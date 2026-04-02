local MODE = MODE

MODE.name = "igwars"
MODE.PrintName = "Improved Gang Wars"

MODE.ROUND_TIME = 999999

-- SETTINGS
MODE.EnableZone = CreateConVar("igwars_enable_zone", 1, FCVAR_REPLICATED)
MODE.ZoneTimeToShrink = 300
MODE.ZoneScale = 2.5

-- SHARED DATA
zonepoint = zonepoint or nil
zonedistance = zonedistance or nil

-- IMPORTANT (FIXED)
function MODE:GetZoneRadius()
    if not zonedistance then return 999999 end

    local dist = zonedistance * self.ZoneScale

    return dist * math.max(((zb.ROUND_START + self.ZoneTimeToShrink) - CurTime()) / self.ZoneTimeToShrink, 0.05)
end

-- OPTIONAL
zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.HMCD_IGWARS_T = zb.Points.HMCD_IGWARS_T or {}
zb.Points.HMCD_IGWARS_CT = zb.Points.HMCD_IGWARS_CT or {}