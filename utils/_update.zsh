#!/bin/zsh

#
# _update() -> If an update is avaible -> git pull, otherwise just print a message.
#
_update() {
	if ! grep -q "UPDATE_FLAG" "$HOME/.goin_config"; then
		echo -e "goin: $WARNING: UPDATE_FLAG not set in config file."
		echo "goin: $INFO adding UPDATE_FLAG in config file..."
		echo -e '\nUPDATE_FLAG="false"' >> "$HOME/.goin_config"
		return 1
	elif grep -q 'UPDATE_FLAG="true"' "$HOME/.goin_config"; then
		if git -C "${0:A:h}" pull -q; then
			echo "goin: $SUCCESS: successfully updated"
			cat "${0:A:h}/patch_note.txt"
			sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="false"|' "$HOME/.goin_config"
		fi
	else
		echo "goin: $INFO: Already up to date."
	fi
	return 0
}

# 
# _has_new_commit() -> Check for a new update (async + cooldown)
# 
_has_new_commit_bg() {
    local repo="${0:A:h}"
    local cooldown=3600

    if [[ ! -d ${~repo} ]]; then
        return 1
    fi

    local last_fetch=$(grep '^LAST_FETCH=' "$HOME/.goin_config" | cut -d '=' -f2- | tr -d '"')
    local now=$(date +%s)

    if (( now - last_fetch < cooldown )); then
        # Cooldown not yet over, we only read the flag
        [[ "$(grep '^UPDATE_AVAILABLE=' "$HOME/.goin_config" | cut -d '=' -f2- | tr -d '"')" == "true" ]]
        return $?
    fi

    # Fetch in background
    (
        git -C ${~repo} fetch -q >/dev/null 2>&1 || exit 1
        sed -i "s|^LAST_FETCH=\".*\"|LAST_FETCH=\"$(date +%s)\"|" "$HOME/.goin_config"
        local local_commit=$(git -C ${~repo} rev-parse HEAD 2>/dev/null)
        local remote_commit=$(git -C ${~repo} rev-parse @{u} 2>/dev/null)
        if [[ "$local_commit" != "$remote_commit" ]]; then
            sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="true"|' "$HOME/.goin_config"
        else
            sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="false"|' "$HOME/.goin_config"
        fi
    ) &!

    # This time, we read the flagfrom the previous fetch
    [[ "$(grep '^UPDATE_AVAILABLE=' "$HOME/.goin_config" | cut -d '=' -f2- | tr -d '"')" == "true" ]]
}

if [[ -o login && -o interactive ]]; then
    if _has_new_commit_bg; then
        echo "goin: $INFO: An update is available, run : goin --update to install it."
		sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="true"|' "$HOME/.goin_config"
    fi
fi