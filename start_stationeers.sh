#!/usr/bin/env bash

# Enable debugging
#set -x

# Setup error handling
set -e
set -o pipefail

# Print the user we're currently running as
echo "Running as user: $(whoami)"

# Define the exit handler
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

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

# Install/update steamcmd
echo ""
echo "Installing/updating steamcmd.."
echo ""
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Check that Stationeers exists in the first place
if [ ! -f "/steamcmd/stationeers/rocketstation_DedicatedServer.x86_64" ]; then
	# Install Stationeers from install.txt
	echo ""
	echo "Installing Stationeers.."
	echo ""
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt
else
	# Install Stationeers from install.txt
	echo ""
	echo "Updating Stationeers.."
	echo ""
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt
fi

# Remove extra whitespace from startup command
STATIONEERS_STARTUP_COMMAND=$(echo "-file start $STATIONEERS_SERVER_WORLD_NAME $STATIONEERS_SERVER_WORLD_ID $STATIONEERS_SERVER_DIFFICULTY $STATIONEERS_SERVER_START_CONDITION $STATIONEERS_SERVER_START_LOCATION" | tr -s " ")

# Set server log file
if [ ! -z ${STATIONEERS_SERVER_LOGS+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -logFile ${STATIONEERS_SERVER_LOGS}"
fi

# Set server startup commands
if [ ! -z ${STATIONEERS_SERVER_STARTUP_ARGUMENTS+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ${STATIONEERS_SERVER_STARTUP_ARGUMENTS} -settings"
fi

# Set server visible
if [ ! -z ${STATIONEERS_SERVER_VISIBLE+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerVisible ${STATIONEERS_SERVER_VISIBLE}"
fi

# Set the game port
if [ ! -z ${STATIONEERS_SERVER_GAME_PORT+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} GamePort ${STATIONEERS_SERVER_GAME_PORT}"
fi

# Set the query/update port
if [ ! -z ${STATIONEERS_SERVER_UPDATE_PORT+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UpdatePort ${STATIONEERS_SERVER_UPDATE_PORT}"
fi

# Set the UPNP Enabled
if [ ! -z ${STATIONEERS_SERVER_UPNP_ENABLED+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UPNPEnabled ${STATIONEERS_SERVER_UPNP_ENABLED}"
fi

# Set the server name name
if [ ! -z ${STATIONEERS_SERVER_NAME+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerName ${STATIONEERS_SERVER_NAME}"
fi

# Set the server password
if [ ! -z ${STATIONEERS_SERVER_PASSWORD+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerPassword ${STATIONEERS_SERVER_PASSWORD}"
fi

# Set the server admin password
if [ ! -z ${STATIONEERS_SERVER_ADMIN_PASSWORD+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerAuthSecret ${STATIONEERS_SERVER_ADMIN_PASSWORD}"
fi

# Set the server max players
if [ ! -z ${STATIONEERS_SERVER_MAX_PLAYERS+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} ServerMaxPlayers ${STATIONEERS_SERVER_MAX_PLAYERS}"
fi

# Set the auto-save
if [ ! -z ${STATIONEERS_SERVER_AUTO_SAVE+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} AutoSave ${STATIONEERS_SERVER_AUTO_SAVE}"
fi

# Set the auto-save interval
if [ ! -z ${STATIONEERS_SERVER_SAVE_INTERVAL+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} SaveInterval ${STATIONEERS_SERVER_SAVE_INTERVAL}"
fi

# Set the Auto pause server
if [ ! -z ${STATIONEERS_SERVER_AUTO_PAUSE+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} AutoPauseServer ${STATIONEERS_SERVER_AUTO_PAUSE}"
fi

# Set the steam p2p
if [ ! -z ${STATIONEERS_SERVER_STEAM_P2P+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} UseSteamP2P ${STATIONEERS_SERVER_STEAM_P2P}"
fi

# Set the StartLocalHost
if [ ! -z ${STATIONEERS_START_LOCAL_HOST+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} StartLocalHost ${STATIONEERS_START_LOCAL_HOST}"
fi




# Set the working directory
cd /steamcmd/stationeers || exit

# Run the server
echo ""
echo "Starting Stationeers with arguments: ${STATIONEERS_STARTUP_COMMAND}"
echo ""
./rocketstation_DedicatedServer.x86_64 \
  ${STATIONEERS_STARTUP_COMMAND} \
  2>&1 &

child=$!
wait "$child"
