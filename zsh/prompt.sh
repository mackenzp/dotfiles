# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

autoload -U colors && colors

setopt PROMPT_SUBST

set_prompt() {

	# [
	PS1="%{$fg[white]%}[%{$reset_color%}"

	# Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
	PS1+="%{$fg_bold[cyan]%}${PWD/#$HOME/~}%{$reset_color%}"

	# Status Code
	PS1+='%(?.., %{$fg[red]%}%?%{$reset_color%})'

	# Git
	if git rev-parse --is-inside-work-tree 2> /dev/null | grep -q 'true' ; then
		PS1+=', '
		PS1+="%{$fg[blue]%}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
		if [ $(git status --short | wc -l) -gt 0 ]; then 
			PS1+="%{$fg[red]%}+$(git status --short | wc -l | awk '{$1=$1};1')%{$reset_color%}"
		fi
	fi

	# Virtual Environment
	if [ -n "$VIRTUAL_ENV" ]; then
		if [ -f "$VIRTUAL_ENV/__name__" ]; then
			local name=`cat $VIRTUAL_ENV/__name__`
		elif [ `basename $VIRTUAL_ENV` = "__" ]; then
			local name=$(basename $(dirname $VIRTUAL_ENV))
		else
			local name=$(basename $VIRTUAL_ENV)
		fi
		PS1+=', '
		PS1+="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX$name$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
	fi

	# Timer: http://stackoverflow.com/questions/2704635/is-there-a-way-to-find-the-running-time-of-the-last-executed-command-in-the-shel
	if [[ $_elapsed[-1] -ne 0 ]]; then
		PS1+=', '
		PS1+="%{$fg[magenta]%}$_elapsed[-1]s%{$reset_color%}"
	fi

	# PID
	if [[ $! -ne 0 ]]; then
		PS1+=', '
		PS1+="%{$fg[yellow]%}PID:$!%{$reset_color%}"
	fi

	# Sudo: https://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
	CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
	if [ ${CAN_I_RUN_SUDO} -gt 0 ]
	then
		PS1+=', '
		PS1+="%{$fg_bold[red]%}SUDO%{$reset_color%}"
	fi

	PS1+="%{$fg[white]%}]: %{$reset_color%}% "
}

precmd_functions+=set_prompt

preexec () {
   (( ${#_elapsed[@]} > 1000 )) && _elapsed=(${_elapsed[@]: -1000})
   _start=$SECONDS
}

precmd () {
   (( _start >= 0 )) && _elapsed+=($(( SECONDS-_start )))
   _start=-1 
}
