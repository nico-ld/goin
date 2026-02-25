# goin
## What is it ?
This is a little function to add at you're '_.zshrc_'. It allows you to go any directory from any directory _(because 'cd ../../directory' is too long)_.

## How to install ?
Actually, this command is only avaible on **Linux**.  
You can do this manually by cloning this repo and add in you're '_.zshrc_' file this line :
```bash
source ~/GIT_REPO/goin.zsh
```
Or Simply run this command :
```bash
git clone https://github.com/nico-ld/goin.git ~/.goin_function && echo "source ~/.goin_function/goin.zsh" >> .zshrc
```

## How to use it ?
The command as to be run like that :
```bash
goin [option] <directory_name>
```
By default this function dont search in hidden directories but you can add them to the research with _**-a**_ or _**--all**_.  
Because I'm a bit lazy when I open my terminal, I also add _**-l**_ and _**--last**_ options to execute the last call of _goin_. But with this option, the function didn't take a directory name :
```bash
goin -l
```
This call will get you in you're last directory.
