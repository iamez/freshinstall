#!/bin/bash

# Define version variables and users
etlegacy_version="2.82.0"  # Update this for the desired version
default_game_directory="$HOME/etlegacy-v${etlegacy_version}-x86_64"
default_installation_file_path="${default_game_directory}/legacy/"
current_user=$(logname)
home_directory=$(eval echo ~$current_user)

# Download ET Legacy server installation script
sudo curl -o "$home_directory/etlegacy-install.sh" https://etlegacy-2.82.0-link.com
sudo chown "$USER:$USER" "$home_directory/etlegacy-install.sh"
sudo chmod a+x "$home_directory/etlegacy-install.sh"

# Install the server using defaults and as the current user
yes | sudo -H -u "$USER" /bin/bash -c "cd $home_directory && ./etlegacy-install.sh"

# Find the latest installed version dynamically
installed_version_directory=$(find "$home_directory" -maxdepth 1 -type d -name "etlegacy-v*" | sort -V | tail -n 1)

# Set ownership and permissions for extracted files
sudo chown -R "$USER:$USER" "$installed_version_directory"
sudo chmod -R 700 "$installed_version_directory"

# Download competitive configs from ET: Legacy Competitive GitHub repository
config_repo_url="https://github.com/ET-Legacy-Competitive/Legacy-Competition-League-Configs/archive/main.zip"
config_temp_zip="$tmp_directory/main.zip"
sudo wget -q "$config_repo_url" -O "$config_temp_zip"
sudo unzip -q "$config_temp_zip" -d "$tmp_directory"
sudo cp -r "$tmp_directory/Legacy-Competition-League-Configs-main/." "$installed_version_directory"
sudo chown -R "$USER:$USER" "$installed_version_directory"
sudo chmod -R 700 "$installed_version_directory"
sudo rm -rf "$tmp_directory/Legacy-Competition-League-Configs-main"

# Additional commands to set ownership and permissions for the server
sudo chown -R "$USER:$USER" "$CONFIG_DIR"
sudo chown -R "$USER:$USER" "$ETMAIN_DIR"
sudo chmod 700 "$ETMAIN_DIR"
sudo chmod 700 "$LEGACY_DIR"
sudo chown -R "$USER:$USER" "$DOMA"

# Download server configs
sudo -u "$USER" curl -sSfL "https://raw.githubusercontent.com/iamez/freshinstall/main/aim.cfg" -o "$ETMAIN_DIR/aim.cfg"
sudo chown "$USER:$USER" "$ETMAIN_DIR/aim.cfg"
sudo chmod 700 "$ETMAIN_DIR/aim.cfg"
sudo -u "$USER" curl -sSfL "https://raw.githubusercontent.com/iamez/freshinstall/main/aim.config" -o "$CONFIG_DIR/aim.config"
sudo chown "$USER:$USER" "$CONFIG_DIR/aim.config"
sudo chmod 700 "$CONFIG_DIR/aim.config"
sudo -u "$USER" curl -sSfL "https://raw.githubusercontent.com/iamez/freshinstall/main/vektor.cfg" -o "$ETMAIN_DIR/vektor.cfg"
sudo chown "$USER:$USER" "$ETMAIN_DIR/vektor.cfg"
sudo chmod 700 "$ETMAIN_DIR/vektor.cfg"
echo "Custom configs have been successfully downloaded and installed."

# Create the abs1.3.lua script for aim server
ABS_LUA_FILE="${LEGACY_DIR}/abs1.3.lua"
echo 'local version = 1.3
local modname = "abs"

function getTeam(clientNum)
    return et.gentity_get(clientNum, "sess.sessionTeam")
end

-- callbacks
function et_InitGame(levelTime, randomSeed, restart)
    et.RegisterModname(modname .. " " .. version)
end

function et_ClientSpawn(clientNum, revived, teamChange, restoreHealth)
    et.gentity_set(clientNum, "ps.powerups", et.PW_NOFATIGUE, 1)
    et.gentity_set(clientNum, "health", 10000)
    if getTeam(clientNum) == 1 then
        et.AddWeaponToPlayer(clientNum, et.WP_MP40, 9999, 9999, 0)
    fi
    if getTeam(clientNum) == 2 then
        et.AddWeaponToPlayer(clientNum, et.WP_THOMPSON, 9999, 9999, 0)
    fi
end' > "${ABS_LUA_FILE}"
sudo chown "$USER:$USER" "$ABS_LUA_FILE"
sudo chmod a+x "$ABS_LUA_FILE"

# Download etdaemon2.sh and move it to the game directory
curl https://github.com/iamez/etlegacy-scripts/blob/main/etdaemon2.sh > "$GAME_DIR/etdaemon2.sh"
chmod a+x "$GAME_DIR/etdaemon2.sh"
chmod a+x "$ABS_LUA_FILE"
chown "$USER:$USER" "$GAME_DIR/etdaemon2.sh"
sed -i -e "s#^GAME_DIR=\".*\"#GAME_DIR=\"$GAME_DIR\"#" -e 's/\r//' "$GAME_DIR/etdaemon2.sh"

