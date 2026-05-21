#!/bin/zsh

_goin_help() {
	echo -e "  \033[1mUsage:\033[0m "
    echo -e "\tgoin [option] <directory_name>"
    echo -e "\tgoin <option>"
    echo -e "\tgoin <alias> [directory_name]\n"
	echo -e "  \033[1mDescription:\033[0m "
    echo -e "\tThis command allows you to access any directory from anywhere.\n"
	# echo -e "\tBy default, this function does not search hidden folders. You can enable this with '-all'. \n"
	echo -e "  \033[1mOptions:\033[0m"
    echo -e "\t-b --back : Work like '\033[3mcd -\033[0m' but without print the destination path"
	echo -e "\t-h --help : Display informations about this command"
    echo -e "\t-l --last : Use the same path than the last time you use the command\n"
	echo -e "  \033[1mAlias :\033[0m"
    echo -e "\tYou can customise this function with somes alias. This allows you to restrict the scope \n\tof the function on a given path. You can also use them to go faster in you're directory\n"
    echo -e "\t--set-alias <name> <path> : If the alias does not exist, it is created; otherwise, its path \n\t\tis modified. The name of you're alias have to start with '-' to be reconize like a flag"
    echo -e "\t--unset-alias <name> : Delete an alias\n"
	echo -e "  \033[1mAuthor\033[0m : nico-ld."
}
