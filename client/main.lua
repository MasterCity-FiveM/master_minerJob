Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX              = nil
local PlayerData = {}
local isInMarker, isMenuOn, UnderSpawnMining, MarkerSpawn, InMiningMarker, UnderMining = false, false, false, false, false, false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Citizen.CreateThread(function()
    for _, info in pairs(Config.MapBlips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.9)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)

RegisterNetEvent('master_keymap:e')
AddEventHandler('master_keymap:e', function() 
	if isInMarker and not isMenuOn then
		TriggerEvent("masterking32:closeAllUI")
		Citizen.Wait(100)
		SetDisplay(true)
	elseif InMiningMarker and not UnderMining then
		TriggerServerEvent("master_minerJob:StartMining")
	end
end)

Citizen.CreateThread(function()
	while true do
		local coords = GetEntityCoords(PlayerPedId())
		
		Citizen.Wait(0)
		local distance2 = GetDistanceBetweenCoords(coords, -601.15631103516,2092.8804199219,131.34860229492, true)
		DrawMarker(2, -601.15631103516,2092.8804199219,131.34860229492, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 41, 197, 1, 110, 0, 1, 0, 1)
		if distance2 <= 1 then
			if isInMarker == false then
				exports.pNotify:SendNotification({text = 'برای دسترسی به منو لطفا E بزنید.', type = "info", timeout = 3000})
			end
			
			isInMarker = true
			spawnMinings()
		elseif distance2 > 30 then
			isInMarker = false
			if distance2 < 250 then
				spawnMinings()
			else
				MarkerSpawn = false
				InMiningMarker = false
			end
			Citizen.Wait(5000)
		else
			isInMarker = false
		end
	end
end)

RegisterNUICallback("exit", function(data)
	SetDisplay(false)
end)

RegisterNetEvent('masterking32:closeAllUI')
AddEventHandler('masterking32:closeAllUI', function() 
	SetDisplay(false)
end)

function SetDisplay(bool)
	isMenuOn = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
		status = bool,
    })
	
	Citizen.CreateThread(function()
		while isMenuOn do
			Citizen.Wait(0)
			DisableControlAction(0, 1, isMenuOn) -- LookLeftRight
			DisableControlAction(0, 2, isMenuOn) -- LookUpDown
			DisableControlAction(0, 142, isMenuOn) -- MeleeAttackAlternate
			DisableControlAction(0, 18, isMenuOn) -- Enter
			DisableControlAction(0, 322, isMenuOn) -- ESC
			DisableControlAction(0, 106, isMenuOn) -- VehicleMouseControlOverride
		end
	end)
end

RegisterNUICallback("sell", function(data)
	TriggerServerEvent("master_minerJob:SellItem", data.item)
end)

Citizen.CreateThread(function()
	RequestModel(Config.NPCHash)
	while not HasModelLoaded(Config.NPCHash) do
		Wait(1)
	end
	
	meth_dealer_seller = CreatePed(1, Config.NPCHash, -601.15631103516,2092.1804199219,130.34860229492, 60, false, true)
	SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
	SetPedDiesWhenInjured(meth_dealer_seller, false)
	SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
	SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
	SetEntityInvincible(meth_dealer_seller, true)
	FreezeEntityPosition(meth_dealer_seller, true)
	TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);
end)

