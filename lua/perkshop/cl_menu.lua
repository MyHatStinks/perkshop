// Perkshop Menu //

local PanelColor = {
	Text = Color(255,255,255,255), TextShadow = Color(0,0,0,255),
	
	dbgPnl = Color(150,150,180,150)
}
local function ShadowText( str, font, x,y, col, xAlign, yAlign )
	draw.DrawText( str, font, x+1, y+1, PanelColor.TextShadow, xAlign, yAlign )
	draw.DrawText( str, font, x, y, col, xAlign, yAlign )
end

surface.CreateFont( "PerkShop_Main", { font="Arial", size=30, weight=600 })
surface.CreateFont( "PerkShop_Large", { font="Arial", size=50, weight=600 })
surface.CreateFont( "PerkShop_Small", { font="Arial", size=18, weight=600 })

function PerkShop:Open()
	if IsValid(self.Menu) then self.Menu:Remove() end
	
	local w,h = ScrW(),ScrH()
	
	// Some panels are referenced at various points, but don't need to be global
	// Declare them here
	local btnItems,btnInventory,btnMisc
	local pnlStatus,pnlPreviewModel
	local pnlItemList
	
	// Frame //
	self.Menu = vgui.Create( "DFrame" )
	self.Menu:SetSize( 600, math.min(600,h) )
	self.Menu:SetPos( (w/2)-300, (h/2)-(self.Menu:GetTall()/2) )
	self.Menu:SetTitle( "Perkshop" )
	self.Menu:MakePopup()
	
	// Layout //
	local pnlButton = vgui.Create( "DPanel", self.Menu )
	pnlButton:Dock( TOP )
	pnlButton:SetTall( 40 )
	pnlButton.Paint = function() end
	
	local pnlPreview = vgui.Create( "DPanel", self.Menu )
	pnlPreview:Dock( RIGHT )
	pnlPreview:SetWide( 250 )
	pnlPreview.Paint = function() end
	
	local pnlItems = vgui.Create( "DPanel", self.Menu )
	pnlItems:Dock( FILL )
	pnlItems.Paint = function() end
	
	// Buttons //
	-- btnItems = vgui.Create( "DButton", pnlButton )
	-- btnItems:Dock( LEFT )
	-- btnItems:SetWide( 195 )
	-- btnItems:SetText( "Shop" )
	
	-- btnMisc = vgui.Create( "DButton", pnlButton )
	-- btnMisc:Dock( RIGHT )
	-- btnMisc:SetWide( 195 )
	-- btnMisc:SetText( "[[TODO:Make this do something]]" )
	
	-- btnInventory = vgui.Create( "DButton", pnlButton )
	-- btnInventory:Dock( FILL )
	-- btnInventory:SetText( "Inventory" )
	
	// Item preview //
	local ply = LocalPlayer()
	pnlStatus = vgui.Create( "DPanel", pnlPreview )
	pnlStatus:Dock( BOTTOM )
	pnlStatus:SetTall( self.Menu:GetTall()*0.2 )
	pnlStatus.Paint = function( s, w,h )
		if not IsValid(ply) then ply=LocalPlayer() return end
		
		draw.RoundedBox( 2, 0,0, w,h, PanelColor.dbgPnl )
		ShadowText( self.PointsLabel or "[PointLabel]", "PerkShop_Main", 10,10, PanelColor.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		ShadowText( ply:PerkShop_Points(), "PerkShop_Large", w/2,50, PanelColor.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	// Item list //
	local pnlItemList = vgui.Create( "DPropertySheet", pnlItems )
	pnlItemList:Dock( FILL )
	pnlItemList.Empty = function(s)
		if not s.Items then return end
		
		for _,itm in pairs( s.Items ) do s:CloseTab( s.Items.Tab, true ) end
	end
	pnlItemList.Update = function(s)
		s:Empty()
		
		if not PerkShop then return end
		if not PerkShop.ItemTable then return end
		
		for catName,cat in pairs( PerkShop.ItemTable ) do
			if not cat.Items then continue end
			
			local IconFrame = vgui.Create( "DIconLayout", s )
			IconFrame:SetSpaceX( 5 )
			local Sheet = s:AddSheet( catName, IconFrame, "icon16/cake.png" )
			
			for itemName,item in pairs(cat.Items) do
				local listItem = IconFrame:Add( "DPerkShopItem" )
				listItem:SetSize( 128, 128 )
				listItem:SetItem( itemName, catName )
			end
		end
	end
	pnlItemList:Update()
end
