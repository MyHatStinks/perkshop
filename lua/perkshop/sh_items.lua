// PerkShop Items (Shared) //

PerkShop.ItemTable = {}

// Categories //
function PerkShop:CreateCategory( name, data )
	if not name then return false end
	if self.ItemTable[name] then return self.ItemTable[name] end // It's already set up
	
	self.ItemTable[name] = data or {}
	self.ItemTable[name].Items = {}
	return self.ItemTable[name]
end
function PerkShop:GetCategory( name )
	if not name then return end
	
	return self.ItemTable[name]
end
function PerkShop:GetCategoryItems( name )
	if not name then return end
	
	return self.ItemTable[name] and self.ItemTable[name].Items
end
function PerkShop:IsCategory( name ) return tobool( self:GetCategory(name) ) end

// Items //
function PerkShop:CreateItem( name, cat, data )
	if not (name and cat and data) then return false end
	if not data.Cost then return false end // Mandatory fields
	
	data.Category = cat
	data.Class = name
	data.Classname = cat.."_"..name
	
	if not self:IsCategory( cat ) then // Category doesn't exist
		if not self:CreateCategory( cat ) then // Try to make it
			return false // Couldn't make it
		end
	end
	
	local tblCat = self:GetCategory( cat )
	if not (tblCat and tblCat.Items) then return false end // This shouldn't happen
	
	// if tblCat[name] then return false end // An item of this name already exists
	
	tblCat.Items[name] = data
	
	if data.Hooks then
		for hk,func in pairs( data.Hooks ) do
			hook.Add( hk, string.format("PerkShop_Hooks_%s_%s", name, hk), function(...)
				for _,ply in pairs(player.GetAll()) do
					if IsValid(ply) and ply:PerkShop_ItemEquipped( name, cat ) then
						data.Hooks[hk]( data, ply, ply:PerkShop_ItemLevel( name, cat ), ... )
					end
				end
			end)
		end
	end
	
	return true
end
function PerkShop:GetItem( name, cat )
	return (name and cat and self:IsCategory(cat)) and self.ItemTable[cat].Items and self.ItemTable[cat].Items[name] or nil // Nil to make output consistent
end
function PerkShop:IsItem( name, cat )
	return tobool( self:GetItem(name,cat) ) // We're basically doing the same thing, re-use
end

function PerkShop:SplitClassname( classname )
	local exp = string.Explode( "_", classname, false )
	
	local class = exp[1]
	local name = table.concat( exp, "_", 2, #exp )
	
	return name,class
end

// Costs //
local function DefaultScale( cost, oldLevel, newLevel, scaleOverride )
	local levelCost = cost
	local retCost = 0
	
	for i=(oldLevel+1),newLevel do
		levelCost = math.Round( cost^(1+((scaleOverride or 0.01)*(i-1))) )
		retCost = retCost+levelCost
	end
	
	return retCost
end
function PerkShop:GetCost( name, cat, oldLevel, newLevel )
	if not self:IsItem( name, cat ) then return -1 end // -1 for invalid items
	
	if not newLevel then
		newLevel = oldLevel or 1
		oldLevel = 0
	end
	if newLevel<oldLevel then // Swap
		local tmp = newLevel
		newLevel = oldLevel
		oldLevel = tmp
	end
	
	local item = self:GetItem( name, cat )
	
	local cost = item.Cost
	if item.CostScale then
		if type(item.CostScale)=="number" then
			cost = DefaultScale( item.Cost, oldLevel, newLevel, item.CostScale )
		else
			cost = item.CostScale( item.Cost, oldLevel, newLevel)
		end
	else
		cost = DefaultScale( item.Cost, oldLevel, newLevel )
	end
	
	return cost
end

// Load items //
local PointshopFuncConversion = {
	["OnBuy"] = "OnBuy", ["OnSell"] = "OnSell", ["OnEquip"] = "OnEquip", ["OnHolster "] = "OnRemove",
}
function PerkShop:LoadItems()
	if not file.IsDir( "perkshop/items", "LUA" ) then return end
	
	local items, dirs = file.Find( "perkshop/items/*", "LUA" )
	
	for _,f in pairs( items ) do
		if SERVER then AddCSLuaFile( "perkshop/items/"..f ) end
		include( "perkshop/items/"..f )
	end
	
	for _,d in pairs( dirs ) do
		local items = file.Find( "perkshop/items/"..d.."/*", "LUA" )
		for _,f in pairs( items ) do
			if SERVER then AddCSLuaFile( "perkshop/items/"..d.."/"..f ) end
			include( "perkshop/items/"..d.."/"..f )
		end
	end
	
	if true then return end // TODO: Complete this stuff
	// Pointshop compatibility //
	// My system is neater, but compatibility...
	if not file.IsDir( "items", "LUA" ) then return end // Good news, we're not converting any pointshop items!
	local _,pointDir = file.Find( "items/*", "LUA" )
	
	for _,pointCatName in pairs(pointDir) do
		if not file.Exists( "items/"..pointCatName.."/__category.lua", "LUA" ) then continue end
		
		CATEGORY = {} // Why global?
		
		if SERVER then AddCSLuaFile("items/"..pointCatName.."/__category.lua") end
		include( "items/"..pointCatName.."/__category.lua" )
		
		if not CATEGORY.Name then continue end // No name, no category
		
		local newCat = {} // Put it in our format. We use nil for defaults, so this is fine
		newCat.Icon = CATEGORY.Icon
		newCat.SortOrder = CATEGORY.Order
		newCat.MaxEquip = (CATEGORY.AllowedEquipped>=0) and CATEGORY.AllowedEquipped
		newCat.AllowedRank = CATEGORY.AllowedUserGroups
		newCat.VisibleFunc = CATEGORY.PlayerCanSee
		
		self:CreateCategory( CATEGORY.Name, newCat ) // Make the category
		
		// Now for items //
		local pointItemFiles = file.Find( "items/"..pointCatName.."/*.lua", "LUA" )
		for _,pointFileName in pairs( pointItemFiles ) do
			if pointFileName=="__category.lua" then continue end
			
			ITEM = {}
			
			if SERVER then AddCSLuaFile("items/"..pointCatName.."/"..pointFileName..".lua") end
			include( "items/"..pointCatName.."/"..pointFileName..".lua" )
			
			if not ITEM.Name then continue end
			
			local newItem = {}
			
			// TODO: Create Item
		end
	end
end
PerkShop:LoadItems()
