#!/usr/bin/env bash

set -e
set -o pipefail

echo "Running as user: $(whoami)"

GAME_DIR="/steamcmd/stationeers"

exit_handler()
{
	echo ""
	echo "Waiting for server to shutdown.."
	echo ""
	kill -SIGINT "$child"
	sleep 5
	echo ""
	echo "Terminating.."
	echo ""
	exit
}

trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

# ---------------------------------------------------------------------------
# Install/update SteamCMD
# ---------------------------------------------------------------------------
echo ""
echo "Installing/updating steamcmd.."
echo ""
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# ---------------------------------------------------------------------------
# Install/update Stationeers dedicated server
# ---------------------------------------------------------------------------
if [ ! -f "$GAME_DIR/rocketstation_DedicatedServer.x86_64" ]; then
	echo ""
	echo "Installing Stationeers.."
	echo ""
else
	echo ""
	echo "Updating Stationeers.."
	echo ""
fi
bash /steamcmd/steamcmd.sh +runscript /app/install.txt

# ---------------------------------------------------------------------------
# Install BepInEx (re-installs when BEPINEX_VERSION changes in image)
# ---------------------------------------------------------------------------
if [ "$(cat "$GAME_DIR/.bepinex_version" 2>/dev/null)" != "$BEPINEX_VERSION" ]; then
	echo ""
	echo "Installing BepInEx $BEPINEX_VERSION.."
	echo ""
	unzip -o /app/bepinex/bepinex.zip -d "$GAME_DIR"
	sed -i 's|^executable_name=.*|executable_name="rocketstation_DedicatedServer.x86_64"|' "$GAME_DIR/run_bepinex.sh"
	chmod +x "$GAME_DIR/run_bepinex.sh"
	echo "$BEPINEX_VERSION" > "$GAME_DIR/.bepinex_version"
fi

# ---------------------------------------------------------------------------
# Install StationeersLaunchPad (re-installs when SLP_VERSION changes in image)
# ---------------------------------------------------------------------------
if [ "$(cat "$GAME_DIR/.slp_version" 2>/dev/null)" != "$SLP_VERSION" ]; then
	echo ""
	echo "Installing StationeersLaunchPad $SLP_VERSION.."
	echo ""
	mkdir -p "$GAME_DIR/BepInEx/plugins"
	unzip -o /app/slp/slp.zip -d "$GAME_DIR/BepInEx/plugins"
	echo "$SLP_VERSION" > "$GAME_DIR/.slp_version"
fi

# ---------------------------------------------------------------------------
# Download Workshop mods (if WORKSHOP_MOD_IDS is set)
# ---------------------------------------------------------------------------
if [ -n "${WORKSHOP_MOD_IDS:-}" ]; then
	echo ""
	echo "Downloading Workshop mods: $WORKSHOP_MOD_IDS"
	echo ""
	WORKSHOP_SCRIPT="$(mktemp /tmp/workshop_XXXXXX.txt)"
	{
		printf "@ShutdownOnFailedCommand 1\n"
		printf "@NoPromptForPassword 1\n"
		printf "login anonymous\n"
		IFS=',' read -ra MOD_IDS <<< "$WORKSHOP_MOD_IDS"
		for mod_id in "${MOD_IDS[@]}"; do
			mod_id="${mod_id// /}"
			printf "workshop_download_item 544550 %s\n" "$mod_id"
		done
		printf "quit\n"
	} > "$WORKSHOP_SCRIPT"
	bash /steamcmd/steamcmd.sh +runscript "$WORKSHOP_SCRIPT"
	rm -f "$WORKSHOP_SCRIPT"
fi

# ---------------------------------------------------------------------------
# Build startup command
# ---------------------------------------------------------------------------
STATIONEERS_STARTUP_COMMAND=$(echo "-file start $STATIONEERS_SERVER_WORLD_NAME $STATIONEERS_SERVER_WORLD_ID $STATIONEERS_SERVER_DIFFICULTY $STATIONEERS_SERVER_START_CONDITION $STATIONEERS_SERVER_START_LOCATION" | tr -s " ")

if [ -n "${STATIONEERS_SERVER_LOGS+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -logFile ${STATIONEERS_SERVER_LOGS}"
fi

if [ -n "${STATIONEERS_SERVER_STARTUP_ARGUMENTS+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ${STATIONEERS_SERVER_STARTUP_ARGUMENTS} -settings"
fi

if [ -n "${STATIONEERS_SERVER_VISIBLE+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerVisible ${STATIONEERS_SERVER_VISIBLE}"
fi

if [ -n "${STATIONEERS_SERVER_GAME_PORT+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} GamePort ${STATIONEERS_SERVER_GAME_PORT}"
fi

if [ -n "${STATIONEERS_SERVER_UPDATE_PORT+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UpdatePort ${STATIONEERS_SERVER_UPDATE_PORT}"
fi

if [ -n "${STATIONEERS_SERVER_UPNP_ENABLED+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UPNPEnabled ${STATIONEERS_SERVER_UPNP_ENABLED}"
fi

if [ -n "${STATIONEERS_SERVER_NAME+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerName ${STATIONEERS_SERVER_NAME}"
fi

if [ -n "${STATIONEERS_SERVER_PASSWORD+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerPassword ${STATIONEERS_SERVER_PASSWORD}"
fi

if [ -n "${STATIONEERS_SERVER_ADMIN_PASSWORD+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerAuthSecret ${STATIONEERS_SERVER_ADMIN_PASSWORD}"
fi

if [ -n "${STATIONEERS_SERVER_MAX_PLAYERS+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerMaxPlayers ${STATIONEERS_SERVER_MAX_PLAYERS}"
fi

if [ -n "${STATIONEERS_SERVER_AUTO_SAVE+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} AutoSave ${STATIONEERS_SERVER_AUTO_SAVE}"
fi

if [ -n "${STATIONEERS_SERVER_SAVE_INTERVAL+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} SaveInterval ${STATIONEERS_SERVER_SAVE_INTERVAL}"
fi

if [ -n "${STATIONEERS_SERVER_AUTO_PAUSE+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} AutoPauseServer ${STATIONEERS_SERVER_AUTO_PAUSE}"
fi

if [ -n "${STATIONEERS_SERVER_STEAM_P2P+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UseSteamP2P ${STATIONEERS_SERVER_STEAM_P2P}"
fi

if [ -n "${STATIONEERS_START_LOCAL_HOST+x}" ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} StartLocalHost ${STATIONEERS_START_LOCAL_HOST}"
fi

# ---------------------------------------------------------------------------
# Launch server via BepInEx
# ---------------------------------------------------------------------------
cd "$GAME_DIR" || exit

echo ""
echo "Starting Stationeers with BepInEx: ${STATIONEERS_STARTUP_COMMAND}"
echo ""
./run_bepinex.sh ${STATIONEERS_STARTUP_COMMAND} 2>&1 &

child=$!
wait "$child"
