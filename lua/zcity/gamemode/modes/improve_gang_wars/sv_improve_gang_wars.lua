local MODE = MODE  

MODE.name = "impgw"

MODE.ZoneCenter = Vector(0,0,0)
MODE.ZoneStartRadius = 10000
MODE.ZoneShrinking = false     --ayo penis fix your mode hooks bro
MODE.ZoneStartTime = 0

util.AddNetworkString("impgw_start")
util.AddNetworkString("impgw_end")

local loadouts = {
	{primary = "weapon_glock17", attachments = {{"supressor4"},{"holo16","laser3"},{"holo15","laser1"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_cz75", attachments = {{"supressor4"},{"supressor4"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_deagle", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ar15", attachments = {{"holo1","grip1","supressor2"},{"holo5","grip3","supressor2"},{"laser4","grip2"},{"laser4","supressor2"}}, armor = {"vest4","helmet1"}, ammo = 3},
	{primary = "weapon_mp7", attachments = {{"holo1","supressor2"},{"holo5","supressor2"},{"laser4","supressor2"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_p90", attachments = {{"holo15","supressor4"},{"laser1","supressor4"},{"holo14","supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_doublebarrel_short", attachments = "", armor = {"vest3","helmet1","mask1"}, ammo = 6},
	{primary = "weapon_akm", attachments = {{"holo6","supressor1"},{"holo4","laser1"},{"supressor1"}}, armor = {"vest1","helmet1","nightvision1"}, ammo = 3},
	{primary = "weapon_remington870", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_mac11", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_mp5", attachments = {{"supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_m590a1", attachments = "", armor = {"vest4","helmet1","mask1"}, ammo = 3},
	{primary = "weapon_uzi", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_vector", attachments = {{"supressor4","holo3"},{"holo4"},{"holo7"}}, armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_revolver2", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ak74", attachments = {{"holo6"},{"holo4"},{"optic8"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_sks", attachments = {{"optic8"},{"holo6"}}, armor = {"vest3","helmet1"}, ammo = 4},
}

local randomGrenades = {"weapon_hg_rgd_tpik", "weapon_hg_pipebomb_tpik", "weapon_hg_smokenade_tpik", "weapon_hg_flashbang_tpik"}
local randomMedicine = {"weapon_bandage_sh", "weapon_bigbandage_sh", "weapon_medkit_sh", "weapon_fentanyl", "weapon_morphine", "weapon_adrenaline", "weapon_tourniquet"}
local randomMelees = {"weapon_melee", "weapon_pocketknife"}

function MODE:Intermission()
	game.CleanUpMap()

	local poses = {}
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			ApplyAppearance(ply)
			ply:SetupTeam(ply:Team())
			table.insert(poses, ply:GetPos())
		end
	end

	local center = Vector(0,0,0)
	for _, pos in ipairs(poses) do center:Add(pos) end
	center:Div(math.max(#poses, 1))
	center.z = center.z + 64

	MODE.ZoneCenter = center
	MODE.ZoneStartRadius = math.max(8000, center:Distance(table.Random(poses)) * 1.8 + 2000)

	net.Start("impgw_start")
		net.WriteVector(MODE.ZoneCenter)
		net.WriteFloat(MODE.ZoneStartRadius)
	net.Broadcast()

	hg.UpdateRoundTime(self.ROUND_TIME)
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")),
	       zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then continue end

		ply:SetSuppressPickupNotices(true)
		ply.noSound = true

		if ply:Team() == 0 then
			ply:SetPlayerClass("bloodz")
			zb.GiveRole(ply, "Bloodz", Color(190,0,0))
			ply:SetNetVar("CurPluv", "pluvred")
		else
			ply:SetPlayerClass("groove")
			zb.GiveRole(ply, "Groove", Color(0,190,0))
			ply:SetNetVar("CurPluv", "pluvgreen")
		end

		ply:Give("weapon_hands_sh")

		local loadout = loadouts[math.random(#loadouts)]
		local atts = istable(loadout.attachments) and table.Random(loadout.attachments) or loadout.attachments

		local gun = ply:Give(loadout.primary)
		if IsValid(gun) then
			ply:GiveAmmo(gun:GetMaxClip1() * (loadout.ammo or 3), gun:GetPrimaryAmmoType(), true)
			if atts then hg.AddAttachmentForce(ply, gun, atts) end
		end

		hg.AddArmor(ply, loadout.armor or {"vest3","helmet1"})
		ply:Give(randomMelees[math.random(#randomMelees)])

		if math.random() > 0.3 then
			ply:Give(randomGrenades[math.random(#randomGrenades)])
		end
		for i = 1, math.random(1,2) do
			ply:Give(randomMedicine[math.random(#randomMedicine)])
		end

		ply:Give("weapon_walkie_talkie")
		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then ply.organism.recoilmul = 0.6 end

		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end
		end)
	end

	timer.Simple(15, function()
		if CurrentRound() and CurrentRound().name == "impgw" then
			MODE.ZoneShrinking = true
			MODE.ZoneStartTime = CurTime()
		end
	end)
end

local zoneCooldown = 0
hook.Add("Think", "impgw_zone_damage", function()
	local rnd = CurrentRound()
	if not rnd or rnd.name ~= "impgw" or not MODE.ZoneShrinking then return end
	if zoneCooldown > CurTime() then return end
	zoneCooldown = CurTime() + 0.25

	local center = MODE.ZoneCenter
	local radius = MODE:GetCurrentZoneRadius()
	local radiussqr = radius * radius

	for _, ent in ents.Iterator() do
		if ent:GetPos():DistToSqr(center) <= radiussqr then continue end
		if ent:IsPlayer() and ent:Alive() then
			hg.LightStunPlayer(ent)
		elseif hgIsDoor and hgIsDoor(ent) and not ent:GetNoDraw() then
			hgBlastThatDoor(ent)
		end
	end
end)

function MODE:GetCurrentZoneRadius()
	if not MODE.ZoneShrinking then return MODE.ZoneStartRadius end
	local progress = math.Clamp((CurTime() - MODE.ZoneStartTime) / MODE.ZoneShrinkTime, 0, 1)
	return Lerp(progress, MODE.ZoneStartRadius, MODE.FinalZoneRadius)
end

function MODE:EndRound()
	local alive = self:CheckAlivePlayers()
	local winner = (#alive[0] > 0) and 0 or 1

	timer.Simple(2, function()
		net.Start("impgw_end")
			net.WriteInt(winner, 8)
		net.Broadcast()
	end)

	for _, ply in player.Iterator() do
		if ply:Team() == winner and ply:Alive() then
			ply:GiveExp(math.random(80,150))
			ply:GiveSkill(math.Rand(0.25,0.4))
		else
			ply:GiveSkill(-math.Rand(0.08,0.15))
		end
	end
end