# Download endstats.lua and c0rnp0rn.lua
sudo -u "$USER" curl -sSfL "https://raw.githubusercontent.com/iamez/etlegacy-scripts/main/endstats.lua" -o "${installed_version_directory}/legacy/endstats.lua"
sudo -u "$USER" curl -sSfL "https://raw.githubusercontent.com/iamez/etlegacy-scripts/main/c0rnp0rn.lua" -o "${installed_version_directory}/legacy/c0rnp0rn.lua"
sudo chown "$USER:$USER" "${installed_version_directory}/legacy/endstats.lua"
sudo chown "$USER:$USER" "${installed_version_directory}/legacy/c0rnp0rn.lua"
sudo chmod 700 "${installed_version_directory}/legacy/endstats.lua"
sudo chmod 700 "${installed_version_directory}/legacy/c0rnp0rn.lua"

# Replace etl_supply entry in configs
sed -i '/^map etl_supply/,/^}/s/set g_userTimeLimit "12"/set g_userTimeLimit "15"\n\tcommand "sv_cvar r_drawfoliage EQ 0"\n/' "${installed_version_directory}/etmain/configs/"*config

# Update lua_modules configurations
sed -i '/setl lua_modules/s/"$/endstats.lua c0rnp0rn.lua"/' "${installed_version_directory}/etmain/configs/"*config



# Download all "official" competitive maps, and some other popular maps.
files=(
    "aimmap3.pk3"
    "badplace4_beta8.pk3"
    "braundorf_b4.pk3"
    "bremen_b3.pk3"
    "ctf_multi2.pk3"
    "CTF_Multi.pk3"
    "ctf_well.pk3"
    "decay_b7.pk3"
    "decay_sw.pk3"
    "erdenberg_t2.pk3"
    "et_beach.pk3"
    "et_brewdog_b6.pk3"
    "et_headshot2_b2.pk3"
    "et_ice.pk3"
    "etl_adlernest_v4.pk3"
    "etl_frostbite_v17.pk3"
    "etl_ice_v12.pk3"
    "etl_sp_delivery_v5.pk3"
    "etl_supply_v12.pk3"
    "etl_warbell_v3.pk3"
    "et_ufo_final.pk3"
    "Frostbite.pk3"
    "gammajump.pk3"
    "karsiah_te2.pk3"
    "karsiah_te3.pk3"
    "kothet2.pk3"
    "lnatrickjump.pk3"
    "maniacmansion.pk3"
    "missile_b3.pk3"
    "mp_sillyctf.pk3"
    "mp_sub_rc1.pk3"
    "multi_huntplace.pk3"
    "reactor_final.pk3"
    "sos_secret_weapon.pk3"
    "sp_delivery_te.pk3"
    "supply.pk3"
    "sw_battery.pk3"
    "sw_goldrush_te.pk3"
    "sw_oasis_b3.pk3"
    "te_escape2_fixed.pk3"
    "te_escape2.pk3"
    "te_valhalla.pk3"
    "UseMeJump.pk3"
)

num_downloaded=0
num_skipped=0
num_failed=0

for file in "${files[@]}"
do
    if [ -e "${ETMAIN_DIR}/${file}" ]; then
        echo "${file} already exists in ${ETMAIN_DIR} and will be skipped"
        ((num_skipped++))
        continue
    fi

    downloaded=false
    for link in \
        "http://download.hirntot.org/etmain/${file}" \
        "https://et.clan-etc.de/etmain/${file}" \
        "http://www.et-spessartraeuber.de/et/etmain/${file}" \
        "http://www.bunker4fun.com/b4/dl.php?dir=etmain&file=${file}"
    do
        if sudo wget -q "$link" -O "$ETMAIN_DIR/${file}"; then
            downloaded=true
            ((num_downloaded++))
            break
        fi
    done
    if ! $downloaded; then
        echo "${file} not found and skipped"
        ((num_failed++))
        continue
    fi
    sudo chown "$USER:$USER" "${ETMAIN_DIR}/${file}"
    sudo chmod 700 "${ETMAIN_DIR}/${file}"
done

echo "Downloaded ${num_downloaded} files. Skipped ${num_skipped} files that already exist. Failed to download ${num_failed} files"

# Create the start.sh script
cat << EOF > "$DOMA/start.sh"
#!/bin/bash
sleep 10
cd "$GAME_DIR"
bash etdaemon2.sh &
EOF

# Set permissions for start.sh
sudo chown "$USER:$USER" "$DOMA/start.sh"
sudo chmod a+x "$DOMA/start.sh"

# Add crontab entries
(crontab -u "$USER" -l ; echo "0 6 * * * kill \$(pidof $GAME_DIR/etlded.x86_64)") | crontab -u "$USER" -
(crontab -u "$USER" -l ; echo "@reboot /bin/bash $DOMA/start.sh >/dev/null 2>&1") | crontab -u "$USER" -

sudo chmod a+x "$GAME_DIR/etlded.x86_64"
sudo touch "/home/$USER/start_servers.log"
sudo chown "$USER:$USER" "/home/$USER/start_servers.log"

# Start the server dynamically with the latest version (new updated)
su - "$USER" -s /bin/bash -c "cd ${installed_version_directory} && dos2unix etdaemon2.sh && ./etdaemon2.sh" &
