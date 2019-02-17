#
# ~/.bash_profile: Local configuration file for bash
#
# This is a cross-computer file, so it includes things that may already be set
# on certain machines.
#
# Some things obtained from https://github.com/mrzool/bash-sensible
#

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

### Script variables ###

# uname is restricted on some systems; default to Linux if we can't use it
if hash uname 2>/dev/null; then
   OSNAME=`uname`
else
   OSNAME="Linux"
fi

### Set up paths (only needed for broken Solaris systems) ###
if [ "$OSNAME" == "SunOS" ]; then
   export PATH="/usr/local/gnu/bin:/opt/csw/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/jdk/bin:/usr/java/bin:/usr/local/X11/bin:/opt/SUNWspro/bin:/usr/openwin/bin:/usr/ccs/bin:/usr/ucb:/usr/local/kde-3.2/bin"
   export LD_LIBRARY_PATH="/usr/local/gnu/lib:$LD_LIBRARY_PATH" # Fix python
fi

### Set up aliases ###
case "$OSNAME" in
   "Linux" )
   LSVER=`/bin/ls --version | head -n 1 | awk '{ print ($4<8.0?"0":"8") }'`
   if [ "$LSVER" -eq "8" ]; then
      alias ls="/bin/ls --color -shF --group-directories-first"
      alias ll="/bin/ls --color -lhF --group-directories-first"
   else
      alias ls="/bin/ls --color -shF"
      alias ll="/bin/ls --color -lhF"
   fi
   alias less="less -M"
   VERBOSEPS="ps xawf -eo pid,user,time,nice,tty,cgroup,args"
   ;;

   "SunOS" )
   alias ls="/usr/local/gnu/bin/ls --color -shF"
   alias ll="/usr/local/gnu/bin/ls --color -lhF"
   alias less="less -M"
   VERBOSEPS="ps -ef"
   ;;

   "OSF1" )
   alias ls="/usr/local/bin/cls --color -shF"
   alias ll="/usr/local/bin/cls --color -lhF"
   alias less="less -M"
   VERBOSEPS="ps -Af"
   ;;

   "CYGWIN_NT-5.1" )
   alias ls="/usr/bin/ls --color -shF"
   alias ll="/usr/bin/ls --color -lhF"
   alias less="less -M"
   VERBOSEPS="ps -af f"
   ;;

   "CYGWIN_NT-6.1-WOW64" )
   alias ls="/usr/bin/ls --color -shF"
   alias ll="/usr/bin/ls --color -lhF"
   alias less="less -M"
   VERBOSEPS="ps -alW"
   ;;
esac

# procps version 3 works differently than version 2
ps --version 2> /dev/null | grep -q -e "procps version 3"
if [ $? == 0 ]; then
   alias pps="ps -Af f"
else
   alias pps=$VERBOSEPS
fi

alias zextract="tar zxvf"
alias zcreate="tar zcvf"
alias more="less"
alias psgrep="pps | grep"
alias reload="source ~/.bashrc"
alias stack="dirs -l"

### Set up environment ###
# Some of these actually break Unicode support, hopefully they are no longer needed?
#export LESSCHARSET="latin1"
#export LESS="-R"
#export CHARSET="UTF-8"
#export LC_CTYPE="en_US.utf8"
#export LC_COLLATE="en_US.utf8"
export EDITOR="vim"
export CVS_RSH="ssh"
export HISTCONTROL="erasedups:ignoreboth" # don't put duplicate lines or lines starting with space in history
export HISTIGNORE="&:[ ]*:l[sl]:[bf]g:exit:history:clear" # ignore repeated, space-started, and casual commands
export HISTTIMEFORMAT="%F %T "
export HISTSIZE="1000" # larger history size
export HISTFILESIZE="4096" # larget history size
export PROMPT_COMMAND="history -a" # record each line to history as it gets issues

shopt -s cmdhist # enable multiline historization as a single line
shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # updated window size after every command
shopt -s cdspell # correct spelling errors in arguments to cd
if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
   shopt -s dirspell # correct spelling errors during tab-completion
fi

bind "set completion-ignore-case on" # perform file completion case-insensitive
bind "set completion-map-case on" # treat hyphens and underscores as equivalent
bind "set show-all-if-ambiguous on" # display matches for ambiguous patterns on first tab press

umask 022

if `which dircolors > /dev/null 2>&1`; then
   eval "`dircolors -b`"
fi
if `which mesg > /dev/null 2>&1`; then
   if [ -t 0 ]; then # verify stdin is a tty to avoid error messages via ssh
      mesg n
   fi
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -r /etc/bash_completion ]; then
   . /etc/bash_completion
fi

### Set up prompt ###
ARROW="▒"
JOBS=" ✶"
GREENBG="\[\e[30;42m\]"
GREENFG="\[\e[32;43m\]"
YELLOWBG="\[\e[30;43m\]"
YELLOWFG="\[\e[33;44m\]"
BLUEBG="\[\e[30;44m\]"
WHITE="\[\e[97m\]"
NORMAL="\[\e[0m\]"
TITLEBAR=""

### Only include titlebar for GUIs ###
### Also, only use fancy colors in GUIs ###
case "$TERM" in
   xterm*|terminator)
      TITLEBAR="\[\e]0;\u@\h:\w\007\]"
      GREENBG="\[\e[30;48;5;70m\]"
      GREENFG="\[\e[38;5;70;48;5;178m\]"
      YELLOWBG="\[\e[30;48;5;178m\]"
      YELLOWFG="\[\e[38;5;32;48;5;178m\]"
      BLUEBG="\[\e[30;48;5;32m\]"
esac

### Select the right date display method to use ###
if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
   export PS1="$TITLEBAR$GREENBG$ARROW \u$WHITE@$GREENBG\h $GREENFG$ARROW$YELLOWBG \w $YELLOWFG$ARROW$BLUEBG \$(date +\"%Y-%m-%d %H:%M:%S\") $ARROW$NORMAL\n\!$WHITE\\$ $NORMAL"
else
   export PS1="$TITLEBAR$GREENBG$ARROW \u$WHITE@$GREENBG\h\$([[ \$(jobs -l | wc -l) -gt 0 ]] && echo $JOBS) $GREENFG$ARROW$YELLOWBG \w $YELLOWFG$ARROW$BLUEBG \D{%Y-%m-%d %H:%M:%S} $ARROW$NORMAL\n\!$WHITE\\$ $NORMAL"
fi

### Load any custom-defined user settings ###
if [ -f ~/.bashrc.local ]; then
   source ~/.bashrc.local
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
   if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
   elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
   fi
fi

# Add in homeshick for dotfiles management
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
# Also include command completion for homeshick
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
