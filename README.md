# Chase Police - FiveM Script

A comprehensive police chase system for FiveM servers. AI police officers will pursue wanted players with escalating intensity based on wanted level.

## Features

- **Dynamic Wanted Levels (1-5)**: Each level increases police response intensity
- **AI Police Units**: Spawns police cars with armed officers that chase players
- **Police Helicopters**: At wanted level 4+, helicopters join the pursuit
- **Configurable Settings**: Customize spawn rates, vehicle types, and chase behavior
- **Wanted Level Decay**: Evade police to lower your wanted level
- **Map Blips**: Optional police blips on minimap
- **Export Functions**: Easily integrate with other resources
- **Admin Commands**: Server-side controls for managing chases

## Installation

1. Download or clone this repository
2. Place the `chasepolice` folder in your server's `resources` directory
3. Add `ensure chasepolice` to your `server.cfg`
4. Restart your server or start the resource

## Usage

### Player Commands

| Command | Description |
|---------|-------------|
| `/startchase [level]` | Start a police chase (default level 1) |
| `/stopchase` | Stop the current chase |
| `/setwanted [level]` | Set your wanted level (0-5) |

### Key Bindings

| Key | Action |
|-----|--------|
| F7 | Toggle chase on/off |

### Admin Commands (Server Console Only)

| Command | Description |
|---------|-------------|
| `forcechase [playerID] [level]` | Force start chase on a player |
| `forcestopchase [playerID]` | Force stop chase on a player |
| `forcesetwanted [playerID] [level]` | Set wanted level on a player |
| `listchases` | List all active chases |

## Configuration

Edit `config.lua` to customize the script:

```lua
Config.EnableScript = true              -- Enable/disable the script
Config.MaxWantedLevel = 5               -- Maximum wanted level
Config.WantedDecayTime = 60000          -- Time before wanted decreases (ms)
Config.SpawnDistance = 150.0            -- Police spawn distance
Config.DespawnDistance = 300.0          -- Police despawn distance
Config.UseHelicopter = true             -- Enable helicopters at level 4+
Config.ShowPoliceBlips = true           -- Show police on minimap
```

### Police Units Per Wanted Level

| Level | Ground Units | Helicopter |
|-------|--------------|------------|
| 1 | 1 | No |
| 2 | 2 | No |
| 3 | 3 | No |
| 4 | 4 | Yes |
| 5 | 6 | Yes |

## Exports (For Other Resources)

### Client-Side Exports

```lua
-- Start a chase with specified wanted level
exports['chasepolice']:StartChase(wantedLevel)

-- Stop the current chase
exports['chasepolice']:StopChase()

-- Set wanted level (0 stops chase)
exports['chasepolice']:SetWantedLevel(level)

-- Get current wanted level
local level = exports['chasepolice']:GetWantedLevel()

-- Check if chase is active
local active = exports['chasepolice']:IsChaseActive()
```

### Server-Side Exports

```lua
-- Get player's chase data
local data = exports['chasepolice']:GetPlayerChaseData(playerId)

-- Check if player is in a chase
local inChase = exports['chasepolice']:IsPlayerInChase(playerId)

-- Get all active chases
local chases = exports['chasepolice']:GetAllActiveChases()

-- Trigger a chase on a player
exports['chasepolice']:TriggerChase(playerId, wantedLevel)

-- Stop a player's chase
exports['chasepolice']:StopChase(playerId)
```

## Events

### Client Events (Trigger from Server)

```lua
-- Start chase on client
TriggerClientEvent('chasepolice:startChase', playerId, wantedLevel)

-- Stop chase on client
TriggerClientEvent('chasepolice:stopChase', playerId)

-- Set wanted level on client
TriggerClientEvent('chasepolice:setWantedLevel', playerId, level)
```

### Server Events (Trigger from Client)

```lua
-- Notify server chase started
TriggerServerEvent('chasepolice:chaseStarted', wantedLevel)

-- Notify server chase stopped
TriggerServerEvent('chasepolice:chaseStopped')
```

## Dependencies

None - this is a standalone resource.

## License

This project is open source. Feel free to modify and use it on your server.

## Support

For issues or feature requests, please open an issue on GitHub.
