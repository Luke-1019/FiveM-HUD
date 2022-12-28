local ESX = nil
local MPH = false
local uiopen = false

local Keys = {
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

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	TriggerEvent('esx:setMoneyDisplay', 0.0)
	ESX.UI.HUD.SetDisplay(0.0)

	PlayerData = ESX.GetPlayerData()

	StartShowHudThread()
end)

if MPH then
	factor = 3.6
else
	factor = 3.6 
end

RegisterNetEvent('announcement')
AddEventHandler('announcement', function(color, title, message)
    SendNUIMessage({
        type = "announcement",
        color = "#FFE000",
		title = title,
        message = message,
    })
	PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	
	for i = 1, 1000, 1 do 
		Citizen.Wait(16)
		SendNUIMessage({
			count = i
		})
	end
end)

RegisterNetEvent('notifications')
AddEventHandler('notifications', function(color, title, message)
    SendNUIMessage({
        type = "notifications",
        color = "#FFE000",
		title = title,
        message = message,
    })
	PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)

	for i = 1, 1000, 1 do 
		Citizen.Wait(8)
		SendNUIMessage({
			count_2 = i
		})
	end
	i = 0
end)

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		
		if(IsPedInAnyVehicle(ped)) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			vehicleisin = vehicle
			if vehicle then
				carSpeed = math.ceil(GetEntitySpeed(vehicle) * factor)
				carRPM = GetVehicleCurrentRpm(vehicle)
				local speed = GetVehicleDashboardSpeed(vehicle)
				local vehicleVal,vehicleLights,vehicleHighlights = GetVehicleLightsState(vehicle)
				local engine = GetIsVehicleEngineRunning(vehicle)
				local door = GetVehicleDoorLockStatus(vehicle)
				local fuel = GetVehicleFuelLevel(vehicle)

				if vehicleLights == 1 then
					SendNUIMessage({
						light = true,
					})
				else
					SendNUIMessage({
						light = false,
					})
				end

				if engine then
					SendNUIMessage({
						engine = true,
					})
				else
					SendNUIMessage({
						engine = false,
					})
				end

				if door == 2 then
					SendNUIMessage({
						door = true,
					})
				else
					SendNUIMessage({
						door = false,
					})
				end

				local speed_real = 479.0 - speed * 8
				local fuel_real = 2 + fuel / 100

				SendNUIMessage({
					type = 'active',
					speed = carSpeed,
					light = lightstate,
					hud = speed_real,
					fuel = fuel_real
				})
				Citizen.Wait(50)
				if uiopen == false then
					uiopen = true
					
					SendNUIMessage({
						type = 'showui',
					})
				end
			end
		else
			SendNUIMessage({
				type = 'deactive',
			})
			uiopen = false
		end

		Citizen.Wait(10)
	end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	if account.name == "money" then
	    SendNUIMessage({action = "setMoney", money = account.money})
		SendNUIMessage({bank = account.bank})
	end

	if account.name == "black_money" then
		if account.money > 0 then
		    SendNUIMessage({action = "setBlackMoney", black = account.money})
		    SendNUIMessage({action = "muted", muted = micmuted})
		else
		    SendNUIMessage({action = "hideBlackMoney"})
		end
	end
end)

function StartShowHudThread()
	while true do
		Citizen.Wait(1000)
		ESX.TriggerServerCallback('hud:getData', function(balance)
			SendNUIMessage({
				action = "setMoney",
				bank = balance,
				id =  GetPlayerServerId(PlayerId()),
				players = GetNumberOfPlayers(),
				money = ESX.GetPlayerData().money,
				job_label = ESX.GetPlayerData().job.label
			})
		end)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		local ped = PlayerPedId()
		local hp_1 = GetEntityHealth(ped)
		local vest_1 = GetPedArmour(ped)
		local real_hp =  hp_1 - 12.0
		local real_vest = vest_1 + 94.0

		if health ~= prevHealth then
			SetEntityHealth(playerPed,  health)
		end

		if hp_1 <= 0 then
			real_hp = 94.0
		end
		if vest_1 <= 0 then
			vest_hp = 94.0
		end
		SendNUIMessage({
			hp = real_hp,
			vest = real_vest 
		})
	end
