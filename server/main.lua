ESX = nil
UnderMiningPlayers = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("master_minerJob:SellItem")
AddEventHandler("master_minerJob:SellItem", function(item)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    local itemCount = xPlayer.getInventoryItem(item).count

	if itemCount > 0 and Config.Items[item] ~= nil then
		xPlayer.removeInventoryItem(item, itemCount)
        xPlayer.addMoney(Config.Items[item] * itemCount)
		TriggerClientEvent("pNotify:SendNotification", _source, { text = 'عالی، ایشاا... چیزای بهتر پیدا کنی!', type = "success", timeout = 500, layout = "bottomCenter"})
	else
		TriggerClientEvent("pNotify:SendNotification", _source, { text = 'شما این ایتم را ندارید.', type = "error", timeout = 500, layout = "bottomCenter"})
	end
end)

RegisterNetEvent("master_minerJob:StartMining")
AddEventHandler("master_minerJob:StartMining", function()
    local _source = source
	if UnderMiningPlayers[_source] ~= nil and UnderMiningPlayers[_source] ~= true then
		TriggerClientEvent("pNotify:SendNotification", _source, { text = 'صبر کن یکم!', type = "error", timeout = 500, layout = "bottomCenter"})
		return
	end
	
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
		UnderMiningPlayers[_source] = true
		local Pickaxe1 = xPlayer.getInventoryItem("Pickaxe1").count
		local Pickaxe2 = xPlayer.getInventoryItem("Pickaxe2").count
		local Pickaxe3 = xPlayer.getInventoryItem("Pickaxe3").count
		local Pickaxe4 = xPlayer.getInventoryItem("Pickaxe4").count
		
		local Rare1 = xPlayer.getInventoryItem("KooheNoor").count
		local Rare2 = xPlayer.getInventoryItem("DaryayeNoor").count
		
		local AxeRank = 0
		local HasRareItem = false
		
		if Rare1 > 0 or Rare2 > 0 then
			HasRareItem = true
		end
		
		if Pickaxe4 > 0 then
			AxeRank = 4
		elseif Pickaxe3 > 0 then
			AxeRank = 3
		elseif Pickaxe2 > 0 then
			AxeRank = 2
		elseif Pickaxe1 > 0 then
			AxeRank = 1
		end
			
		if AxeRank > 0 then
			TriggerClientEvent("master_minerJob:StartMining", _source)
			Citizen.CreateThread(function()
				Citizen.Wait(Config.Miningtime)
				local randomItem = math.random(1,220)
				
				if randomItem >= 0 and randomItem <= 50 then
					xPlayer.addInventoryItem("Iron", 1)
				elseif randomItem >= 51 and  randomItem <= 100 then
					xPlayer.addInventoryItem("Bronze", 1)
				elseif randomItem >= 101 and  randomItem <= 120 and AxeRank >= 1 then
					xPlayer.addInventoryItem("Silver", 1)
				elseif randomItem >= 121 and  randomItem <= 140 and AxeRank >= 1 then
					xPlayer.addInventoryItem("Gold", 1)
				elseif randomItem >= 141 and  randomItem <= 150 and AxeRank >= 2 then
					xPlayer.addInventoryItem("Diamond", 1)
				elseif randomItem >= 151 and  randomItem <= 160 and AxeRank >= 2 then
					xPlayer.addInventoryItem("PureGold", 1)
				elseif randomItem >= 161 and  randomItem <= 166 and AxeRank >= 3 then
					xPlayer.addInventoryItem("BlueEmerald", 1)
				elseif randomItem >= 167 and  randomItem <= 172 and AxeRank >= 3 then
					xPlayer.addInventoryItem("RedRuby", 1)
				elseif randomItem == 210 and AxeRank >= 4 and not Rare1 then
					xPlayer.addInventoryItem("KooheNoor", 1)
				elseif randomItem == 220 and AxeRank >= 4 and not Rare1 then
					xPlayer.addInventoryItem("DaryayeNoor", 1)
				end
				
				TriggerClientEvent("master_minerJob:FinishMining", _source)
				UnderMiningPlayers[_source] = nil
			end)
		else
			UnderMiningPlayers[_source] = nil
			TriggerClientEvent("pNotify:SendNotification", _source, { text = 'با دست خالی میخوای کوه بکنی؟ برو خدا روزیتو جای دیگه حواله کنه!!', type = "error", timeout = 4000, layout = "bottomCenter"})
			return
		end
	end
end)