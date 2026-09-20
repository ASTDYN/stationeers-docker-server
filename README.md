# Stationeers Dedicated Server — Docker

Runs a Stationeers dedicated server in Docker. The server installs/updates automatically on each startup.

Mount `/steamcmd/stationeers` on the host for data persistence.

---

## Quick start

```yaml
services:
  stationeers:
    image: didstopia/stationeers-server:latest
    ports:
      - "27016:27016/udp"
      - "27015:27015/udp"
      - "27500:27500/tcp"
      - "27500:27500/udp"
    volumes:
      - ./stationeers-data:/steamcmd/stationeers
    environment:
      STATIONEERS_SERVER_NAME: "My Stationeers Server"
      STATIONEERS_SERVER_WORLD_ID: "Mars"
      STATIONEERS_SERVER_WORLD_NAME: "docker"
      STATIONEERS_SERVER_PASSWORD: ""
      STATIONEERS_SERVER_ADMIN_PASSWORD: ""
```

---

## Environment variables

All variables and their defaults are listed below.

### World settings

| Variable | Default | Description |
|---|---|---|
| `STATIONEERS_SERVER_WORLD_NAME` | `docker` | Save name used for world files on disk |
| `STATIONEERS_SERVER_WORLD_ID` | `Mars` | World type to load — see [World types](#world-types) below |
| `STATIONEERS_SERVER_DIFFICULTY` | `Normal` | Difficulty — `Easy`, `Normal`, `Hard`, or `Stationeer` |
| `STATIONEERS_SERVER_START_CONDITION` | `DefaultStartCommunity` | Starting loadout for new players — see [Start conditions](#start-conditions) |
| `STATIONEERS_SERVER_START_LOCATION` | `MarsSpawnCanyonOverlook` | Spawn location — see [Start locations](#start-locations) |

### Network settings

| Variable | Default | Description |
|---|---|---|
| `STATIONEERS_SERVER_GAME_PORT` | `27016` | Primary game port (UDP) |
| `STATIONEERS_SERVER_UPDATE_PORT` | `27015` | Steam query port (UDP) |
| `STATIONEERS_SERVER_UPNP_ENABLED` | `false` | Enable UPnP port mapping |
| `STATIONEERS_SERVER_STEAM_P2P` | `false` | Enable Steam P2P networking |
| `STATIONEERS_START_LOCAL_HOST` | `true` | Allow connections from localhost |

### Server settings

| Variable | Default | Description |
|---|---|---|
| `STATIONEERS_SERVER_NAME` | `A Docker Server by Astral Dynamics` | Name shown in the server browser |
| `STATIONEERS_SERVER_VISIBLE` | `true` | List the server publicly in the server browser |
| `STATIONEERS_SERVER_PASSWORD` | *(empty)* | Password required to join — leave empty for a public server |
| `STATIONEERS_SERVER_ADMIN_PASSWORD` | *(empty)* | RCON / admin authentication secret |
| `STATIONEERS_SERVER_MAX_PLAYERS` | `20` | Maximum concurrent players (1–30) |

### Save & performance

| Variable | Default | Description |
|---|---|---|
| `STATIONEERS_SERVER_AUTO_SAVE` | `true` | Enable automatic world saving |
| `STATIONEERS_SERVER_SAVE_INTERVAL` | `300` | Autosave interval in seconds |
| `STATIONEERS_SERVER_AUTO_PAUSE` | `true` | Pause the simulation when no players are online |

### Advanced

| Variable | Default | Description |
|---|---|---|
| `STATIONEERS_SERVER_STARTUP_ARGUMENTS` | `-autostart -nographics -batchmode` | Extra arguments appended to the server launch command |
| `STATIONEERS_SERVER_LOGS` | *(unset)* | Path inside the container to write the server log file |
| `PUID` | `1000` | UID the server process runs as |
| `PGID` | `1000` | GID the server process runs as |

---

## World types

Set `STATIONEERS_SERVER_WORLD_ID` to one of the following values.

| WorldID | Environment | Suggested difficulty |
|---|---|---|
| `Mars` | Thin CO₂ atmosphere, dust storms, moderate temperatures | Beginner |
| `Moon` | Vacuum, extreme temperature swings between day/night | Beginner |
| `Europa` | Icy moon, extreme cold, thin O₂/N₂ atmosphere | Intermediate |
| `Europa2` | Alternative Europa variant | Intermediate |
| `Mimas` | Barren Saturn moon, no atmosphere, similar to Moon | Intermediate |
| `Loulan` | Dense alien atmosphere, high gravity (0.8g), breathable air | Intermediate |
| `Vulcan` | Volcanic, extreme heat, toxic gases | Advanced |
| `Vulcan2` | Alternative Vulcan variant | Advanced |
| `Venus` | Extreme heat and pressure | Advanced |
| `Space` | Open space, no gravity, no atmosphere | Advanced |

---

## Start conditions

Set `STATIONEERS_SERVER_START_CONDITION` to one of the following values.

| Value | Description |
|---|---|
| `DefaultStart` | Standard starting loadout |
| `DefaultStartCommunity` | Standard loadout, community spawn rules *(default)* |
| `BrutalCommunity` | Minimal resources, community spawn rules |
| `Brutal` | Minimal starting resources, hardest conditions |

---

## Start locations

Set `STATIONEERS_SERVER_START_LOCATION` to a spawn point matching your chosen `STATIONEERS_SERVER_WORLD_ID`.
Using `<WorldID>SpawnRoundRobin` rotates players across all available spawn points.

### Mars
| Value |
|---|
| `MarsSpawnCanyonOverlook` |
| `MarsSpawnButchersFlat` |
| `MarsSpawnFindersCanyon` |
| `MarsSpawnHellasCrags` |
| `MarsSpawnDonutFlats` |
| `MarsSpawnRoundRobin` |

### Moon (Lunar)
| Value |
|---|
| `LunarSpawnCraterVesper` |
| `LunarSpawnMontesUmbrarum` |
| `LunarSpawnCraterNox` |
| `LunarSpawnMonsArcanus` |
| `LunarSpawnRoundRobin` |

### Other worlds
For Europa, Mimas, Vulcan, Venus, Loulan, and Space the naming convention is `<WorldID>SpawnRoundRobin` (e.g. `EuropaSpawnRoundRobin`) or a specific named location if available. Refer to the [Stationeers Dedicated Server Guide](https://stationeers-wiki.com/Dedicated_Server_Guide) for the full up-to-date list.

---

## Administering the server

Stationeers includes a built-in RCON web interface accessible at `http://<server-ip>:27500`.

Set `STATIONEERS_SERVER_ADMIN_PASSWORD` to secure it. The default password (`stationeers`) is set in `default.ini` inside the container.

---

## License

See [LICENSE](LICENSE).
