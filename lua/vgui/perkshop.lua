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
	self.btnSell = vgui.Create( "DImageButton", self )
	self.btnSell:SetSize(16,16)
	self.btnSell:SetPos( 2,2 )
	self.btnSell:SetImage( "icon16/money_dollar.png" )
	
	self.btnBuy = vgui.Create( "DImageButton", self )
	self.btnBuy:SetSize( 16,16 )
	self.btnBuy:SetPos( 2, 20 )
	self.btnBuy:SetImage( "icon16/box.png" )
	
	self:SetAnimated( true )
	
	self.perkItem = nil
end

//     Layout     ///
function PANEL:PerformLayout()
	self.btnSell:SetSize( 16,16 )
	self.btnSell:SetPos( 2,2 )
	
	self.btnBuy:SetSize( 16,16 )
	self.btnBuy:SetPos( 2, self:GetTall()-18 )
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

//     Paint     //
local colWhite, colGray, colRed = Color(255,255,255),Color(155,0,0), Color(100,100,100, 150)
function PANEL:Paint(w,h)
	if not self.perkItem then
		surface.SetDrawColor( colRed )
		surface.DrawRect( 0,0, w,h )
		return
	end
	
	draw.RoundedBox( 4, 0,0, w,h, colRed )
	if self.itmMaterial then
		surface.SetDrawColor( colGray )
		surface.SetMaterial( self.itmMaterial )
		surface.DrawTexturedRect( 0,0, w,h )
	end
	
	self.BaseClass.Paint( self,w,h )
	
	ShadowText( self.perkItem.Class, "PerkShop_Small", w/2, h-30, colWhite, TEXT_ALIGN_CENTER )
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
