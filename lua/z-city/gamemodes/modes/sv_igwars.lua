local MODE = MODE

MODE.name = "igwars"
MODE.PrintName = "Improved Gang Wars"

MODE.LootSpawn = false
MODE.Chance = 0.02

util.AddNetworkString("igwars_start")
util.AddNetworkString("igwars_end")

function MODE:CanLaunch()
    return true
end

-- START
function MODE:Intermission()
    game.CleanUpMap()

    local poses = {}

    for _, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end

        ply:SetupTeam(ply:Team())
        table.insert(poses, ply:GetPos())
    end

    -- ZONE CENTER
    local center = Vector(0,0,0)
    for _, pos in ipairs(poses) do
        center:Add(pos)
    end

    if #poses > 0 then
        center:Div(#poses)
    end

    local dist = 0
    for _, pos in ipairs(poses) do
        dist = math.max(dist, pos:Distance(center))
    end

    zonepoint = center
    zonedistance = dist

    net.Start("igwars_start")
        net.WriteVector(zonepoint)
        net.WriteFloat(zonedistance)
    net.Broadcast()
end

-- CHECK TEAMS
function MODE:CheckAlivePlayers()
    return zb:CheckAliveTeams(true)
end

-- END WHEN ONE TEAM LEFT
function MODE:ShouldRoundEnd()
    local alive = self:CheckAlivePlayers()

    local count = 0
    for _, _ in pairs(alive) do
        count = count + 1
    end

    return count <= 1
end

-- LOADOUT
function MODE:GiveEquipment()
    timer.Simple(0.2, function()
        for _, ply in player.Iterator() do
            if not ply:Alive() then continue end

            ply:SetSuppressPickupNotices(true)
            ply.noSound = true

            if ply:Team() == 0 then
                zb.GiveRole(ply, "Bloodz", Color(190,0,0))
                ply:SetPlayerClass("bloodz")
            else
                zb.GiveRole(ply, "Groove", Color(0,190,0))
                ply:SetPlayerClass("groove")
            end

            local wep = ply:Give("weapon_glock17")
            if IsValid(wep) then
                ply:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)
            end

            ply:Give("weapon_bandage_sh")
            ply:Give("weapon_tourniquet")
            ply:Give("weapon_hands_sh")
            ply:SelectWeapon("weapon_hands_sh")

            timer.Simple(0.1, function()
                if IsValid(ply) then
                    ply.noSound = false
                    ply:SetSuppressPickupNotices(false)
                end
            end)
        end
    end)
end

-- ZONE LOGIC
hook.Add("Think", "igwars_zone", function()
    local rnd = CurrentRound()
    if not rnd or rnd.name ~= "igwars" then return end

    if not MODE.EnableZone:GetBool() then return end
    if not zonepoint then return end

    local radius = MODE.GetZoneRadius()
    local radiussqr = radius * radius

    for _, ent in ents.Iterator() do
        if ent:GetPos():DistToSqr(zonepoint) > radiussqr then

            if ent:IsPlayer() then
                hg.LightStunPlayer(ent)
                continue
            end

            if string.find(ent:GetClass(), "prop_") then
                ent:Remove()
            end
        end
    end
end)

function MODE:EndRound()
    timer.Simple(2, function()
        net.Start("igwars_end")
        net.Broadcast()
    end)
end