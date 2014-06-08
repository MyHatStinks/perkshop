// Perkshop Autorun //

PerkShop = PerkShop or {}
PerkShop.ShopName = "PerkShop" // This'll show in a few places
PerkShop.Tag = "[SHOP] " // To show before messages, if you like
PerkShop.PointsLabel = "Coins" // What do we call our points? This label will be used everywhere

if SERVER then
	// Add client/shared stuff
	AddCSLuaFile( "perkshop/sh_items.lua" )
	AddCSLuaFile( "perkshop/sh_player_ext.lua" )
	AddCSLuaFile( "perkshop/sh_player.lua" )
	AddCSLuaFile( "perkshop/cl_init.lua" )
	AddCSLuaFile( "perkshop/cl_menu.lua" )
	
	// Shared (Server)
	include( "perkshop/sh_items.lua" )
	include( "perkshop/sh_player_ext.lua" )
	include( "perkshop/sh_player.lua" )
	
	// Server
	include( "perkshop/init.lua" )
	include( "perkshop/sv_player_ext.lua" )
else
	// Shared (Client)
	include( "perkshop/sh_items.lua" )
	include( "perkshop/sh_player_ext.lua" )
	include( "perkshop/sh_player.lua" )
	
	// Client
	include( "perkshop/cl_init.lua" )
	include( "perkshop/cl_menu.lua" )
end
