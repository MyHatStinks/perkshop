// Perkshop custom panels //

local function ShadowText( str, font, x,y, col, xAlign, yAlign )
	draw.DrawText( str, font, x+1, y+1, Color(0,0,0), xAlign, yAlign )
	draw.DrawText( str, font, x, y, col, xAlign, yAlign )
end

////////////////
// Item Panel //
////////////////
local PANEL = {}

//    Init     //
function PANEL:Init()
	self:SetAnimated( true )
	
	self.perkItem = nil
end

//     Layout     ///
function PANEL:PerformLayout()
end
function PANEL:LayoutEntity( Entity )
	if not Entity.IsSetup then
		local min,max = Entity:GetRenderBounds()
		
		local d = min:Distance(max)
		self:SetCamPos( Vector(0.3,0.3,0.3)*d )
		self:SetLookAt( min-max )
		
		Entity.IsSetup = true
	end
	
	if ( self.bAnimated ) then
		self:RunAnimation()
	end
	
	Entity:SetAngles( Angle( 0, RealTime()*10,  0) )
end

//     Do Click     //
function PANEL:DoClick()
	if not self.perkItem then return end
	if not self.SelectedLevel then return end
	
	if self.ShowBuyMenu then
		local HasLevel = LocalPlayer():PerkShop_HasItem( self.perkItem.Classname ) or 0
		if self.SelectedLevel>HasLevel then
			RunConsoleCommand( "perk_buy", self.perkItem.Category, self.perkItem.Class, self.SelectedLevel )
		elseif self.SelectedLevel<HasLevel then
			RunConsoleCommand( "perk_sell", self.perkItem.Category, self.perkItem.Class, HasLevel-self.SelectedLevel )
		end
	elseif self.ShowEquipMenu then
		local EqpLevel = LocalPlayer():PerkShop_ItemLevel( self.perkItem.Classname )
		if self.SelectedLevel~=EqpLevel then
			RunConsoleCommand( "perk_equip", self.perkItem.Category, self.perkItem.Class, self.SelectedLevel )
		end
	end
end

