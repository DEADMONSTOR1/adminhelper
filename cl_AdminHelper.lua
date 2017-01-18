AdminHelper = (AdminHelper or {})
AdminHelper.AdminMode = false
AdminHelper.FAdmin = true
AdminHelper.ULX = false
AdminHelper.GodMode = false
AdminHelper.DarkRP = false


function AdminHelper.DrawBox()
	if AdminHelper.AdminMode == true then
		draw.RoundedBox( 4, 0, 0, 180, 90, Color(0, 0, 0, 180) )
		draw.SimpleText( "Admin Helper", "Trebuchet24", 30, 10, Color( 255, 255, 255, 255 ) ) 
		if (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP) then
			draw.SimpleText( "Nocliping", "Trebuchet24", 50, 33, Color( 0, 255, 0, 255 ) ) 
		else
			draw.SimpleText( "Nocliping", "Trebuchet24", 50, 33, Color( 255, 0, 0, 255 ) ) 
		end
		if (AdminHelper.FAdmin) then
			if LocalPlayer():FAdmin_GetGlobal("FAdmin_godded") then
				draw.SimpleText( "Goded", "Trebuchet24", 60, 56, Color( 0, 255, 0, 255 ) ) 
			else
				draw.SimpleText( "Goded", "Trebuchet24", 60, 56, Color( 255, 0, 0, 255 ) ) 
			end
		end
		if (AdminHelper.ULX) then
			if AdminHelper.GodMode == true then
				draw.SimpleText( "Goded", "Trebuchet24", 60, 56, Color( 0, 255, 0, 255 ) ) 
			else
				draw.SimpleText( "Goded", "Trebuchet24", 60, 56, Color( 255, 0, 0, 255 ) ) 
			end
		end
	end
end
hook.Add("HUDPaint", "AdminHelperDrawBox", AdminHelper.DrawBox)

local function DrawText(strText, strFont, tblColor, xPos, yPos)
	draw.SimpleTextOutlined(strText, strFont, xPos, yPos, tblColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
end
	
local function DrawAdminESP()
	if !(AdminHelper.AdminMode) then return end
	local t = ents.GetAll()
	for k=1, #t do
		local v = t[k]
		if(v:IsPlayer()) then
			if(v != LocalPlayer() and v:GetPos():Distance(LocalPlayer():GetPos()) < 3000) then				
				local xPos, yPos = (v:GetPos() + Vector(0, 0, 50)):ToScreen().x, (v:GetPos() + Vector(0, 0, 50)):ToScreen().y
				
				DrawText(v:Nick(), "Default", team.GetColor(v:Team()), xPos, yPos)
				
				yPos = yPos + 13
				if v:SteamID() == "NULL" then
					DrawText("BOT", "Default", Color(255, 255, 255, 255), xPos, yPos)	
				else
					DrawText(v:SteamID(), "Default", Color(255, 255, 255, 255), xPos, yPos)
				end
				yPos = yPos + 13
				if AdminHelper.DarkRP == true then
					DrawText(team.GetName(v:Team()) or "Unknown Class", "Default", Color(255, 255, 255, 255), xPos, yPos)
					yPos = yPos + 13
				end
				DrawText(v:GetUserGroup() or "Unknown Rank", "Default", Color(255, 255, 255, 255), xPos, yPos)
			end
		end
		if(v:IsVehicle() and v:GetPos():Distance(LocalPlayer():GetPos()) < 3000) then
			local xPos, yPos = (v:GetPos() + Vector(0, 0, 50)):ToScreen().x, (v:GetPos() + Vector(0, 0, 50)):ToScreen().y
			
			DrawText("[Vehicle]", "Default", Color(255, 255, 255, 200), xPos, yPos)
		end 
	end
end
hook.Add("HUDPaint", "DrawAdminESPs", DrawAdminESP)


net.Receive( "AdminHelperUpdateClient", function( len, pl )
	AdminHelper.AdminMode = net.ReadBool()
	AdminHelper.FAdmin = net.ReadBool()
	AdminHelper.ULX = net.ReadBool()
	AdminHelper.DarkRP = net.ReadBool()
end )

net.Receive( "AdminHelperUpdateClientDuty", function( len, pl )
	AdminHelper.AdminMode = net.ReadBool()
end )

net.Receive( "AdminHelperUpdateClientGodMode", function( len, pl )
	AdminHelper.GodMode = net.ReadBool()
end )