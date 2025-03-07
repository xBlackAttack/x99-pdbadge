QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        QBCore = exports[config.coreData.scriptName]:GetCoreObject()
        Citizen.Wait(200)
        TriggerEvent(config.coreData.eventPrefix ..':GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
    
    while QBCore.Functions.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    SharedItems = QBCore.Shared.Items
end)

Citizen.CreateThread(function()
    while config.coreData.eventPrefix == nil do 
        Citizen.Wait(0)
        print("waiting to config settings")
    end
    QBCore = exports[config.coreData.scriptName]:GetCoreObject()
end)

local plate_net = nil
local platespawned = nil
local plateModel = "x99_policebadge_bcso"
local plateModel2 = "x99_policebadge_doa"
local plateModel3 = "x99_policebadge_lspd"
local plateModel4 = "x99_policebadge_park"
local plateModel5 = "x99_policebadge_sasp"
local animDict = "paper_1_rcm_alt1-9"
local animName = "player_one_dual-9"

PlayerLoaded = false

Citizen.CreateThread(function()
    -- while config.coreData.eventPrefix == nil do 
    --     Citizen.Wait(0)
    --     print("waiting to config settings")
    -- end
    RegisterNetEvent(config.coreData.eventPrefix..':Client:OnPlayerLoaded', function()
        PlayerLoaded = true
        QBCore.Functions.GetPlayerData(function(data)
            PlayerData = data
        end)
    end)
    
    RegisterNetEvent(config.coreData.eventPrefix..':Client:OnPlayerUnload', function()
        PlayerLoaded = false
        PlayerData = nil
    end)
    
    RegisterNetEvent(config.coreData.eventPrefix..':Client:OnJobUpdate', function(JobInfo)
        QBCore.Functions.GetPlayerData(function(PlayerData)
            PlayerData = PlayerData
        end)
    end)
    
end)


CreateThread(function()
    while config.badgecommand == nil do
        print("config loading...")
        Citizen.Wait(0)
    end
    print("config loaded!")
    local commandName = config.badgecommand
    RegisterCommand(commandName, function()
        if config.usecreatecommand then 
            PlayerData = QBCore.Functions.GetPlayerData()
            Citizen.Wait(150)
            for k, v in pairs(config.authorizedJobs) do 
                if PlayerData.job.name == v then 
                    TriggerEvent("x99_badge:create")
                -- else 
                    -- QBCore.Functions.Notify(config.Notifys.permissionerror, "error", 5000)
                end
            end
        end
    end)   
    local photocommand = config.photocommand
    RegisterCommand(photocommand, function()
        if config.usephotocommand then 
            PlayerData = QBCore.Functions.GetPlayerData()
            Citizen.Wait(150)
            for k, v in pairs(config.authorizedJobs) do 
                if PlayerData.job.name == v then 
                    TriggerEvent("x99_badge:changeurl")
                -- else 
                    -- QBCore.Functions.Notify(config.Notifys.permissionerror, "error", 5000)
                end
            end
        end
    end)   
    if config.reloadcmmnd then 
        local reloadDataCommandName = config.refreshcmnnd
        RegisterCommand(reloadDataCommandName, function()
            TriggerEvent(""..config.coreData.eventPrefix..":Client:OnPlayerLoaded")
            QBCore.Functions.Notify(config.Notifys.reloadPdData, "success", 5000)
        end)
    end
end)


RegisterNetEvent("x99_badge:create")
AddEventHandler("x99_badge:create", function()
    PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname.. " " ..PlayerData.charinfo.lastname
    local callsign = PlayerData.metadata.callsign
    local rank = PlayerData.job.grade.name 
    local photo = PlayerData.metadata.phone.profilepicture
    local grade = PlayerData.job.grade.level
    -- print(callsign)

    local type = 'police'
    local typeNumber = PlayerData.job.name
    local found = false
    for k, v in pairs(config.authorizedJobs) do 
        if v == PlayerData.job.name then 
            found = true
            typeNumber = k
            -- print(typeNumber)
        end
    end
    type = config.grades[typeNumber][grade]
    -- print(json.encode(type))
    -- if grade >= 8 and grade <= 15 then 
    --     type = 'sheriff'
    -- elseif grade >= 16 and grade <= 17 then
    --     type = 'trooper'
    -- elseif grade >= 18 and grade <= 21 then
    --     type = 'ranger'
    -- end
    -- print(type)
    if callsign == nil then 
        QBCore.Functions.Notify(config.Notifys.nocallsign, "error", 5000)
    else 
        TriggerServerEvent("x99-badge:item:create", name, callsign, rank, photo, type)
    end
end)