//     Paint     //
local colWhite, colGray, colRed = Color(255,255,255),Color(155,0,0), Color(100,100,100, 150)
local ItemCol = {
	LevelEquipped = Color(240,240,60), LevelOwned = Color(140,140,60), LevelUnowned = Color(60,60,60), LevelHover = Color(255,255,255,20), LevelBG = Color(0,0,0,100)
}
local matBuy,matEquip = Material("icon16/money_dollar.png"), Material("icon16/box.png")
function PANEL:Paint(w,h)
	if not self.perkItem then
		surface.SetDrawColor( colRed )
		surface.DrawRect( 0,0, w,h )
		return
	end
	
	surface.SetDrawColor( colRed )
	surface.DrawRect( 0,0, w,h )
	if self.itmMaterial then
		surface.SetDrawColor( colGray )
		surface.SetMaterial( self.itmMaterial )
		surface.DrawTexturedRect( 0,0, w,h )
	end
	
	self.BaseClass.Paint( self,w,h )
	
	surface.SetDrawColor( colWhite )
	surface.SetMaterial( matBuy )
	surface.DrawTexturedRect( 2,2, 16,16 )
	
	surface.SetMaterial( matEquip )
	surface.DrawTexturedRect( 2,h-18, 16,16 )
	
	local lvlSpacing = (self:GetWide()-24) / (self.perkItem.Level or 1)
	local x,y = self:LocalCursorPos()
	
	self.SelectedLevel = nil
	if self.ShowBuyMenu then
		local HasLevel = LocalPlayer():PerkShop_HasItem( self.perkItem.Classname ) or 0
		surface.SetDrawColor( ItemCol.LevelBG )
		surface.DrawRect( 20,2, self:GetWide()-24, 16 )
		for i=1,(self.perkItem.Level or 1) do
			surface.SetDrawColor( i<=HasLevel and ItemCol.LevelEquipped or ItemCol.LevelUnowned )
			surface.DrawRect( 22+(lvlSpacing*(i-1)),4, lvlSpacing-4, 12 )
			
			if (x-20)>lvlSpacing*(i-1) and (x-20)<lvlSpacing*(i) then
				self.SelectedLevel = i
				surface.SetDrawColor( ItemCol.LevelHover )
				surface.DrawRect( 20+(lvlSpacing*(i-1)),2, lvlSpacing, 16 )
			end
		end
		
		if x<=18 then self.SelectedLevel = 0 end
		
		local diff = (self.SelectedLevel or 0) - HasLevel
		if diff~=0 then
			local cost = PerkShop:GetCost( self.perkItem.Class, self.perkItem.Category, HasLevel, self.SelectedLevel or 0 ) or -1
			if diff<0 then
				cost = cost * (0.75)
			end
			ShadowText( Format( "%s %s level%s", diff>0 and "Buy" or "Sell", math.abs(diff), (diff~=1 and diff~=-1) and "s" or "" ), "PerkShop_Tiny", w/2, 20, colWhite, TEXT_ALIGN_CENTER )
			ShadowText( cost, "PerkShop_Tiny", w/2, 32, colWhite, TEXT_ALIGN_CENTER )
		end
		
	elseif self.ShowEquipMenu then
		local HasLevel = LocalPlayer():PerkShop_HasItem( self.perkItem.Classname ) or 0
		local EqpLevel = LocalPlayer():PerkShop_ItemLevel( self.perkItem.Classname )
		
		surface.SetDrawColor( ItemCol.LevelBG )
		surface.DrawRect( 20,h-16, self:GetWide()-24, 16 )
		for i=1,(self.perkItem.Level or 1) do
			surface.SetDrawColor( (i<=EqpLevel and ItemCol.LevelEquipped) or (i<=HasLevel and ItemCol.LevelOwned) or ItemCol.LevelUnowned )
			surface.DrawRect( 22+(lvlSpacing*(i-1)),h-14, lvlSpacing-4, 12 )
			
			if (x-20)>lvlSpacing*(i-1) and (x-20)<lvlSpacing*(i) then
				self.SelectedLevel = i
				surface.SetDrawColor( ItemCol.LevelHover )
				surface.DrawRect( 20+(lvlSpacing*(i-1)),h-16, lvlSpacing, 16 )
			end
		end
		
		if x<=18 then self.SelectedLevel = 0 end
		
		local diff = (self.SelectedLevel or 0) - EqpLevel
		if diff~=0 and (self.SelectedLevel or 0)<=HasLevel then
			ShadowText( Format( "%s %s level%s", diff>0 and "Equip" or "Unequip", math.abs(diff), (diff~=1 and diff~=-1) and "s" or "" ), "PerkShop_Tiny", w/2, 20, colWhite, TEXT_ALIGN_CENTER )
		end
	end
	
	ShadowText( self.perkItem.Class, "PerkShop_Small", w/2, h-35, colWhite, TEXT_ALIGN_CENTER )
end

function PANEL:Think()
	if not self.perkItem then return end
	if not self:IsHovered() then
		self.ShowBuyMenu = false
		self.ShowEquipMenu = false
		return
	end
	
	local x,y = self:LocalCursorPos()
	if y<18 then
		if x<18 then
			self.ShowBuyMenu = true
		end
	else
		self.ShowBuyMenu = false
	end
	
	if y>(self:GetTall()-18) then
		if x<18 then
			self.ShowEquipMenu = true
		end
	else
		self.ShowEquipMenu = false
	end
end

//     Item     //
function PANEL:SetItem( item, cat )
	if type(item)=="string" then
		if not cat then
			item,cat = PerkShop:SplitClassname( item )
		end
		item = PerkShop:GetItem( item, cat )
	end
	
	if item and item.Class and item.Category and item.Cost then // Mandatory fields
		self.perkItem = item
		
		if IsValid( self.Entity ) then self.Entity:Remove() self.Entity = nil end
		self.itmMaterial = nil
		
		if item.Material then
			self.itmMaterial = Material(item.Material)
		elseif item.Model then
			self:SetModel( item.Model )
		else
			self:SetModel( "models/maxofs2d/hover_rings.mdl" )
		end
	end
end

derma.DefineControl( "DPerkShopItem", "Item panel for PerkShop", PANEL, "DModelPanel" )
