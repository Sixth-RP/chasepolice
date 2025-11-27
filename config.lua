Config = {}

-- General Settings
Config.EnableScript = true

-- Wanted Level Settings
Config.MaxWantedLevel = 5
Config.WantedDecayTime = 60000 -- Time in ms before wanted level decreases by 1

-- Police Spawn Settings
Config.MaxCopsPerLevel = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 6
}

Config.SpawnDistance = 150.0 -- Distance from player to spawn police
Config.DespawnDistance = 300.0 -- Distance from player to despawn police

-- Police Vehicle Models (by wanted level)
Config.PoliceVehicles = {
    [1] = {'police'},
    [2] = {'police', 'police2'},
    [3] = {'police', 'police2', 'police3'},
    [4] = {'police', 'police2', 'police3', 'policeb'},
    [5] = {'police', 'police2', 'police3', 'policeb', 'fbi', 'fbi2'}
}

-- Police Ped Models
Config.PolicePedModels = {
    's_m_y_cop_01',
    's_f_y_cop_01',
    's_m_y_hwaycop_01'
}

-- Chase Behavior Settings
Config.ChaseAggressiveness = 1.0 -- 0.0 to 1.0, higher = more aggressive
Config.UseHelicopter = true -- Spawn police helicopter at wanted level 4+
Config.HelicopterModel = 'polmav'

-- Blip Settings
Config.ShowPoliceBlips = true
Config.PoliceBlipSprite = 60
Config.PoliceBlipColor = 3
Config.PoliceBlipScale = 0.8

-- Commands
Config.Commands = {
    StartChase = 'startchase',
    StopChase = 'stopchase',
    SetWanted = 'setwanted'
}

-- Key Bindings (set to false to disable)
Config.UseKeyBindings = true
Config.ToggleChaseKey = 168 -- F7
