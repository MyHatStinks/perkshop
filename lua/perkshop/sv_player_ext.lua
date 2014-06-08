// PerkShop Player Extensions (Server) //

local PLAYER = FindMetaTable( "Player" )

// Save data //
function PLAYER:PerkShop_Save()
	if not (self.PerkShop) then return false,"Player not loaded" end
	
	local data = util.TableToJSON( self.PerkShop )
	if not data then return false,"Failed to compress table" end // This shouldn't happen, but just in case
	
	self:SetPData( "PerkShopData", data )
	
	self:PerkShop_UpdateItems()
	
	return true
end
function PLAYER:PerkShop_Load()
	self.PerkShop = { // Create/Reset the table
		Points = (-1),
		Items = {},
		Equipped = {},
	}
	
	local str = self:GetPData( "PerkShopData" )
	if str then
		local data = util.JSONToTable( str )
		if data then
			self.PerkShop.Items = data.Items or self.PerkShop.Items
			self.PerkShop.Equipped = data.Equipped or self.PerkShop.Equipped
			self:PerkShop_SetPoints(data.Points or self.PerkShop.Points)
		end
	end
	
	for classname,level in pairs(self.PerkShop.Equipped) do
		local name,cat = PerkShop:SplitClassname( classname )
		if name and cat then
			local itm = PerkShop:GetItem( name, cat )
			if itm and itm.OnEquip then
				itm:OnEquip( self, level )
			end
		end
	end
	
	self:PerkShop_UpdateItems()
	
	return true
end

// Set data //
function PLAYER:PerkShop_SetPoints( num )
	if not self.PerkShop then return false,"Player not loaded" end // Not loaded, nothing we can do
	
	self.PerkShop.Points = math.max( num, 0 )
	self:SetNWInt( "PerkShop_Points", self.PerkShop.Points )
	
	return true
end
function PLAYER:PerkShop_GivePoints( add ) return self:PerkShop_SetPoints( self:PerkShop_Points() + add ) end // For convenience
function PLAYER:PerkShop_TakePoints( sub ) return self:PerkShop_SetPoints( self:PerkShop_Points() - sub ) end // And again

function PLAYER:PerkShop_ClearItems()
	if not self.PerkShop then return false,"Player not loaded" end // Not loaded, nothing we can do
	
	self.PerkShop.Items = {}
	self:PerkShop_Save()
	
	return true
end
function PLAYER:PerkShop_GiveItem( item, level )
	if not self.PerkShop then return false,"Player not loaded" end // Not loaded, nothing we can do
	
	self.PerkShop.Items[item.Category.."_"..item.Class] = level or 1
	self:PerkShop_Save()
	
	return true
end
function PLAYER:PerkShop_TakeItem( item, level )
	if not self.PerkShop then return false,"Player not loaded" end // Not loaded, nothing we can do
	
	self.PerkShop.Items[item.Category.."_"..item.Class] = nil
	self:PerkShop_Save()
	
	return true
end

// Equipping //
function PLAYER:PerkShop_Equip( item, level ) // Level 0 is unequip
	if not self.PerkShop then return false,"Player not loaded" end
	level = level or 1
	
	local itmLevel = self:PerkShop_HasItem( item.Class, item.Category )
	if not itmLevel then return false,"Attempting to equip unowned item" end
	
	if level>itmLevel then return false,"Attempting to equip higher than level" end
	
	if self.PerkShop.Equipped[item.Classname] and self.PerkShop.Equipped[item.Classname]>0 and item.OnRemove then
		item:OnRemove( self, self.PerkShop.Equipped[item.Classname] )
	end
	
	self.PerkShop.Equipped[item.Classname] = level>0 and level or nil
	self:PerkShop_Save()
	
	if level>0 then
		if item.OnEquip then item:OnEquip( self, level ) end
	end
	
	return true
