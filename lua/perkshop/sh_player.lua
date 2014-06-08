// PerkShop Player (server) //

// These are server-only hooks, keep them out of client for neatness
if SERVER then
	hook.Add( "PlayerInitialSpawn", "PerkShop_InitialSpawn", function(ply)
		ply:PerkShop_Load()
	end)

	local function ProcessEquipment( ply, funcName, ... ) // vararg additional paramaters for the item
		if not (IsValid(ply) and ply.PerkShop and ply.PerkShop.Equipped and funcName) then return end
		
		for classname,level in pairs( ply.PerkShop.Equipped ) do
			local name,cat = PerkShop:SplitClassname( classname )
			if name and cat then
				local itm = PerkShop:GetItem( name, cat )
				if itm and itm[funcName] then
					itm[funcName]( itm, ply, level, ... )
				end
			end
		end
	end
	hook.Add( "PlayerSpawn", "PerkShop_PlayerSpawn", function( ply )
		ProcessEquipment( ply, "OnSpawn" )
	end)
	hook.Add( "PlayerDeath", "PerkShop_PlayerDeath", function( ply, wep, att )
		ProcessEquipment( ply, "OnSpawn" )
		ProcessEquipment( att, "OnKill", wep, att )
	end)
end
