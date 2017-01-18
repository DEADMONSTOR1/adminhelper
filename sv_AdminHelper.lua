AdminHelper = (AdminHelper or {})

util.AddNetworkString("AdminHelperUpdateClient")
util.AddNetworkString("AdminHelperUpdateClientDuty")
util.AddNetworkString("AdminHelperUpdateClientGodMode")

function AdminHelper.SetupAll()
	if istable(DarkRP) then
		AdminHelper.SetupDatabase()
		AdminHelper.DarkRP = true
	else
		AdminHelper.SetupDatabase()
		AdminHelper.DarkRP = false
	end
	AdminHelper.SetupAdminMode()
	if istable(ulx) and istable(FAdmin) then
		print("AdminHelper: Two admin systems detected. Defaulting onto FAdmin\n")
		AdminHelper.SetupFAdmin()
		AdminHelper.ULX = true
		return
	end
	
	if istable(ulx) then
		AdminHelper.SetupULX()
		AdminHelper.ULX = true
	end
	if istable(FAdmin) then
		AdminHelper.SetupFAdmin()
		AdminHelper.FAdmin = true
	end
end
hook.Add( "Initialize", "Setup Initialization Admin Helper", AdminHelper.SetupAll )



function AdminHelper.SetupDatabase()

	if( sql.Query( "SELECT SteamID,TimeOnDuty,LastOnline FROM AdminHelper" ) == false ) then
		sql.Query( "CREATE TABLE AdminHelper( SteamID string UNIQUE, TimeOnDuty int, LastOnline int, LastOnDuty int)" )
		print( "AdminHelper table successfully made!" )
	end
	
	print( "AdminHelper table successfully initialized!" )
	
end

function AdminHelper.InitializePlayerInfo( ply )
	if !(ply:IsValid() and ply:IsPlayer() and ply:IsAdmin()) then
		return 
	end

	local steamID = ply:SteamID64()
	if( sql.Query( "SELECT * FROM AdminHelper WHERE SteamID = '"..steamID.."'" ) == nil ) then
		sql.Query("INSERT INTO AdminHelper ( SteamID, TimeOnDuty, LastOnline, LastOnDuty ) \
			VALUES ( '"..steamID.."', 0, '"..os.time().."' , 0)" )
	else
		local MyTable = sql.Query( "SELECT SteamID, TimeOnDuty, LastOnline, LastOnDuty FROM AdminHelper WHERE SteamID = '"..steamID.."'" )
		
		for k,v in pairs(MyTable[1]) do
			if k == "SteamID" then continue end
			ply:SetNWInt("AdminHelper "..k,tonumber(v))
			print("AdminHelper "..k..": " ..tonumber(v))
		end
	end
	net.Start("AdminHelperUpdateClient")
		net.WriteBool(false)
		net.WriteBool(AdminHelper.FAdmin)
		net.WriteBool(AdminHelper.ULX)
		net.WriteBool(AdminHelper.DarKRP)
	net.Send(ply)
end
hook.Add( "PlayerInitialSpawn", "Initializing The Player Info for Admin Helper", AdminHelper.InitializePlayerInfo )

function AdminHelper.LUARefreshFuckUP()
	for k,v in pairs(player.GetAll()) do 
		if !(v:IsAdmin()) then return end
		net.Start("AdminHelperUpdateClient")
			net.WriteBool(v:GetNWBool("AdminHelper AdminMode", false))
			net.WriteBool(AdminHelper.FAdmin)
			net.WriteBool(AdminHelper.ULX)
			net.WriteBool(AdminHelper.DarkRP)
		net.Send(v)
	end
end
AdminHelper.LUARefreshFuckUP()

function AdminHelper.SetupFAdmin()

	// Hook into it so when someone gets set a rank it will run InitializePlayerInfo

end

function AdminHelper.SetupAdminMode()

	function AdminHelper.AdminMode(ply, text, public)
		if (string.lower( text ) == "/staff") and (ply:GetNWBool("AdminHelper AdminMode", false) == false) and ply:IsAdmin() == true then
			AdminHelper.OnDuty(ply)
			return ""
		elseif (string.lower( text ) == "/staff") and (ply:GetNWBool("AdminHelper AdminMode", false) == true) and ply:IsAdmin() == true then
			AdminHelper.OffDuty(ply)
			return ""
		end
	end
	hook.Add("PlayerSay", "AdminHelper.AdminMode", AdminHelper.AdminMode)
	
end

function AdminHelper.OffDuty(ply)

	if !(ply:IsValid() and ply:IsPlayer())then
		return 
	end
	ply:SetNWBool("AdminHelper AdminMode", false)
	ply:ChatPrint("Admin Mode disabled")
	
	local timeonduty = tonumber(os.time() - ply:GetNWInt("AdminHelper StartTimeOnDuty", 0))
	ply:SetNWInt("AdminHelper StartTimeOnDuty", 0)
	local fulltimeonduty = tonumber(ply:GetNWInt("AdminHelper TimeOnDuty", 0) + timeonduty)
	ply:SetNWInt("AdminHelper TimeOnDuty", fulltimeonduty)
	ply:SetNWInt("AdminHelper LastOnDuty", os.time())

	ply:ChatPrint("[AdminHelper] You have been on duty for "..math.Round(fulltimeonduty / 60 /60 ).." hours this week.")
	
	net.Start("AdminHelperUpdateClientDuty")
		net.WriteBool(false)
	net.Send(ply)
end

function AdminHelper.OnDuty(ply)

	if !(ply:IsValid() and ply:IsPlayer())then
		return 
	end
	ply:SetNWBool("AdminHelper AdminMode", true)
	ply:ChatPrint("Admin Mode enabled")
	ply:SetNWInt("AdminHelper StartTimeOnDuty", os.time())
	
	net.Start("AdminHelperUpdateClientDuty")
		net.WriteBool(true)
	net.Send(ply)
end

function AdminHelper.SaveInfoOnDisconnect(ply)
	local saveinfo = {}
	table.insert(saveinfo, ply:GetNWInt("AdminHelper TimeOnDuty", 0))
	table.insert(saveinfo, ply:GetNWInt("AdminHelper LastOnDuty", 0))
	sql.Query("UPDATE AdminHelper SET TimeOnDuty='"..saveinfo[1].."', LastOnDuty='"..saveinfo[2].."'")

end
hook.Add("PlayerDisconnected", "AdminHelper.SaveInfoOnDisconnect", AdminHelper.SaveInfoOnDisconnect)

function AdminHelper.ServerShutdown()

	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			AdminHelper.SaveInfoOnDisconnect(v)
		end
	end
end
hook.Add("ShutDown", "AdminHelper.ServerShutdown", AdminHelper.ServerShutdown)

function AdminHelper.FixGodMode()
	for k,v in pairs(player.GetAll()) do
		if (v:IsAdmin()) then 
			if v:IsFlagSet(FL_GODMODE) != v.GodMode then
				v.GodMode = v:IsFlagSet(FL_GODMODE)
				net.Start("AdminHelperUpdateClientGodMode")
					net.WriteBool(v.GodMode)
				net.Send(v)
			end
		end
	end
end
hook.Add("Think", "AdminHelper.GodMode", AdminHelper.FixGodMode)
AdminHelper.SetupAll()