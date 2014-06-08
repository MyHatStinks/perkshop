// PerkShop Default Perks //

PerkShop:CreateCategory( "Perks" )

// Regeneration //
local PerkRegen = {}
PerkRegen.Cost = 300
PerkRegen.Level = 5 // Max level

function PerkRegen:OnEquip( ply, level )
	if not (IsValid(ply) and level and level>0) then return end
	if ply.PerkRegen_HealthMod then self:OnRemove( ply ) end // Just make sure we don't permanently lower their health accidentally
	
	ply.PerkRegen_HealthMod = level*10
	ply:SetMaxHealth( ply:GetMaxHealth() - ply.PerkRegen_HealthMod )
	ply:SetHealth( math.min( ply:Health(), ply:GetMaxHealth() ) )
end
function PerkRegen:OnRemove( ply, level )
	if not (IsValid(ply) and ply.PerkRegen_HealthMod) then return end // We're not modified
	
	ply:SetMaxHealth( ply:GetMaxHealth() + ply.PerkRegen_HealthMod )
	ply.PerkRegen_HealthMod = nil
end

function PerkRegen:OnSpawn( ply, level )
	return self:OnEquip( ply, level )
end
function PerkRegen:OnDie( ply, level )
	return self:OnRemove( ply, level )
end

if SERVER then
	timer.Create( "PerkShop_PerkRegeneration", 1, 0, function()
		for _,ply in pairs(player.GetAll()) do
			if not (IsValid(ply) and ply:Alive()) then continue end
			
			local level = ply:PerkShop_ItemLevel( "Perks_Regeneration" )
			if level and level>0 then
				ply:SetHealth( math.Approach(ply:Health(), ply:GetMaxHealth(), level) )
			end
		end
	end)
end
PerkShop:CreateItem( "Regeneration", "Perks", PerkRegen )

// Fortune //
local PerkFortune = {}
PerkFortune.Cost = 500
PerkFortune.Level = 5

if SERVER then
	timer.Create( "PerkShop_PerkFortune", 300, 0, function()
		for _,ply in pairs(player.GetAll()) do
			if not (IsValid(ply)) then continue end
			
			local level = ply:PerkShop_ItemLevel( "Perks_Fortune" )
			ply:PerkShop_GivePoints( level+1 )
			ply:ChatPrint( string.format("%sYou have received %i %s for playing.", PerkShop.Tag, level+1, PerkShop.PointsLabel) )
		end
	end)
end
PerkShop:CreateItem( "Fortune", "Perks", PerkFortune )