RegisterNetEvent("x99-pdbadge:open")
AddEventHandler("x99-pdbadge:open", function(sourceId, sender_coords, data)
    if PlayerData.job.name ~= nil then 
        PlayerLoaded = true
    end
    if PlayerLoaded then
        if platespawned ~= nil then
            DeleteEntity(platespawned)
        end
        if plate_net ~= nil then 
            DeleteEntity(plate_net)
        end
        local mypos = GetEntityCoords(PlayerPedId(), false)
        if (GetDistanceBetweenCoords(mypos.x, mypos.y, mypos.z, sender_coords.x, sender_coords.y, sender_coords.z, true) < config.badgedistance) then
            SendNUIMessage({
                action = "badgeOpen",
                name = data.name,
                callsign = data.callsign,
                rank = data.rank,
                photo = data.photo,
                type = data.type
            })
            -- print(data.type)
            startAnim(GetPlayerPed(GetPlayerFromServerId(sourceId)), data.type)
            badge = true
            while badge do
                Citizen.Wait(1)
                if IsControlJustPressed(1, config.closeKey) then
                    DeleteEntity(plate_net)
                    DeleteEntity(NetToObj(plate_net))
                    badge = false
                    SendNUIMessage({
                        action = "badgeClose"
                    })
                    ClearPedSecondaryTask(PlayerPedId())
                    DeleteEntity(platespawned)
                    DetachEntity(NetToObj(plate_net), 1, 1)
                    DeleteEntity(NetToObj(plate_net))
                    plate_net = nil 
                    platespawned = nil
                end
            end
        end
    end
end)

function startAnim(playerPed, type)
    -- local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        local model = GetHashKey(getBadgeType(type))
        RequestModel(model)
        while not HasModelLoaded(model) do
            print("Waiting for badge model to load")
            Citizen.Wait(1)
        end
        ClearPedSecondaryTask(playerPed)
        RequestAnimDict("paper_1_rcm_alt1-7")
        while not HasAnimDictLoaded("paper_1_rcm_alt1-7") do
            Citizen.Wait(1)
            print("Waiting for badge anim to load")
        end 
        local plyCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, -5.0)
        TaskPlayAnim(playerPed, "paper_1_rcm_alt1-7", "player_one_dual-7", 3.0, 3.0, -1, 62, 0, 0, 0, 0)
        Citizen.Wait(1300)
        platespawned = CreateObject(model, plyCoords.x, plyCoords.y, plyCoords.z, 0, 0, 0)
        AttachEntityToEntity(platespawned, playerPed, GetPedBoneIndex(playerPed, 28422), 0.12, 0.088, 0.001, 270.0, 180.0, 300.0, 1, 1, 0, 1, 0, 1)
        local netid = ObjToNet(platespawned)
        plate_net = netid
        SetNetworkIdExistsOnAllMachines(netid, true)
        SetNetworkIdCanMigrate(netid, false)
    end
end

function getBadgeType(type)
    local model = "x99_policebadge_bcso"
    if type == "police" then
        model = "x99_policebadge_lspd"
    elseif type == "sheriff" then 
        model = "x99_policebadge_bcso"
    elseif type == "trooper" then 
        model = "x99_policebadge_sasp"
    elseif type == "ranger" then 
        model = "x99_policebadge_park"
    end
    return model

end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 0 )
    end
end

function tprint(t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end 

RegisterNetEvent("x99_badge:changeurl")
AddEventHandler("x99_badge:changeurl", function()
    local myInputs = {}
    table.insert(myInputs, {text = "url", name = "url1", type = "text", isRequired = false})
    local dialog = exports['qb-input']:ShowInput({
        header = "PD Badge",
        submitText = "Change Photo",
        inputs = myInputs
    })
    PlayerData = QBCore.Functions.GetPlayerData()
    -- print(json.encode(dialog["url1"]))
    PlayerData.metadata.phonedata.profilepicture = dialog["url1"]
    TriggerServerEvent("x99-badge:SaveMetaData", PlayerData.metadata.phonedata)
    -- print(json.encode(PlayerData.metadata.phonedata, {indent = true}))
end)