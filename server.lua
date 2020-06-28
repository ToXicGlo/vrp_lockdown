local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_lockdown")

RegisterServerEvent("ToXicGlo:SendLockdown")
AddEventHandler("ToXicGlo:SendLockdown", function()
	TriggerClientEvent('ToXicGlo:AktiverLockdown', -1)
end)

RegisterServerEvent("ToXicGlo:Lockdown")
AddEventHandler("ToXicGlo:Lockdown", function()
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	if vRP.getInventoryItemAmount({user_id,"laptop_h"}) > 0 then
		TriggerClientEvent('ToXicGlo:Lockdown', -1)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', player, { type = 'error', text = 'You dont have any Hacker Laptop', length = '3000', style = {}})--TriggerClientEvent("pNotify:SendNotification", player,{text = "Y", type = "error", queue = "global", timeout = 4000, layout = "bottomCenter",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
	end
end)

RegisterServerEvent("ToXicGlo:NotifyPolice")
AddEventHandler("ToXicGlo:NotifyPolice", function()
	local source = source
	local xPlayers = vRP.getUsers()
	for i=1, #xPlayers, 1 do
		local xPlayer = vRP.getUserId({xPlayers[i]})
		if vRP.hasPermission({xPlayer,"police.pc"}) then
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'There is someone is trying to Lockdown the City!', length = '10000', style = {}})
			TriggerClientEvent('ToXicGlo:setblip', xPlayers[i])
		end
	end
end)