function spawnMinings()
	if UnderSpawnMining then
		return
	end
	Citizen.CreateThread(function()
		UnderSpawnMining = true
		MarkerSpawn = false
		random_destination = math.random(1, #Config.MiningPoints)
		random_destination2 = math.random(1, #Config.MiningPoints2)
		random_destination3 = math.random(1, #Config.MiningPoints3)
		Citizen.Wait(500)
		MarkerSpawn = true
		FinalSpawn()
		Citizen.Wait(Config.RefreshMarkerTimer)
		UnderSpawnMining = false
		MarkerSpawn = false
		InMiningMarker = false
	end)
end

MarkerPostionData = 1
function FinalSpawn()
	Citizen.CreateThread(function()
		while MarkerSpawn do
			Citizen.Wait(0)
			local pos = GetEntityCoords(GetPlayerPed(-1), false)
			local dpos = Config.MiningPoints[random_destination]	
			local dpos2 = Config.MiningPoints2[random_destination2]	
			local dpos3 = Config.MiningPoints3[random_destination3]	
			local delivery_point_distance = Vdist(dpos.x, dpos.y, dpos.z, pos.x, pos.y, pos.z)
			local delivery_point_distance2 = Vdist(dpos2.x, dpos2.y, dpos2.z, pos.x, pos.y, pos.z)
			local delivery_point_distance3 = Vdist(dpos3.x, dpos3.y, dpos3.z, pos.x, pos.y, pos.z)
			if delivery_point_distance < 100.0 or delivery_point_distance2 < 100.0 or delivery_point_distance3 < 100.0 then
				DrawMarker(1, dpos.x, dpos.y, dpos.z,0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 155, 0, 0, 2, 0, 0, 0, 0)
				DrawMarker(1, dpos2.x, dpos2.y, dpos2.z,0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 155, 0, 0, 2, 0, 0, 0, 0)
				DrawMarker(1, dpos3.x, dpos3.y, dpos3.z,0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 155, 0, 0, 2, 0, 0, 0, 0)
				if delivery_point_distance < 1.5 or delivery_point_distance2 < 1.5 or delivery_point_distance3 < 1.5 then
					if InMiningMarker == false then
						exports.pNotify:SendNotification({text = 'برای استخراج لطفا E بزنید.', type = "info", timeout = 3000})
					end
					
					InMiningMarker = true
					MarkerPostionData = dpos
					
					if delivery_point_distance2 < delivery_point_distance then
						MarkerPostionData = dpos2
					end
					
					if delivery_point_distance3 < delivery_point_distance2 then
						MarkerPostionData = dpos3
					end
				else
					InMiningMarker = false
				end
			else 
				InMiningMarker = false
			end
		end
	end)
end
local pickaxe = nil
RegisterNetEvent('master_minerJob:StartMining')
AddEventHandler('master_minerJob:StartMining', function()
	if UnderMining == true then
		return
	end
	
	UnderMining = true
	Citizen.CreateThread(function()
        while UnderMining do
            Citizen.Wait(1)
			DisableAllControlActions(0)
			DisableControlAction(0, Keys['F2'],true)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['N'], true)
			EnableControlAction(0, Keys['F10'], true)
			EnableControlAction(0, 1, true)
			EnableControlAction(0, 2, true)
			EnableControlAction(0, Keys['G'], true)
        end
    end)
	
    Citizen.CreateThread(function()
		local player = PlayerPedId()	
		SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
		if pickaxe ~= nil then
			DetachEntity(pickaxe, 1, true)
			DeleteEntity(pickaxe)
			DeleteObject(pickaxe)
		end
		
		pickaxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
		AttachEntityToEntity(pickaxe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)
		
        while UnderMining do
            Citizen.Wait(1)
			local ped = PlayerPedId()	
			RequestAnimDict("amb@world_human_hammering@male@base")
			Citizen.Wait(100)
			TaskPlayAnim((ped), 'amb@world_human_hammering@male@base', 'base', 12.0, 12.0, -1, 80, 0, 0, 0, 0)
			SetEntityHeading(ped, MarkerPostionData.h)
			Citizen.Wait(2500)
        end
		
		DetachEntity(pickaxe, 1, true)
		DeleteEntity(pickaxe)
		DeleteObject(pickaxe)
		pickaxe = nil
    end)
end)

RegisterNetEvent('master_minerJob:FinishMining')
AddEventHandler('master_minerJob:FinishMining', function()
	UnderMining = false
end)
