#!/bin/bash
set -e

# --- app metadata ---
APP_NAME="Kornet"
APP_ID="kornet-launcher"
APP_COMMENT="Kornet Launcher"
APP_INSTALL_SEARCH_DIR="AppData/Local/Kornet"

INSTALLER_URL="https://setup.kornet.lat/KornetPlayerLauncher.exe"
INSTALLER_EXE="KornetPlayerLauncher.exe"

REQUIRED_DOTNET_VERSION="8.0"
# pinned to exact version 8.0.24 as required by Kornet
DOTNET_INSTALLER_URL="https://download.visualstudio.microsoft.com/download/pr/windowsdesktop-runtime-8.0.24-win-x64.exe"
DOTNET_INSTALLER_NAME="windowsdesktop-runtime-8.0.24-win-x64.exe"

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR]: This installer must be run as root (sudo)."
  exit 1
fi

DOWNLOAD_TOOL=""
DOWNLOAD_ARGS=""

if command -v curl &>/dev/null; then
  DOWNLOAD_TOOL="curl"
  DOWNLOAD_ARGS="-L -o"
  echo "[SYSTEM]: Using 'curl' for downloads."
elif command -v wget &>/dev/null; then
  DOWNLOAD_TOOL="wget"
  DOWNLOAD_ARGS="-O"
  echo "Using 'wget' for downloads (Warning: Cannot follow redirects, .NET download may fail)."
else
  echo "[ERROR]: Neither curl nor wget found. Please install one to proceed."
  exit 1
fi

echo "[SYSTEM]: Installing dos2unix..."
if command -v dnf &>/dev/null; then
  dnf install -y dos2unix
elif command -v apt &>/dev/null; then
  apt update && apt install -y dos2unix
elif command -v pacman &>/dev/null; then
  pacman -S --noconfirm dos2unix
else
  echo "[WARNING]: Could not install dos2unix automatically."
fi

