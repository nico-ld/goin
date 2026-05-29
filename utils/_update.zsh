#!/bin/zsh

#
# _update() -> If an update is avaible -> git pull, otherwise just print a message.
#
_update() {
	if ! grep -q "UPDATE_AVAILABLE" "$HOME/.goin_config"; then
		echo -e "goin: $WARNING: UPDATE_AVAILABLE not set in config file."
		echo "goin: $INFO adding UPDATE_AVAILABLE in config file..."
		echo -e '\UPDATE_AVAILABLE="false"' >> "$HOME/.goin_config"
		return 1
	elif grep -q 'UPDATE_AVAILABLE="true"' "$HOME/.goin_config"; then
		if git -C "${0:A:h}" pull -q; then
			source ~/.zshrc
			if [ $? == 0]; then
				echo "goin: $SUCCESS: successfully updated"
				cat "${0:A:h}/patch_note.txt"
				sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="false"|' "$HOME/.goin_config"
			else
				echo -e "$ERROR: A problem occurs whil trying to refresh ~/.zshrc"
				echo -e "$WARNING: Goin updated but function maybe not refreshed"
				echo -e "$WARNING: Restart your terminal or try again to refresh ~/.zshrc"
			fi
		fi
	else
		if [[ -z "$1" ]]; then 
			echo "goin: $INFO: Already up to date."
		fi
	fi
	return 0
}

_has_new_commit() {
    local repo="$GOIN_DIR"

    [[ ! -d ${~repo} ]] && return 1

    # Fetch synchronously (runs only at source time)
    git -C ${~repo} fetch -q >/dev/null 2>&1 || return 1

    local local_commit=$(git -C ${~repo} rev-parse HEAD 2>/dev/null)
    local remote_commit=$(git -C ${~repo} rev-parse @{u} 2>/dev/null)

    if [[ "$local_commit" != "$remote_commit" ]]; then
        echo "goin: $INFO: An update is available, run : goin --update to install it"
        sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="true"|' "$HOME/.goin_config"
    fi
}

if [[ -o login && -o interactive ]]; then
    _has_new_commit
fi