// Perkshop Menu //

function PerkShop:Open()
	if IsValid(self.Menu) then self.Menu:Remove() end
	
	local w,h = ScrW(),ScrH()
	
	self.Menu = vgui.Create( "DFrame" )
	self.Menu:SetSize( 600, math.min(600,h) )
	self.Menu:SetPos( (w/2)-300, (h/2)-(self.Menu:GetTall()/2) )
	self.Menu:SetTitle( "Perkshop" )
	self.Menu:MakePopup()
	
	local pnlButton = vgui.Create( "DPanel", self.Menu )
	pnlButton:Dock( TOP )
	pnlButton:SetTall( 40 )
	
	local pnlPreview = vgui.Create( "DPanel", self.Menu )
	pnlPreview:Dock( RIGHT )
	pnlPreview:SetWide( 250 )
	
	local pnlItems = vgui.Create( "DPanel", self.Menu )
	pnlItems:Dock( FILL )
end
