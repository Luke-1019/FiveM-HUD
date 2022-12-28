ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('hud:getData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local balance = xPlayer.getAccount('bank').money

    cb(balance)
end)

RegisterCommand("announce", function(source, args, rawCommand)
    local arg = rawCommand
    local transform = arg:gsub("announce ", "")

    TriggerClientEvent('announcement', -1, "#4cff38", "Announcement", transform)
end, true)

RegisterCommand("test", function(source, args, rawCommand)
    local arg = rawCommand
    local transform = arg:gsub("test ", "")

    TriggerClientEvent('notifications', source, "#4cff38", "Notification", transform)
end, true)