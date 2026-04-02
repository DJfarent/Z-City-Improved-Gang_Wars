local MODE = MODE

MODE.name = "igwars"

local mat = Material("hmcd_dmzone")

net.Receive("igwars_start", function()
    zonepoint = net.ReadVector()
    zonedistance = net.ReadFloat()

    surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
end)

function MODE:PostDrawTranslucentRenderables()
    local rnd = CurrentRound()
    if not rnd then return end
    if not rnd.EnableZone:GetBool() then return end
    if not zonepoint then return end
    if not rnd.GetZoneRadius then return end

    local radius = rnd:GetZoneRadius()

    render.SetMaterial(mat)
    render.DrawSphere(zonepoint, radius, 60, 60, color_white)
end

function MODE:HUDPaint()
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