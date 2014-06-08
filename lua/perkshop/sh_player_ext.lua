// PerkShop Player Extensions (Shared) //

local PLAYER = FindMetaTable( "Player" )

// Get data //
function PLAYER:PerkShop_Points()
	return self:GetNWInt( "PerkShop_Points", -1 ) // We use a NWVar because it simplifies networking. It's not the most efficient, by far.
end
function PLAYER:PerkShop_Items() // If the items table exists, hand out a copy of it. Otherwise, give a false, we're not set up
	return self.PerkShop and (self.PerkShop.Items and table.Copy(self.PerkShop.Items)) or false
end
function PLAYER:PerkShop_Equipped()
	return self.PerkShop and (self.PerkShop.Equipped and table.Copy(self.PerkShop.Equipped)) or false
end

function PLAYER:PerkShop_HasItem( item, cat )
	if not item then return false end // What are we looking for?
	if not self.PerkShop then return false end // Not loaded
	if cat then item = cat.."_"..item end
	
	local items = self:PerkShop_Items()
	if not items then return false end
	
	for name,level in pairs( items ) do
		if name==item then return level end // Yep, we've got it! Return level
	end
	
	return false
end
PLAYER.PerkShop_GetItem = PLAYER.PerkShop_HasItem

function PLAYER:PerkShop_ItemEquipped( item, cat )
	if not item then return false end
	if not self.PerkShop then return false end
	if cat then item = cat.."_"..item end
	
	local items = self:PerkShop_Equipped()
	if not items then return false end
	
	return items[item] or false
end
function PLAYER:PerkShop_ItemLevel( item, cat ) // Quick output, validated. 0 is unequipped or unpurchased
	return tonumber( self:PerkShop_ItemEquipped(item,cat) ) or 0
end

// Helper //
function PLAYER:PerkShop_ValidateEquipment()
	if not self.PerkShop then return end
	if not self.PerkShop.Equipped then return end
	
	for class,level in pairs(self.PerkShop.Equipped) do
		local hasLvl = self:PerkShop_HasItem( class )
		if not hasLvl then
			self.PerkShop.Equipped[class] = nil
		elseif hasLvl<level then
			self.PerkShop.Equipped[class] = hasLvl
		end
	end
end

// Networking functions //
local function SendItems(ply)
	ply:PerkShop_ValidateEquipment()
	
	local items = ply:PerkShop_Items()
	if not items then // Not loaded?
		ply:PerkShop_Load() // Re-load!
		
		items = ply:PerkShop_Items() // Try again
		
		if not items then return end // Still nothing, guess we quit
	end
	local eqp = ply:PerkShop_Equipped()
	
	net.Start( "perkshop_items" ) // We've got something, let's send it
		net.WriteTable( items )
		net.WriteTable( eqp or {} )
	net.Send( ply )
end
function PLAYER:PerkShop_UpdateItems()
	if CLIENT and LocalPlayer()==self then
		net.Start( "perkshop_items") net.SendToServer()
	elseif SERVER then
		SendItems( self )
	end
end

// Net messages //
net.Receive( "perkshop_items", function( len, ply ) // Can't use a NWvar here, it's too complex
	if SERVER and IsValid(ply) then
		SendItems(ply)
	elseif CLIENT then
		local ply = LocalPlayer()
		if not IsValid(ply) then return end // Why would we get this before we're set up?
		
		ply.PerkShop = ply.PerkShop or {}
		
		local items = net.ReadTable()
		if not items then return end
		
		ply.PerkShop.Items = items
		
		local eqp = net.ReadTable()
		if not eqp then
			ply.PerkShop.Equipped = {}
			return
		end
		
		ply.PerkShop.Equipped = eqp
	end
end)