end
concommand.Add( "perk_equip", function( p,c,a )
	if not (IsValid(p)) then return end
	local item = PerkShop:GetItem( a[2], a[1] )
	if item then p:PerkShop_Equip( item, tonumber(a[3]) or 1 ) end
end)
concommand.Add( "perk_unequip", function( p,c,a )
	if not (IsValid(p)) then return end
	local item = PerkShop:GetItem( a[2], a[1] )
	if item then p:PerkShop_Equip( item, 0 ) end
end)

// Purchasing //
function PLAYER:PerkShop_Buy( item, newLevel )
	if not self.PerkShop then return false,"Player not loaded" end
	
	newLevel = newLevel or 1
	if newLevel>item.Level then return false,"Attempting to buy over max level" end
	
	local oldLevel = self:PerkShop_HasItem( item.Classname ) or 0
	if oldLevel>=newLevel then return false,"Attempting to buy level lower than owned" end
	
	local cost,err = PerkShop:GetCost( item.Class, item.Category, oldLevel, newLevel or 1 )
	if cost==-1 then return false,err or "Failed to calculate value" end
	
	if cost>self:PerkShop_Points() then return false,"Insufficient funds" end
	
	local success,err = self:PerkShop_TakePoints( cost )
	if not success then return false,err or "Failed to spend "..PerkShop.PointsLabel end
	
	return self:PerkShop_GiveItem( item, newLevel or 1 )
end
function PLAYER:PerkShop_Sell( item, sellLevels )
	if not self.PerkShop then return false,"Player not loaded" end
	
	sellLevels = sellLevels or 0
	
	local oldLevel = self:PerkShop_HasItem( item.Classname )
	if not oldLevel then return false,"Attempting to sell unowned item" end
	
	local newLevel = (sellLevels==0 and 0) or math.max(oldLevel-sellLevels,0)
	if oldLevel<newLevel then return false,"Attempting to sell level higher than owned" end
	
	local refund,err = PerkShop:GetCost( item.Class, item.Category, oldLevel, newLevel or 1 )
	if refund==-1 then return false,err or "Failed to calculate value" end
	
	refund = refund*0.75
	
	local success,err = self:PerkShop_GivePoints( refund )
	if not success then return false,err or "Failed to refund "..PerkShop.PointsLabel end
	
	if newLevel>0 then
		return self:PerkShop_GiveItem( item, newLevel )
	else
		return self:PerkShop_TakeItem( item )
	end
end

concommand.Add( "perk_buy", function( p,c,a )
	if not (IsValid(p)) then return end
	local item = PerkShop:GetItem( a[2], a[1] )
	if item then
		local success,err = p:PerkShop_Buy( item, tonumber(a[3]) )
		if success then
			p:ChatPrint( string.format( "%sSuccessfully bought %s: %s %s", PerkShop.Tag, a[1], a[2], tonumber(a[3]) and "(level "..tonumber(a[3])..")" or "" ) )
		else
			p:ChatPrint( string.format( "%sPurchase failed. (%s)", PerkShop.Tag, err or "N/A" ) )
		end
	else
		p:ChatPrint( string.format( "%sPurchase failed. (Item %s_%s does not exist)", PerkShop.Tag, a[1], a[2] ) )
	end
end)
concommand.Add( "perk_sell", function( p,c,a )
	if not (IsValid(p)) then return end
	local item = PerkShop:GetItem( a[2], a[1] )
	if item then
		local success,err = p:PerkShop_Sell( item, tonumber(a[3]) )
		if success then
			p:ChatPrint( string.format( "%sSuccessfully sold %s: %s %s", PerkShop.Tag, a[1], a[2], tonumber(a[3]) and "("..tonumber(a[3]).." levels)" or "" ) )
		else
			p:ChatPrint( string.format( "%sSale failed. (%s)", PerkShop.Tag, err or "N/A" ) )
		end
	else
		p:ChatPrint( string.format( "%sSale failed. (Item %s_%s does not exist)", PerkShop.Tag, a[1], a[2] ) )
	end
end)