echo "[SYSTEM]: Detecting non-root users..."
USER_DIRS=(/home/*)
declare -A found_users
for dir in "${USER_DIRS[@]}"; do
  if [[ -d "$dir" ]] && [[ ! -L "$dir" ]]; then
    user=$(basename "$dir")
    if [[ "$user" != "root" ]] && id "$user" >/dev/null 2>&1; then
      uid=$(id -u "$user")
      if [[ "$uid" -ge 1000 ]]; then
        found_users["$user"]=1
      fi
    fi
  fi
done
USER_LIST=("${!found_users[@]}")

if [[ ${#USER_LIST[@]} -eq 0 ]]; then
  echo "[ERROR]: No suitable user directories found."
  exit 1
elif [[ ${#USER_LIST[@]} -eq 1 ]]; then
  REAL_USER="${USER_LIST[0]}"
  echo "[SYSTEM]: Found single user: $REAL_USER"
else
  echo "[SYSTEM]: Multiple users found. Please choose the user to install $APP_NAME for:"
  mapfile -t sorted_users < <(printf "%s\n" "${USER_LIST[@]}" | sort)
  select chosen_user in "${sorted_users[@]}"; do
    if [[ -n "$chosen_user" ]]; then
      REAL_USER="$chosen_user"
      echo "[SYSTEM]: Selected user: $REAL_USER"
      break
    fi
  done
fi

REAL_HOME=$(eval echo ~$REAL_USER)
REAL_UID=$(id -u "$REAL_USER")
REAL_GID=$(id -g "$REAL_USER")
WINEPREFIX="$REAL_HOME/.wine"

echo "Capturing user's graphical environment variables..."

SUDO_USER_ORIGINAL=$(logname 2>/dev/null || who am i | awk '{print $1}')
if [[ -z "$SUDO_USER_ORIGINAL" ]]; then
    echo "[WARNING]: Could not determine original user. Falling back to simple environment pass."
    SUDO_USER_ORIGINAL="$REAL_USER"
fi

ENV_VARS="DISPLAY=\"$DISPLAY\" XDG_RUNTIME_DIR=\"$XDG_RUNTIME_DIR\" WAYLAND_DISPLAY=\"$WAYLAND_DISPLAY\""

# --- get xauthority path for x11 connections ---
if [[ -n "$DISPLAY" ]] && [[ "$SUDO_USER_ORIGINAL" == "$REAL_USER" ]]; then
    XAUTH_FILE=""
    if [[ -n "$XAUTHORITY" ]] && [[ -f "$XAUTHORITY" ]]; then
        XAUTH_FILE="$XAUTHORITY"
    elif [[ -f "$REAL_HOME/.Xauthority" ]]; then
        XAUTH_FILE="$REAL_HOME/.Xauthority"
    else
        XAUTH_DIR="/run/user/$(id -u "$REAL_USER")"
        XAUTH_CANDIDATE=$(find "$XAUTH_DIR" -type f -iname "*authority*" -print -quit 2>/dev/null)
        if [[ -n "$XAUTH_CANDIDATE" ]]; then
            XAUTH_FILE="$XAUTH_CANDIDATE"
        fi
    fi

    if [[ -n "$XAUTH_FILE" ]]; then
        if [[ -f "$XAUTH_FILE" ]]; then
            ENV_VARS+=" XAUTHORITY=\"$XAUTH_FILE\""
            echo "Using XAUTHORITY: $XAUTH_FILE"
        fi
    fi
fi

# --- define a function to execute commands as the user with the necessary environment ---
execute_as_user() {
  su - "$REAL_USER" -c "export $ENV_VARS; WINEPREFIX=\"$WINEPREFIX\" WINEARCH=win64 $1"
}

WINE_EXE=$(command -v wine || true)
if [[ -z "$WINE_EXE" ]]; then
  echo "[SYSTEM]: Installing Wine..."
  if command -v dnf &>/dev/null; then
    dnf install -y wine winetricks
  elif command -v apt &>/dev/null; then
    apt update && apt install -y wine winetricks
  elif command -v pacman &>/dev/null; then
    pacman -Syu --noconfirm wine winetricks
  else
    echo "[ERROR]: Cannot find package manager."
    exit 1
  fi
fi

# --- run wineboot here to ensure prefix is fully prepared ---
echo "[KORNET]: Preparing Wine prefix (initialization/update)..."
execute_as_user "wineboot -u"
execute_as_user "wine reg add \"HKCU\\\\Software\\\\Wine\" /v UseWinsock /t REG_SZ /d Y /f"

# --- check for .NET 8.0.x runtime (any patch version) ---
echo "[SYSTEM]: Checking for existing .NET $REQUIRED_DOTNET_VERSION runtime installation..."

DOTNET_FXR_DIR="$WINEPREFIX/drive_c/users/$REAL_USER/AppData/Local/Microsoft/dotnet/host/fxr"
HAS_DOTNET=false

if [[ -d "$DOTNET_FXR_DIR" ]]; then
  # look for any folder starting with 8.0. (e.g. 8.0.24)
  while IFS= read -r -d '' dir; do
    version=$(basename "$dir")
    if [[ "$version" == 8.0.* ]]; then
      echo "[SYSTEM]: Found .NET runtime version: $version"
      HAS_DOTNET=true
      break
    fi
  done < <(find "$DOTNET_FXR_DIR" -maxdepth 1 -type d -print0)
fi

# --- .NET installation prompt ---
if [[ "$HAS_DOTNET" == false ]]; then
  echo
  echo "Required .NET $REQUIRED_DOTNET_VERSION runtime is missing."
  echo "You have two options:"
  echo "  1) Automatic install (opens a Wine GUI window using the official installer). Recommended for most users!"
  echo "  2) Manual install (recommended if GUI fails). Usually not recommended for beginner users."
  echo

  read -r -p "" CHOICE
  CHOICE=${CHOICE:-1}

  if [[ "$CHOICE" =~ ^[1Yy]$ ]]; then
    echo "[KORNET]: Starting GUI installation of .NET $REQUIRED_DOTNET_VERSION..."
    echo "[KORNET]: Downloading .NET 8.0.24 runtime installer..."

    DOTNET_DOWNLOAD_CMD="$DOWNLOAD_TOOL $DOWNLOAD_ARGS \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\" \"$DOTNET_INSTALLER_URL\""

    if ! su - "$REAL_USER" -c "$DOTNET_DOWNLOAD_CMD"; then
        echo "[ERROR]: Failed to download the .NET installer using $DOWNLOAD_TOOL."
        echo "Please try the manual install instructions below."
        exit 1
    else
        echo "[.net]: Running .NET installer..."
        execute_as_user "wine \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\" || true"

        echo "[.net]: Cleaning up .NET installer..."
        su - "$REAL_USER" -c "rm -f \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\""
    fi

  else
    echo
    echo "Manual installation instructions:"
    echo "---------------------------------"
    echo "1. Open a terminal as user '$REAL_USER'"
    echo "2. Run the following commands:"
    echo
    echo "   curl -L -o \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\" \"$DOTNET_INSTALLER_URL\""
    echo
    echo "   export WINEPREFIX=\"$WINEPREFIX\""
    echo "   export WINEARCH=win64"
    echo "   wine \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\""
    echo "   rm -f \"$REAL_HOME/Downloads/$DOTNET_INSTALLER_NAME\""
    echo
    echo "Then re-run this installer when finished."
    exit 0
  fi
else
  echo "[KORNET]: .NET $REQUIRED_DOTNET_VERSION runtime already installed - skipping."
fi

# --- bootstrapper / installer direct download ---
echo "[KORNET]: Downloading the launcher's installer..."
EXE_PATH="$REAL_HOME/Downloads/$INSTALLER_EXE"

MAIN_DOWNLOAD_CMD="$DOWNLOAD_TOOL $DOWNLOAD_ARGS \"$EXE_PATH\" \"$INSTALLER_URL\""
su - "$REAL_USER" -c "$MAIN_DOWNLOAD_CMD"

echo "[KORNET]: Running the Kornet launcher..."
execute_as_user "wine \"$EXE_PATH\" || true"

echo "[KORNET]: Waiting 5 seconds for installation cleanup to complete..."
sleep 5

echo "[KORNET]: Searching for installed executable..."
INSTALL_PATH=$(find "$WINEPREFIX/drive_c/users/$REAL_USER/$APP_INSTALL_SEARCH_DIR" -type f -iname "*.exe" 2>/dev/null | sort | tail -n 1)

if [[ -z "$INSTALL_PATH" ]]; then
  echo "[ERROR]: Could not find installed executable in $APP_INSTALL_SEARCH_DIR."
  echo "[KORNET]: The client may have installed to a different path or failed to finish cleanly."
  echo "[KORNET]: You will need to manually locate the executable file."
  exit 1
fi

# --- .desktop file creation ---
DESKTOP_DIR="$REAL_HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

echo "[KORNET]: Creating desktop entry for URL protocol handler (kornetclient://)..."
echo "The protocol handler is not kornet-related at all; we can't change it."
cat <<EOF > "$DESKTOP_DIR/$APP_ID.desktop"
[Desktop Entry]
Name=$APP_NAME
Exec=env WINEPREFIX=$WINEPREFIX wine "$INSTALL_PATH" %u
Type=Application
Comment=$APP_COMMENT
Categories=Game;
StartupWMClass=Kornet
MimeType=x-scheme-handler/kornetclient;
EOF
chown "$REAL_USER:$REAL_GID" "$DESKTOP_DIR/$APP_ID.desktop"

# register the handler with the system
echo "[KORNET]: Registering 'kornetclient://' protocol handler..."
execute_as_user "update-desktop-database $DESKTOP_DIR || true"
execute_as_user "xdg-mime default $APP_ID.desktop x-scheme-handler/kornetclient || true"

# cleaning up
echo "[END]: Cleaning up installer..."
rm -f "$REAL_HOME/Downloads/$INSTALLER_EXE"

echo "Kornet has been installed! You may now play Kornet games on Linux through the site."
echo "PLEASE DO NOT UNINSTALL WINE. YOU WILL NOT BE ABLE TO LAUNCH THE GAME CLIENT WITHOUT IT."
echo "For support, please contact @unknownluau on Discord (the owner of Kornet)."
echo "Credits to Carbon for letting us use their linux launcher!"