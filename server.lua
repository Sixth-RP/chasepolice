-- Police Chase Server Script

-- Player chase data
local playerChaseData = {}

-- Event: Chase Started
RegisterNetEvent('chasepolice:chaseStarted')
AddEventHandler('chasepolice:chaseStarted', function(wantedLevel)
    local source = source
    playerChaseData[source] = {
        wantedLevel = wantedLevel,
        startTime = os.time(),
        active = true
    }
    
    print(('[ChasePolice] Player %s started a chase with wanted level %d'):format(GetPlayerName(source), wantedLevel))
end)

-- Event: Chase Stopped
RegisterNetEvent('chasepolice:chaseStopped')
AddEventHandler('chasepolice:chaseStopped', function()
    local source = source
    
    if playerChaseData[source] then
        local duration = os.time() - playerChaseData[source].startTime
        print(('[ChasePolice] Player %s ended chase after %d seconds'):format(GetPlayerName(source), duration))
    end
    
    playerChaseData[source] = nil
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function(reason)
    local source = source
    playerChaseData[source] = nil
end)

-- Admin Command: Force start chase on player
RegisterCommand('forcechase', function(source, args, rawCommand)
    -- Check if server console or admin
    if source == 0 then
        local targetId = tonumber(args[1])
        local wantedLevel = tonumber(args[2]) or 1
        
        if targetId and GetPlayerName(targetId) then
            TriggerClientEvent('chasepolice:startChase', targetId, wantedLevel)
            print(('[ChasePolice] Started chase on player %s with wanted level %d'):format(GetPlayerName(targetId), wantedLevel))
        else
            print('[ChasePolice] Invalid player ID')
        end
    end
end, true)

-- Admin Command: Force stop chase on player
RegisterCommand('forcestopchase', function(source, args, rawCommand)
    if source == 0 then
        local targetId = tonumber(args[1])
        
        if targetId and GetPlayerName(targetId) then
            TriggerClientEvent('chasepolice:stopChase', targetId)
            print(('[ChasePolice] Stopped chase on player %s'):format(GetPlayerName(targetId)))
        else
            print('[ChasePolice] Invalid player ID')
        end
    end
end, true)

-- Admin Command: Set wanted level on player
RegisterCommand('forcesetwanted', function(source, args, rawCommand)
    if source == 0 then
        local targetId = tonumber(args[1])
        local wantedLevel = tonumber(args[2]) or 0
        
        if targetId and GetPlayerName(targetId) then
            TriggerClientEvent('chasepolice:setWantedLevel', targetId, wantedLevel)
            print(('[ChasePolice] Set wanted level %d on player %s'):format(wantedLevel, GetPlayerName(targetId)))
        else
            print('[ChasePolice] Invalid player ID')
        end
    end
end, true)

-- Get all active chases (for admin purposes)
RegisterCommand('listchases', function(source, args, rawCommand)
    if source == 0 then
        print('[ChasePolice] Active Chases:')
        local count = 0
        for playerId, data in pairs(playerChaseData) do
            if data.active then
                local duration = os.time() - data.startTime
                print(('  - Player %s (ID: %d): Wanted Level %d, Duration: %ds'):format(
                    GetPlayerName(playerId) or 'Unknown',
                    playerId,
                    data.wantedLevel,
                    duration
                ))
                count = count + 1
            end
        end
        if count == 0 then
            print('  No active chases')
        end
    end
end, true)

-- Export functions for other resources
exports('GetPlayerChaseData', function(playerId)
    return playerChaseData[playerId]
end)

exports('IsPlayerInChase', function(playerId)
    return playerChaseData[playerId] and playerChaseData[playerId].active or false
end)

exports('GetAllActiveChases', function()
    local activeChases = {}
    for playerId, data in pairs(playerChaseData) do
        if data.active then
            activeChases[playerId] = data
        end
    end
    return activeChases
end)

-- Server-side trigger for other resources to start a chase
exports('TriggerChase', function(playerId, wantedLevel)
    if GetPlayerName(playerId) then
        TriggerClientEvent('chasepolice:startChase', playerId, wantedLevel or 1)
        return true
    end
    return false
end)

exports('StopChase', function(playerId)
    if GetPlayerName(playerId) then
        TriggerClientEvent('chasepolice:stopChase', playerId)
        return true
    end
    return false
end)

print('[ChasePolice] Server script loaded successfully!')
