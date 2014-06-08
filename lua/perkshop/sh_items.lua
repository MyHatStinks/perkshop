// PerkShop Items (Shared) //

PerkShop.ItemTable = {}

// Categories //
function PerkShop:CreateCategory( name )
	if not name then return false end
	if self.ItemTable[name] then return self.ItemTable[name] end // It's already set up
	
	self.ItemTable[name] = {}
	return self.ItemTable[name]
end
function PerkShop:GetCategory( name )
	if not name then return end
	
	return self.ItemTable[name]
end
function PerkShop:IsCategory( name )
	return tobool( self:GetCategory(name) )
end

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
	if not tblCat then return false end // This shouldn't happen
	
	// if tblCat[name] then return false end // An item of this name already exists
	
	tblCat[name] = data
	
	return true
end
function PerkShop:GetItem( name, cat )
	return (name and cat and self:IsCategory(cat)) and self.ItemTable[cat][name] or nil // Nil to make output consistent
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
end
PerkShop:LoadItems()
