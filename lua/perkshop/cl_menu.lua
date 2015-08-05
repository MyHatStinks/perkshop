----------------------------------------
--------------- Perkshop ---------------
----------------------------------------
------- Created by my_hat_stinks -------
----------------------------------------
-- cl_menu.lua                 CLIENT --
--                                    --
-- Perkshop Menu.                     --
----------------------------------------

PerkShop.Colors = {
	A = Color( 34, 32, 43 ), B = Color( 56, 55, 69 ), C = Color( 125, 105, 98 ),
	D = Color( 202, 141, 110 ), E = Color( 249, 174, 116 ),
	
	Close = Color(225,50,25), White = Color(255,255,255),
	Text = Color(255,255,255,255), TextShadow = Color(0,0,0,255),
}
local Col = PerkShop.Colors

local function ShadowText( str, font, x,y, col, xAlign, yAlign )
	draw.DrawText( str, font, x+1, y+1, Col.TextShadow, xAlign, yAlign )
	draw.DrawText( str, font, x, y, col, xAlign, yAlign )
end

surface.CreateFont( "PerkShop_Main", { font="Arial", size=30, weight=600 })
surface.CreateFont( "PerkShop_Large", { font="Arial", size=50, weight=600 })
surface.CreateFont( "PerkShop_Small", { font="Arial", size=18, weight=600 })
surface.CreateFont( "PerkShop_Tiny", { font="Arial", size=15, weight=600 })

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
	self.Menu:SetSize( math.min(1000,w), math.min(800,h) )
	self.Menu:SetPos( (w/2)-(self.Menu:GetWide()/2), (h/2)-(self.Menu:GetTall()/2) )
	self.Menu:SetTitle( "Perkshop" )
	self.Menu:ShowCloseButton( false )
	self.Menu:MakePopup()
	
	self.Menu.Paint = function( s,w,h )
		surface.SetDrawColor( Col.A )
		surface.DrawRect( 0,0, w,h )
		
		-- surface.SetDrawColor( Col.B )
		-- surface.DrawRect( 0,0, w,20 )
	end
	
	local CloseButton = vgui.Create( "DButton", self.Menu )
	CloseButton:SetSize( 30, 20 )
	CloseButton:SetPos( self.Menu:GetWide()-32, 2 )
	CloseButton:SetText( "" )
	CloseButton.DoClick = function()
		self.Menu:Remove()
	end
	
	surface.SetFont( "PerkShop_Tiny" )
	local _,TextHeight = surface.GetTextSize("X")
	CloseButton.Paint = function( s,w,h )
		surface.SetDrawColor( Col.Close )
		surface.DrawRect( 0,0, w,h )
		
		draw.DrawText( "X", "PerkShop_Tiny", w/2, (h/2)-(TextHeight/2), Col.White, TEXT_ALIGN_CENTER )
	end
	
	// Layout //
	-- local pnlButton = vgui.Create( "DPanel", self.Menu )
	-- pnlButton:Dock( TOP )
	-- pnlButton:SetTall( 40 )
	-- pnlButton.Paint = function() end
	
	local pnlPreview = vgui.Create( "DPanel", self.Menu )
	pnlPreview:Dock( RIGHT )
	pnlPreview:DockPadding(2,2,2,3)
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
		
		surface.SetDrawColor( Col.B )
		surface.DrawRect( 0,0, w,h )
		
		ShadowText( self.PointsLabel or "[PointLabel]", "PerkShop_Main", 10,10, Col.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		ShadowText( ply:PerkShop_Points(), "PerkShop_Large", w/2,50, Col.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	// Item list //
	local pnlItemList = vgui.Create( "DPropertySheet", pnlItems )
	pnlItemList:Dock( FILL )
	pnlItemList:SetPadding( 7 )
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
			Sheet.Tab.Paint = function( s,w,h )
				-- surface.SetDrawColor( Col.B )
				-- surface.DrawOutlinedRect( 0,0, w,h )
			end
			
			for itemName,item in pairs(cat.Items) do
				local listItem = IconFrame:Add( "DPerkShopItem" )
				listItem:SetSize( 128, 128 )
				listItem:SetItem( itemName, catName )
			end
		end
	end
	pnlItemList:Update()
	
	pnlItemList.tabScroller.Paint = function( s,w,h )
		surface.SetDrawColor( Col.C )
		surface.DrawRect( 0,0, w,h-3 )
	end
	pnlItemList.Paint = function( s,w,h )
		surface.SetDrawColor( Col.B )
		surface.DrawRect( 0,0, w,h-3 )
	end
end
