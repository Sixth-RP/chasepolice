-- Police Chase Client Script
local isChaseActive = false
local currentWantedLevel = 0
local spawnedCops = {}
local spawnedVehicles = {}
local policeBlips = {}
local helicopterSpawned = false
local lastWantedDecay = 0

-- Utility Functions
local function LoadModel(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
    return modelHash
end

local function GetRandomPoliceVehicle()
    local vehicles = Config.PoliceVehicles[currentWantedLevel] or Config.PoliceVehicles[1]
    return vehicles[math.random(#vehicles)]
end

local function GetRandomPolicePed()
    return Config.PolicePedModels[math.random(#Config.PolicePedModels)]
end

local function CreatePoliceBlip(entity)
    if not Config.ShowPoliceBlips then return nil end
    
    local blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, Config.PoliceBlipSprite)
    SetBlipColour(blip, Config.PoliceBlipColor)
    SetBlipScale(blip, Config.PoliceBlipScale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police")
    EndTextCommandSetBlipName(blip)
    
    return blip
end

local function RemovePoliceBlip(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

-- Spawn Police Unit
local function SpawnPoliceUnit(spawnCoords)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Get spawn position on road near player
    local nodeCoords = spawnCoords or vector3(
        playerCoords.x + math.random(-100, 100),
        playerCoords.y + math.random(-100, 100),
        playerCoords.z
    )
    
    local found, groundZ = GetGroundZFor_3dCoord(nodeCoords.x, nodeCoords.y, nodeCoords.z + 100.0, false)
    if found then
        nodeCoords = vector3(nodeCoords.x, nodeCoords.y, groundZ)
    end
    
    -- Find nearest road
    local retval, roadPos = GetClosestVehicleNode(nodeCoords.x, nodeCoords.y, nodeCoords.z, 1, 3.0, 0)
    if not retval then
        roadPos = nodeCoords
    end
    
    -- Load and spawn vehicle
    local vehicleModel = GetRandomPoliceVehicle()
    local vehicleHash = LoadModel(vehicleModel)
    
    local vehicle = CreateVehicle(vehicleHash, roadPos.x, roadPos.y, roadPos.z, GetEntityHeading(playerPed), true, false)
    SetVehicleSiren(vehicle, true)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(vehicleHash)
    
    -- Load and spawn police ped
    local pedModel = GetRandomPolicePed()
    local pedHash = LoadModel(pedModel)
    
    local cop = CreatePedInsideVehicle(vehicle, 4, pedHash, -1, true, false)
    SetPedArmour(cop, 100)
    GiveWeaponToPed(cop, GetHashKey('WEAPON_PISTOL'), 999, false, true)
    SetPedCombatAttributes(cop, 46, true)
    SetPedCombatAbility(cop, 2)
    SetPedCombatMovement(cop, 2)
    SetModelAsNoLongerNeeded(pedHash)
    
    -- Set cop to chase player
    TaskVehicleChase(cop, playerPed)
    SetPedKeepTask(cop, true)
    
    -- Add to tracking tables
    table.insert(spawnedCops, cop)
    table.insert(spawnedVehicles, vehicle)
    
    -- Create blip
    local blip = CreatePoliceBlip(vehicle)
    if blip then
        table.insert(policeBlips, blip)
    end
    
    return cop, vehicle
end

-- Spawn Police Helicopter
local function SpawnPoliceHelicopter()
    if helicopterSpawned or currentWantedLevel < 4 then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local heliHash = LoadModel(Config.HelicopterModel)
    local heli = CreateVehicle(heliHash, playerCoords.x + 100, playerCoords.y + 100, playerCoords.z + 100, 0.0, true, false)
    SetVehicleEngineOn(heli, true, true, false)
    SetHeliBladesFullSpeed(heli)
    SetModelAsNoLongerNeeded(heliHash)
    
    -- Spawn pilot
    local pilotHash = LoadModel('s_m_y_pilot_01')
    local pilot = CreatePedInsideVehicle(heli, 4, pilotHash, -1, true, false)
    TaskHeliChase(pilot, playerPed, 0.0, 0.0, 50.0)
    SetPedKeepTask(pilot, true)
    SetModelAsNoLongerNeeded(pilotHash)
    
    -- Spawn gunner
    local gunnerHash = LoadModel('s_m_y_swat_01')
    local gunner = CreatePedInsideVehicle(heli, 4, gunnerHash, 1, true, false)
    GiveWeaponToPed(gunner, GetHashKey('WEAPON_CARBINERIFLE'), 999, false, true)
    TaskCombatPed(gunner, playerPed, 0, 16)
    SetPedKeepTask(gunner, true)
    SetModelAsNoLongerNeeded(gunnerHash)
    
    table.insert(spawnedCops, pilot)
    table.insert(spawnedCops, gunner)
    table.insert(spawnedVehicles, heli)
    
    local blip = CreatePoliceBlip(heli)
    if blip then
        table.insert(policeBlips, blip)
    end
    
    helicopterSpawned = true
end

-- Cleanup Functions
local function CleanupCop(index)
    local cop = spawnedCops[index]
    if cop and DoesEntityExist(cop) then
        DeleteEntity(cop)
    end
    table.remove(spawnedCops, index)
end

local function CleanupVehicle(index)
    local vehicle = spawnedVehicles[index]
    if vehicle and DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
    table.remove(spawnedVehicles, index)
end

local function CleanupAllPolice()
    -- Remove all blips
    for _, blip in ipairs(policeBlips) do
        RemovePoliceBlip(blip)
    end
    policeBlips = {}
    
    -- Delete all cops
    for i = #spawnedCops, 1, -1 do
        if spawnedCops[i] and DoesEntityExist(spawnedCops[i]) then
            DeleteEntity(spawnedCops[i])
        end
    end
    spawnedCops = {}
    
    -- Delete all vehicles
    for i = #spawnedVehicles, 1, -1 do
        if spawnedVehicles[i] and DoesEntityExist(spawnedVehicles[i]) then
            DeleteEntity(spawnedVehicles[i])
        end
    end
    spawnedVehicles = {}
    
    helicopterSpawned = false
end

-- Start Chase
local function StartChase(wantedLevel)
    if not Config.EnableScript then return end
    
    currentWantedLevel = math.min(wantedLevel or 1, Config.MaxWantedLevel)
    isChaseActive = true
    lastWantedDecay = GetGameTimer()
    
    TriggerServerEvent('chasepolice:chaseStarted', currentWantedLevel)
    
    -- Spawn initial police units
    local maxCops = Config.MaxCopsPerLevel[currentWantedLevel] or 1
    for i = 1, maxCops do
        Wait(500)
        SpawnPoliceUnit()
    end
    
    -- Check for helicopter
    if Config.UseHelicopter and currentWantedLevel >= 4 then
        SpawnPoliceHelicopter()
    end
    
    ShowNotification("~r~Police Chase Started!~s~ Wanted Level: " .. currentWantedLevel)
end

-- Stop Chase
local function StopChase()
    isChaseActive = false
    currentWantedLevel = 0
    CleanupAllPolice()
    
    TriggerServerEvent('chasepolice:chaseStopped')
    ShowNotification("~g~Police Chase Ended!~s~")
end

-- Set Wanted Level
local function SetWantedLevel(level)
    local newLevel = math.max(0, math.min(level, Config.MaxWantedLevel))
    
    if newLevel == 0 then
        StopChase()
        return
    end
    
    if not isChaseActive then
        StartChase(newLevel)
    else
        local previousLevel = currentWantedLevel
        currentWantedLevel = newLevel
        
        -- Spawn additional cops if wanted level increased
        if newLevel > previousLevel then
            local currentCops = #spawnedCops
            local maxCops = Config.MaxCopsPerLevel[newLevel] or 1
            local copsToSpawn = maxCops - currentCops
            
            for i = 1, copsToSpawn do
                Wait(500)
                SpawnPoliceUnit()
            end
            
            -- Check for helicopter
            if Config.UseHelicopter and newLevel >= 4 and not helicopterSpawned then
                SpawnPoliceHelicopter()
            end
        end
        
        ShowNotification("~y~Wanted Level Changed:~s~ " .. newLevel)
    end
end

-- Notification Helper
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Main Chase Loop
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        
        if isChaseActive and Config.EnableScript then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check and cleanup distant police
            for i = #spawnedCops, 1, -1 do
                local cop = spawnedCops[i]
                if cop and DoesEntityExist(cop) then
                    local copCoords = GetEntityCoords(cop)
                    local distance = #(playerCoords - copCoords)
                    
                    -- Despawn if too far
                    if distance > Config.DespawnDistance then
                        CleanupCop(i)
                    -- Re-task if cop lost target
                    elseif not IsPedInAnyVehicle(cop, false) then
                        TaskCombatPed(cop, playerPed, 0, 16)
                        SetPedKeepTask(cop, true)
                    end
                else
                    table.remove(spawnedCops, i)
                end
            end
            
            -- Spawn new cops if below max
            local maxCops = Config.MaxCopsPerLevel[currentWantedLevel] or 1
            local currentCops = #spawnedCops
            
            if currentCops < maxCops then
                SpawnPoliceUnit()
            end
            
            -- Wanted level decay
            if Config.WantedDecayTime > 0 then
                local currentTime = GetGameTimer()
                if currentTime - lastWantedDecay > Config.WantedDecayTime then
                    lastWantedDecay = currentTime
                    
                    -- Check if player is hidden (not in line of sight of any cop)
                    local isHidden = true
                    for _, cop in ipairs(spawnedCops) do
                        if cop and DoesEntityExist(cop) then
                            if HasEntityClearLosToEntity(cop, playerPed, 17) then
                                isHidden = false
                                break
                            end
                        end
                    end
                    
                    if isHidden then
                        SetWantedLevel(currentWantedLevel - 1)
                    end
                end
            end
        end
    end
end)

-- Key Binding Handler
if Config.UseKeyBindings then
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            
            if IsControlJustPressed(0, Config.ToggleChaseKey) then
                if isChaseActive then
                    StopChase()
                else
                    StartChase(1)
                end
            end
        end
    end)
end

-- Command Handlers
RegisterCommand(Config.Commands.StartChase, function(source, args)
    local level = tonumber(args[1]) or 1
    StartChase(level)
end, false)

RegisterCommand(Config.Commands.StopChase, function()
    StopChase()
end, false)

RegisterCommand(Config.Commands.SetWanted, function(source, args)
    local level = tonumber(args[1]) or 0
    SetWantedLevel(level)
end, false)

-- Server Event Handlers
RegisterNetEvent('chasepolice:startChase')
AddEventHandler('chasepolice:startChase', function(wantedLevel)
    StartChase(wantedLevel)
end)

RegisterNetEvent('chasepolice:stopChase')
AddEventHandler('chasepolice:stopChase', function()
    StopChase()
end)

RegisterNetEvent('chasepolice:setWantedLevel')
AddEventHandler('chasepolice:setWantedLevel', function(level)
    SetWantedLevel(level)
end)

-- Exports
exports('StartChase', StartChase)
exports('StopChase', StopChase)
exports('SetWantedLevel', SetWantedLevel)
exports('GetWantedLevel', function() return currentWantedLevel end)
exports('IsChaseActive', function() return isChaseActive end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupAllPolice()
    end
end)
