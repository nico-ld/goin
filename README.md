# goin
## What is it ?
This is a small function to add to you're '_.zshrc_'. It allows you to go to any directory from anywhere _(because 'cd ../../directory' is too long)_.

## How to install it ?
Currently, this command is only avaible on **Linux**.  
You can install it manually by cloning this repository and adding in you're '_.zshrc_' file :
```bash
source ~/GIT_REPO/goin.zsh
```
Or simply run this command :
```bash
git clone https://github.com/nico-ld/goin.git ~/.goin_function && echo "source ~/.goin_function/goin.zsh" >> .zshrc
```

⚠️ By default, the function will generate a configuration file in your __/home/user/__ directory _(.goin_config)_. For certain reasons, this file must know the location of the repository. Therefore, if you clone manually or move the repository, remember to __specify the new path in the configuration file.__

## How to use it ?
There are three ways to use this function :
```bash
goin <directory_name>
goin <option>
```
The first way is the basic one : you just go to you're desired directory.

The second way works with these options :
- -h --help : Display the help menu
- -l --last : Uses you're last call of function
- -b --back : Work like _'cd -'_ but without printing the destination path

## Alias
The third way to use this function is with custom aliases. You can create your own flag to go faster, or limit the scope of the function. 
To create your alias, use :
```bash
goin --set-alias <name> <path>
```
Your alias must start like a real flag (with '-'), otherwhise it will not be reconized.
To delete it :
```bash
goin --unset-alias <name>
```
To use your alias :
```bash
goin <alias> [directory]
```
