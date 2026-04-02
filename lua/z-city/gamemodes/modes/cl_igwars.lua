local MODE = MODE
MODE.name = "igwars"

local ZonePos
local ZoneDist

net.Receive("igwars_start", function()
    ZonePos = net.ReadVector()
    ZoneDist = net.ReadFloat()

    zb.RemoveFade()
    surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
end)

-- DRAW ZONE
local mat = Material("hmcd_dmzone")

function MODE:PostDrawTranslucentRenderables()
    if not MODE.EnableZone:GetBool() then return end
    if not ZonePos then return end

    local radius = MODE.GetZoneRadius()

    render.SetMaterial(mat)
    render.DrawSphere(ZonePos, -radius, 60, 60, color_white)
end

-- HUD
function MODE:HUDPaint()
    if not LocalPlayer():Alive() then return end

    draw.SimpleText("Improved Gang Wars",
        "ZB_HomicideMediumLarge",
        ScrW()/2, ScrH()*0.1,
        Color(0,162,255),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
    )
end

net.Receive("igwars_end", function()
    surface.PlaySound("ambient/alarms/warningbell1.wav")
end)