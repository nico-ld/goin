#!/bin/zsh

# includes others files
source "${0:A:h}/utils/_alias.zsh"
source "${0:A:h}/utils/_help.zsh"
source "${0:A:h}/utils/_research.zsh"
source "${0:A:h}/utils/_update.zsh"

# define global var for output message
typeset -g ERROR="\033[31mERROR\033[0m"
typeset -g INFO="\033[34mINFO\033[0m"
typeset -g WARNING="\033[33mWARNING\033[0m"
typeset -g SUCCESS="\033[32mSUCCESS\033[0m"

# goin dir emplacement
typeset -g GOIN_DIR="${${(%):-%x}:A:h}"

# 
# _update_config_file() -> modify .goin_config to always keep goin -l and goin -b working
# 
_update_config_file() {
    sed -i "s|^LAST_PATH=\".*\"|LAST_PATH=\"$1\"|" "$config_file"
}

#
# _config_file_check() -> Check the presence of important line of config_file
#
_config_file_check() {
	local alias_save="none"

	if grep -q "ALIAS" "$config_file"; then
		alias_save=$(grep "ALIAS" "$config_file")
	else
		echo "ALIAS={}" >> $config_file
	fi
	if ! grep -q "LAST_PATH" "$config_file"; then
		echo 'LAST_PATH="~"' >> "$config_file"
	fi
	if ! grep -q "UPDATE_AVAILABLE" "$config_file"; then
		echo "goin: $ERROR: Missing important parameter in configuration file"
		echo "goin: $INFO: configuration file will be rewrite"
		echo "goin: $INFO: your aliases have beed saved"
        echo 'LAST_PATH="~"' > "$config_file"

		if [[ "$alias_save" == "none" ]]; then
			echo "ALIAS={}" >> "$config_file"
		else
			echo "$alias_save" >> "$config_file"
		fi

		echo 'UPDATE_AVAILABLE="false"' >> "$config_file"
        echo 'LS_FLAG="false"' >> "$config_file"		
		_update "silent"
	fi
}

# 
# _check_ls_flag() -> Check the flag ls in config file, and execute ls if necessary
# 
_check_ls_flag() {
	if grep -q 'LS_FLAG="true"' "$config_file"; then
		ls
	fi
}

_reset_temp_flag() {
	if grep -q 'CREATE_FLAG="true"' "$config_file"; then
		sed -i 's|^CREATE_FLAG=".*"|CREATE_FLAG="false"|' "$config_file"
	fi
	if grep -q 'HIDDEN_FLAG="true"' "$config_file"; then
		sed -i 's|^HIDDEN_FLAG=".*"|HIDDEN_FLAG="false"|' "$config_file"
	fi
}

_update_message(){
	if grep -q 'UPDATE_AVAILABLE="true"' "$config_file"; then
		echo "goin: $INFO: An update is available, run : goin --update to install it"
	fi
}

#
# goin() -> main function. Parse all flags and call good function
#
goin() {
    local config_file="$HOME/.goin_config"

    if [[ ! -f "$config_file" ]]; then
        echo -e 'LAST_PATH="~"\nALIAS={}\nUPDATE_AVAILABLE="false"' > "$config_file"
		echo -e 'LS_FLAG="flag"\nCREATE_FLAG="false"\nHIDDEN_FLAG="false"' >> "$config_file"
	fi

	_config_file_check

    if [[ -z "$1" ]]; then 
        echo "goin: $ERROR: Missing arguments"
        echo "Usage: goin [option] <directory_name>"
        return 3
    fi

    local current_dir=${PWD}
    local back=$(env | grep OLDPWD | cut -d '=' -f2-)

	# Flag parsing
    local arg
	local flag
	local count

	for arg in "$@"; do 
		(( count++ ))
		case "$arg" in
			--*)
				if [[ ! count -eq 1 ]]; then
					echo "goin: $ERROR: ${arg#} have to be used alone"
					_reset_temp_flag
					_update_message
					return 1
				fi
				case "$arg" in
					--help)
						man -l "$GOIN_DIR/utils/goin.1"
						;;
					--set-alias)
						if [[ -z "$2" || -z "$3" ]]; then
							echo "goin: $ERROR: missing arguments"
							echo "Usage: goin --set-alias <name> <~/path/from/home>"
							return 1
						else
							_alias_management "update" $@
						fi
						;;
					--unset-alias)
						if [[ -z "$2" ]]; then
							echo "goin: $ERROR: missing arguments"
							echo "Usage: goin --unset-alias <name>"
							return 1
						else
							_alias_management "unset" $@
						fi
						;;
					--list-alias)
						_list_alias
						;;
					--set-ls)
						if ! grep -q "LS_FLAG" "$config_file"; then
							echo 'LS_FLAG="true"' >> "$config_file"
						else
							sed -i 's|^LS_FLAG=".*"|LS_FLAG="true"|' "$config_file"
						fi
						;;
					--unset-ls)
						if ! grep -q "LS_FLAG" "$config_file"; then
							echo 'LS_FLAG="false"' >> "$config_file"
						else
							sed -i 's|^LS_FLAG=".*"|LS_FLAG="false"|' "$config_file"
						fi
						;;
					--update)
						_update
						;;
					--version)
						echo "goin: $INFO: Version \033[1m2.2.2\033[0m"
						;;
					--*) echo "goin: $ERROR: $arg: Unknow option" ;;
				esac
				_update_message
				return "$?"
				;;
			-*)
				# Short option(s): strip the leading '-', then iterate chars
				local opts="${arg#-}"
				local i=1
				if (grep "ALIAS" "$config_file" | grep -q -- "\"$arg\":"); then
					_alias_management "research" "$arg"
					_check_ls_flag
					_update_message
					return 0
				fi
				while [[ $i -le ${#opts} ]]; do
					flag="${opts[$i]}"
					case "$flag" in
						h)
							_goin_help
							_reset_temp_flag
							_update_message
							return 0
							;;
						b)
							cd "$back"
							_check_ls_flag
							_update_config_file "$back"
							_reset_temp_flag
							_update_message
							return 0
							;;
						p)
							if ! grep -q "CREATE_FLAG" "$config_file"; then
								echo 'CREATE_FLAG="true"' >> "$config_file"
							else
								sed -i 's|^CREATE_FLAG=".*"|CREATE_FLAG="true"|' "$config_file"
							fi
							;;
						a)
							if ! grep -q "HIDDEN_FLAG" "$config_file"; then
								echo 'HIDDEN_FLAG="true"' >> "$config_file"
							else
								sed -i 's|^HIDDEN_FLAG=".*"|HIDDEN_FLAG="true"|' "$config_file"
							fi
							;;
						*)
							echo "goin: $ERROR: Unknown flag or alias: '$flag'"
							;;
					esac
					(( i++ ))
				done
				;;
			*)
				_research "~" "$current_dir" "$arg"
				if [[ "$?" -eq "0" ]]; then
					_check_ls_flag
				elif [[ "$?" -eq "77" ]]; then
					_update_message
					return 0
				fi
				break
				;;
			esac
	done

    local return_code="$?"
	_update_message
	_reset_temp_flag
    return "$return_code"
}

gion() {
	echo -e "gion: $ERROR: you type gion ! Get a 10sec sleep"
	echo
	goin $@
	sleep 10
}

(
if [[ -o interactive ]]; then
   	_has_new_commit
fi
) &!

