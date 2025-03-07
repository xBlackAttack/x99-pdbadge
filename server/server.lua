local QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        QBCore = exports[config.coreData.scriptName]:GetCoreObject()
        Citizen.Wait(200)
    end
    print("[QBCore] Loaded")
    QBCore.Functions.CreateUseableItem("pdbadge", function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        local coords = GetEntityCoords(GetPlayerPed(source))
        if Player.Functions.GetItemBySlot(item.slot) ~= nil then
            TriggerClientEvent("x99-pdbadge:open", -1, source, coords, item.info)
        end
    end)
end)

RegisterServerEvent("x99-badge:item:create")
AddEventHandler("x99-badge:item:create", function(name, callsign, rank, photo, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {}
    info.name = name
    info.callsign = callsign
    info.rank = rank
    info.photo = photo
    info.type = type
    Player.Functions.AddItem("pdbadge", 1, false, info)
end)

RegisterServerEvent("x99-badge:SaveMetaData")
AddEventHandler("x99-badge:SaveMetaData", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
    local MetaData = json.decode(result[1].metadata)
    MetaData.phone = MData
    MySQL.update('UPDATE players SET metadata = ? WHERE citizenid = ?',
        {json.encode(MetaData), Player.PlayerData.citizenid})
    Player.Functions.SetMetaData("phone", data)
end)