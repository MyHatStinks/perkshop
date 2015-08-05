----------------------------------------
--------------- Perkshop ---------------
----------------------------------------
------- Created by my_hat_stinks -------
----------------------------------------
-- sh_player.lua               SHARED --
--                                    --
-- Player-related stuff.              --
----------------------------------------

// These are server-only hooks, keep them out of client for neatness
if SERVER then
	hook.Add( "PlayerInitialSpawn", "PerkShop_InitialSpawn", function(ply)
		ply:PerkShop_Load()
	end)
end
