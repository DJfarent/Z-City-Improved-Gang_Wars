local MODE = MODE

MODE.name = "igwars"
MODE.PrintName = "Improved Gang Wars"

-- SETTINGS
MODE.ROUND_TIME = 999999
MODE.EnableZone = CreateConVar("igwars_enable_zone", 1, FCVAR_REPLICATED)

-- ZONE SETTINGS (bigger + slower)
MODE.ZoneTimeToShrink = 300 -- 5 mins
MODE.ZoneScale = 2.5

-- ZONE CALC
function MODE.GetZoneRadius()
    if not zonedistance then return 999999 end

    local dist = zonedistance * MODE.ZoneScale

    return dist * math.max(((zb.ROUND_START + MODE.ZoneTimeToShrink) - CurTime()) / MODE.ZoneTimeToShrink, 0.05)
end

-- OPTIONAL POINTS
zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.HMCD_IGWARS_T = zb.Points.HMCD_IGWARS_T or {}
zb.Points.HMCD_IGWARS_CT = zb.Points.HMCD_IGWARS_CT or {}