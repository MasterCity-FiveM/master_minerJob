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
				else
					InMiningMarker = false
				end
			else 
				InMiningMarker = false
			end
		end
	end)
end

RegisterNetEvent('master_minerJob:StartMining')
AddEventHandler('master_minerJob:StartMining', function()
	UnderMining = true
    Citizen.CreateThread(function()
		local player = PlayerPedId()	
		SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
		local pickaxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
		AttachEntityToEntity(pickaxe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)
		
        while UnderMining do
            Citizen.Wait(1)
			local ped = PlayerPedId()	
			RequestAnimDict("amb@world_human_hammering@male@base")
			Citizen.Wait(100)
			TaskPlayAnim((ped), 'amb@world_human_hammering@male@base', 'base', 12.0, 12.0, -1, 80, 0, 0, 0, 0)
			SetEntityHeading(ped, 270.0)
			Citizen.Wait(2500)
        end
		
		DetachEntity(pickaxe, 1, true)
		DeleteEntity(pickaxe)
		DeleteObject(pickaxe)
    end)
end)

RegisterNetEvent('master_minerJob:FinishMining')
AddEventHandler('master_minerJob:FinishMining', function()
	UnderMining = false
end)
