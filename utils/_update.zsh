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
		if git -C "$GOIN_DIR" pull -q; then
			source ~/.zshrc
			if (( $? == 0 )); then
				echo "goin: $SUCCESS: successfully updated"
				cat "$GOIN_DIR/utils/patch_note.txt"
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

    if [[ ! -d ${~repo} ]]; then
		echo "goin: $ERROR: couldn't find repository" >&2
		return 1
	fi

    git -C ${~repo} fetch -q >/dev/null 2>&1 || return 1

    local local_commit=$(git -C ${~repo} rev-parse HEAD 2>/dev/null)
    local remote_commit=$(git -C ${~repo} rev-parse @{u} 2>/dev/null)

    if [[ "$local_commit" != "$remote_commit" ]]; then
        sed -i 's|^UPDATE_AVAILABLE=".*"|UPDATE_AVAILABLE="true"|' "$HOME/.goin_config"
    fi
}
