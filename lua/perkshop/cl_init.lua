// Perkshop Client //

// Hooks //
hook.Add( "PlayerBindPress", "PerkShop_Bind_Open", function( ply, bind, pressed )
	if bind=="gm_showspare1" and pressed then
		PerkShop:Open()
	end
end)

local shopCommands = {
	["!shop"]=true, ["!perk"]=true, ["!perks"]=true, ["!perkshop"]=true,
	["/shop"]=true, ["/perk"]=true, ["/perks"]=true, ["/perkshop"]=true,
}
hook.Add( "OnPlayerChat", "PerkShop_Chat_Open", function( ply, msg )
	if shopCommands[ msg:lower() ] then
		if ply==LocalPlayer() then
			PerkShop:Open()
		end
		
		return true
	end
end)