end)

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(100)

		TriggerEvent('esx_status:getStatus', 'thirst', function(status)
			local thristi = status.val / 10000 + 94.0
	
			if status.val <= 0 then
				thristi = 94.0
			end
			SendNUIMessage({
				status_2 = Config.HungerandThirst,
				thirst = thristi
			})
		end)

		TriggerEvent('esx_status:getStatus', 'hunger', function(status)
			local hungry = status.val / 10000 + 94.0

			if status.val <= 0 then
				hungry = 94.0
			end
			SendNUIMessage({
				hunger = hungry
			})
		end)
	end
	
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		local player = GetPlayerPed(-1)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		if IsPedArmed(player, 7) then
			local weapon = GetSelectedPedWeapon(player)
			local ammoTotal = GetAmmoInPedWeapon(player,weapon)
			local weapon_1 = GetWeapontypeModel(weapon)

			if weapon == 453432689 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Pistole",
					hash = "weapon_pistol",
					bullets = ammoTotal
				})
			elseif weapon == 3219281620 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Pistole MK2",
					hash = "weapon_pistol_mk2",
					bullets = ammoTotal
				})
			elseif weapon == 1593441988 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Kampfpistole",
					hash = "weapon_combatpistol",
					bullets = ammoTotal
				})
			elseif weapon == -1716589765 then
				SendNUIMessage({
					status = "weapon",
					weapon = "50. Pistole",
					hash = "weapon_pistol50",
					bullets = ammoTotal
				})
			elseif weapon == -1076751822 then
				SendNUIMessage({
					status = "weapon",
					weapon = "SNS Pistole",
					hash = "weapon_snspistol",
					bullets = ammoTotal
				})
			elseif weapon == -771403250 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Schwere Pistole",
					hash = "weapon_heavypistol",
					bullets = ammoTotal
				})
			elseif weapon == 137902532 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Vintage Pistole",
					hash = "weapon_vintagepistol",
					bullets = ammoTotal
				})
			elseif weapon == -598887786 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Marksman Pistole",
					hash = "weapon_marksmanpistol",
					bullets = ammoTotal
				})
			elseif weapon == -1045183535 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Revolver",
					hash = "weapon_revolver",
					bullets = ammoTotal
				})
			elseif weapon == 584646201 then
				SendNUIMessage({
					status = "weapon",
					weapon = "AP Pistole",
					hash = "weapon_appistol",
					bullets = ammoTotal
				})
			elseif weapon == 911657153 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Taser",
					hash = "weapon_stungun",
					bullets = ammoTotal
				})
			elseif weapon == 1198879012 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Leuchtpistole",
					hash = "weapon_flaregun",
					bullets = ammoTotal
				})
			elseif weapon == 324215364 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Mikro SMG",
					hash = "weapon_microsmg",
					bullets = ammoTotal
				})
			elseif weapon == -619010992 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Maschinenpistole",
					hash = "weapon_machinepistol",
					bullets = ammoTotal
				})
			elseif weapon == 736523883 then
				SendNUIMessage({
					status = "weapon",
					weapon = "SMG",
					hash = "weapon_smg",
					bullets = ammoTotal
				})
			elseif weapon == 2024373456 then
				SendNUIMessage({
					status = "weapon",
					weapon = "SMG MK2",
					hash = "weapon_smg_mk2",
					bullets = ammoTotal
				})
			elseif weapon == -270015777 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Sturmgewehr",
					hash = "weapon_assaultsmg",
					bullets = ammoTotal
				})
			elseif weapon == 171789620 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Kampf PDW",
					hash = "weapon_combatpdw",
					bullets = ammoTotal
				})
			elseif weapon == -1660422300 then
				SendNUIMessage({
					status = "weapon",
					weapon = "MG",
					hash = "weapon_mg",
					bullets = ammoTotal
				})
			elseif weapon == 2144741730 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Combat MG",
					hash = "weapon_combatmg",
					bullets = ammoTotal
				})
			elseif weapon == 3686625920 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Combat MG MK2",
					hash = "weapon_combatmg_mk2",
					bullets = ammoTotal
				})
			elseif weapon == 1627465347 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Gusenberg",
					hash = "weapon_gusenberg",
					bullets = ammoTotal
				})
			elseif weapon == -1121678507 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Mini SMG",
					hash = "weapon_minismg",
					bullets = ammoTotal
				})
			elseif weapon == -1074790547 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Sturmgewehr",
					hash = "weapon_assaultrifle",
					bullets = ammoTotal
				})
			elseif weapon == 961495388 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Sturmgewehr Mk2",
					hash = "weapon_assaultrifle_mk2",
					bullets = ammoTotal
				})
			elseif weapon == -2084633992 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Karabinergewehr",
					hash = "weapon_carbinerifle",
					bullets = ammoTotal
				})
			elseif weapon == 4208062921 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Karabinergewehr Mk2",
					hash = "weapon_carbinerifle_mk2",
					bullets = ammoTotal
				})
			elseif weapon == -1357824103 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Advanced Gewehr",
					hash = "weapon_advancedrifle",
					bullets = ammoTotal
				})
			elseif weapon == -1063057011 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Spezial Karabiner",
					hash = "weapon_specialcarbine",
					bullets = ammoTotal
				})
			elseif weapon == 2132975508 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Bullpup Gewehr",
					hash = "weapon_bullpuprifle",
					bullets = ammoTotal
				})
			elseif weapon == 1649403952 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Kompakt Gewehr",
					hash = "weapon_compactrifle",
					bullets = ammoTotal
				})
			elseif weapon == 100416529 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Scharfschützengewehr",
					hash = "weapon_sniperrifle",
					bullets = ammoTotal
				})
			elseif weapon == 205991906 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Schwere Sniper",
					hash = "weapon_heavysniper",
					bullets = ammoTotal
				})
			elseif weapon == 177293209 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Schwere Sniper Mk2",
					hash = "weapon_heavysniper_mk2",
					bullets = ammoTotal
				})
			elseif weapon == -952879014 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Marksman Gewehr",
					hash = "weapon_marksmanrifle",
					bullets = ammoTotal
				})
			elseif weapon == 487013001 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Schrotflinte",
					hash = "weapon_pumpshotgun",
					bullets = ammoTotal
				})
			elseif weapon == 2017895192 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Abgesägte Schrotflinte",
					hash = "weapon_sawnoffshotgun",
					bullets = ammoTotal
				})
			elseif weapon == -1654528753 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Bullpup Schrotflinte",
					hash = "weapon_bullpupshotgun",
					bullets = ammoTotal
				})
			elseif weapon == -494615257 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Kampf Schrotflinte",
					hash = "weapon_assaultshotgun",
					bullets = ammoTotal
				})
			elseif weapon == -1466123874 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Muskete",
					hash = "weapon_musket",
					bullets = ammoTotal
				})
			elseif weapon == 984333226 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Schwere Schrotflinte",
					hash = "weapon_heavyshotgun",
					bullets = ammoTotal
				})
			elseif weapon == -275439685 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Doppelläufige Schrotflinte",
					hash = "weapon_doublebarrelshotgun",
					bullets = ammoTotal
				})
			elseif weapon == 317205821 then
				SendNUIMessage({
					status = "weapon",
					weapon = "Automatische Schrotflinte",
					hash = "weapon_autoshotgun",
					bullets = ammoTotal
				})
			else
				SendNUIMessage({
					status = "weapon-2"
				})
			end
		else
			SendNUIMessage({
				status = "weapon-2"
			})
		end
	end
end)