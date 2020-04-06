vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_lockdown")

lockdown = false
Cooldown = false

-- Blip on the Map
Citizen.CreateThread(function()
    blip1 = AddBlipForCoord(Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z)
    SetBlipSprite(blip1, 459)
    SetBlipColour(blip1, 1)
    SetBlipAsShortRange(blip1, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.TextComponentString)
    EndTextCommandSetBlipName(blip1)   
end)

-- The Active Lockdown 3D Text Message
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5)
        local player = GetPlayerPed(-1)
        local playerLoc = GetEntityCoords(player)
		if lockdown == false then
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z, true ) < 1 then
				DrawText3D(Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z+0.9, Config.ActiveText)
				if IsControlJustReleased(1, 38) then
					TriggerServerEvent('ToXicGlo:Lockdown')
				end
			end
        end
    end
end)

-- The Cooldown 3D Text Message after the Lockdown
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5)
        local player = GetPlayerPed(-1)
        local playerLoc = GetEntityCoords(player)
		if Cooldown == true then
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z, true ) < 1 then
				DrawText3D(Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z+0.9, Config.LockdownText)
			end
        end
    end
end)


-- Lockdown Event (When you press E)
RegisterNetEvent('ToXicGlo:Lockdown')
AddEventHandler('ToXicGlo:Lockdown', function()
	local ped = PlayerPedId()
	TriggerServerEvent('ToXicGlo:NotifyPolice')	
	lockdown = true	
	
	prop = GetHashKey("prop_cs_hand_radio")
	object = CreateObject(GetHashKey("prop_police_radio_main"), GetEntityCoords(PlayerPedId()), true)
	
	AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
 
	RequestAnimDict('weapons@projectile@sticky_bomb')
	while not HasAnimDictLoaded('weapons@projectile@sticky_bomb') do
		Citizen.Wait(100)
	end 

	TaskPlayAnim(ped, 'weapons@projectile@sticky_bomb', 'plant_vertical', 8.0, -8, -1, 49, 0, 0, 0, 0)	
	exports['progressBars']:startUI(1700, Config.ConnectingDevice)
	Citizen.Wait(1000)
	DeleteEntity(object)
	Citizen.Wait(700)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	Citizen.Wait(200)
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, true)
	exports['progressBars']:startUI(2500, Config.TakingDevice)
	Citizen.Wait(2600)
	exports['progressBars']:startUI(7000, Config.OpenEXE)
	Citizen.Wait(7100)
    TriggerEvent("mhacking:show")
    TriggerEvent("mhacking:start",7,60,mycb)
	exports['mythic_notify']:DoCustomHudText('inform', Config.FindCode, 5000)
    robbed = true
end)

-- Activates the Lockdown
RegisterNetEvent('ToXicGlo:AktiverLockdown')
AddEventHandler('ToXicGlo:AktiverLockdown', function()
	SetBlackout(true)
	Cooldown = true
	Citizen.Wait(Config.Cooldown)
	SetBlackout(false)
	Cooldown = false
	lockdown = false
end)


-- Hacking

function mycb(success, timeremaining)
	if success then
		local ped = PlayerPedId()
		TriggerEvent('mhacking:hide')
		exports["datacrack"]:Start(4)
	else
		ClearPedTasks(PlayerPedId())
		Cooldown = true
        TriggerEvent('mhacking:hide')
        exports['mythic_notify']:DoCustomHudText('error', Config.LockdownFAILED, 5000)
	end
end

AddEventHandler("datacrack", function()
	local ped = PlayerPedId()
	ClearPedTasks(PlayerPedId())
	exports['mythic_notify']:DoCustomHudText('inform', Config.HackSuccess, 3000)
	Citizen.Wait(5000)
	exports['mythic_notify']:DoCustomHudText('inform', Config.LockdownIn5Sec, 3000)
	Citizen.Wait(5000)
	exports['mythic_notify']:DoCustomHudText('success', Config.LockdownACTIVE, 10000)
	TriggerEvent('ToXicGlo:AktiverLockdown')
end)

-- Sets blip on marker to the Police Officers

RegisterNetEvent('ToXicGlo:setblip')
AddEventHandler('ToXicGlo:setblip', function()
    blipLockdown = AddBlipForCoord(Config.Lockdown.x, Config.Lockdown.y, Config.Lockdown.z)
    SetBlipSprite(blipLockdown , 161)
    SetBlipScale(blipLockdown , 1.0)
    SetBlipColour(blipLockdown, 1)
	PulseBlip(blipLockdown)
	Citizen.Wait(Config.KillBlip)
	RemoveBlip(blipLockdown)
end)

-- 3D TEXT

function DrawText3D(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextDropshadow(0, 0, 0, 155)
	SetTextEdge(1, 0, 0, 0, 250)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
end

-- WHEN YOU RESTART THE SCRIPT, THE LOCKDOWN TURNS OFF AND ALL LIGHTS COMES BACK
AddEventHandler("onResourceStop",function(a)if a==GetCurrentResourceName()then SetBlackout(false)end end)
