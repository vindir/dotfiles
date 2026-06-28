# ~/.bash_profile: executed by bash(1) for login shells.
# Supported by bash3.2+ on linux or mac

# A good portion of this base is originally from jacqui's profile on
# dotfiles.org, but includes other profiles I've pulled from and some
# of my own functions.

OS=`uname -s`

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.mac_bashprofile ]; then
   source ~/.mac_bashprofile
fi

# Color Handling ---------------------------------------------------------------
if [ $OS != "Darwin" ] ; then
    eval `dircolors -b` # set the basis for our LS_COLORS
fi
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1 
#LS_COLORS is not supported by the default ls command in OS-X
export LS_COLORS='di=1:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=35:*.rb=90'


# Colors to use later in interactive shell or scripts --------------------------
export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[1;30m'
export COLOR_GRAY_U='\e[1;30;4m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_LIGHT_GRAY_U='\e[0;37;4m'
alias colorslist="set | egrep 'COLOR_\w*'" # Lists all the colors, uses vars
                                           # in .bashrc_non-interactive


# Miscellaneous ----------------------------------------------------------------
umask 002
export HISTCONTROL=erasedups
export HISTIGNORE="pwd:ls:ls -lhtr:who:history:set:env:[bf]g:clear:exit"
export HISTSIZE=25000
export HISTFILESIZE=25000
export RSYNC_RSH=ssh
export PAGER=less
# Use UTF-8 Character Set
export LESSCHARSET=utf-8
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LANG=en_US.UTF-8

shopt -s histappend #history is appended on exit instead of overwritten
complete -cf sudo #sudo Auto Completion
shopt -u mailwarn #disable mail notification
unset MAILCHECK #disable mail notification

# SSH Auto Completion of Remote Hosts
SSH_COMPLETE=( $(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | egrep -v [0123456789]) )
complete -o default -W "${SSH_COMPLETE[*]}" ssh 


# Navigation -------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd .. ; cd ..'

# I got the following from, and mod'd it: http://www.macosxhints.com/article.php?story=20020716005123797
#    The following aliases (save & show) are for saving frequently used directories
#    You can save a directory using an abbreviation of your choosing. Eg. save ms
#    You can subsequently move to one of the saved directories by using cd with
#    the abbreviation you chose. Eg. cd ms  (Note that no '$' is necessary.)
if [ ! -f ~/.dirs ]; then  # if doesn't exist, create it
    touch ~/.dirs
fi

alias show='cat ~/.dirs'
save (){
    command sed "/!$/d" ~/.dirs > ~/.dirs1; \mv ~/.dirs1 ~/.dirs; echo "$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ; 
}
source ~/.dirs  # Initialization for the above 'save' facility: source the .sdirs file
shopt -s cdable_vars # set the bash option so that no '$' is required when using the above facility


# cvs config -------------------------------------------------------------------
export CVSEDITOR=vim
export CVS_RSH=ssh


# git config -------------------------------------------------------------------
if [ $OS = "Darwin" ] ; then
    export GIT_AUTHOR_EMAIL="`whoami`@`hostname -f`"
    export GIT_COMMITTER_EMAIL="`whoami`@`hostname -f`"
else
    export GIT_AUTHOR_EMAIL="`whoami`@`hostname --fqdn`"
    export GIT_COMMITTER_EMAIL="`whoami`@`hostname --fqdn`"
fi
alias gb="git branch"
alias gba="git branch -a"
alias gc="git commit -v"
alias gd="git diff | mate"
alias gl="git pull --rebase"
alias gp="git push origin HEAD"
alias gcp="git cherry-pick"
alias gst="git status"
alias ga="git add"
alias gr="git rm"
alias gu="git pull --rebase && git push origin HEAD"
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}


# svn config -------------------------------------------------------------------
export SV_USER='jowens'  # Change this to your username that you normally use on subversion (only if it is different from your logged in name)
export SVN_EDITOR='${EDITOR}'
alias svshowcommands="echo -e '${COLOR_BROWN}Available commands: 
   ${COLOR_GREEN}sv
   ${COLOR_GREEN}sv${COLOR_NC}help
   ${COLOR_GREEN}sv${COLOR_NC}import    ${COLOR_GRAY}Example: import ~/projects/my_local_folder http://svn.foo.com/bar
   ${COLOR_GREEN}sv${COLOR_NC}checkout  ${COLOR_GRAY}Example: svcheckout http://svn.foo.com/bar
   ${COLOR_GREEN}sv${COLOR_NC}status    
   ${COLOR_GREEN}sv${COLOR_NC}status${COLOR_GREEN}on${COLOR_NC}server
   ${COLOR_GREEN}sv${COLOR_NC}add       ${COLOR_GRAY}Example: svadd your_file
   ${COLOR_GREEN}sv${COLOR_NC}add${COLOR_GREEN}all${COLOR_NC}    ${COLOR_GRAY}Note: adds all files not in repository [recursively]
   ${COLOR_GREEN}sv${COLOR_NC}delete    ${COLOR_GRAY}Example: svdelete your_file
   ${COLOR_GREEN}sv${COLOR_NC}diff      ${COLOR_GRAY}Example: svdiff your_file
   ${COLOR_GREEN}sv${COLOR_NC}commit    ${COLOR_GRAY}Example: svcommit
   ${COLOR_GREEN}sv${COLOR_NC}update    ${COLOR_GRAY}Example: svupdate
   ${COLOR_GREEN}sv${COLOR_NC}get${COLOR_GREEN}info${COLOR_NC}   ${COLOR_GRAY}Example: svgetinfo your_file
   ${COLOR_GREEN}sv${COLOR_NC}blame     ${COLOR_GRAY}Example: svblame your_file
'"
   
alias sv='svn --username ${SV_USER}'
alias svimport='sv import'
alias svcheckout='sv checkout'
alias svstatus='sv status'
alias svupdate='sv update'
alias svstatusonserver='sv status --show-updates' # Show status here and on the server
alias svcommit='sv commit'
alias svadd='svn add'
alias svaddall='svn status | grep "^\?" | awk "{print \$2}" | xargs svn add'
alias svdelete='sv delete'
alias svhelp='svn help' 
alias svblame='sv blame'

svgetinfo (){
    sv info $@
    sv log $@
}


# Debian Package Management ----------------------------------------------------
#==> debian package management
alias -- dsearch="apt-cache search"
alias -- dshow="apt-cache show"
alias -- -install="apt-get install"
alias -- -remove="apt-get remove"
alias -- -update="apt-get update"
alias -- -upgrade="apt-get upgrade"
alias -- -source="dpkg -S"
alias -- -list="dpkg -l"
alias -- -files="dpkg -L"


# Miscellaneous Aliases --------------------------------------------------------
if [ $OS = "Darwin" ] ; then
    LS_OPTS=
else
    LS_OPTS="--color=auto -h"
fi

alias ls="ls $LS_OPTS"
alias ll="ls $LS_OPTS -l"
alias llt='ls $LS_OPTS -latr'
alias la='ls $LS_OPTS -a'
alias lla='ls $LS_OPTS -la'
alias g='grep -i --colour=auto'  # Case insensitive grep
alias f='find . -iname'
alias ducks='du -cksh * | sort -rn|head -11' #original version. broken but cute
alias ducks="du -k | sort -nr | cut -f2 | head -15 | xargs -d '\n' du -sh" # Lists folders and files sizes in the current folder
alias ducky="du --max-depth=1 -k * | sort -nr | cut -f2 | head -15 | xargs -d '\n' du -sh" # Lists folders and files sizes in the current folder
alias systail='tail -f /var/log/system.log'
alias m='less'
alias df='df -h'
alias vi='vim'
alias hst='set horizontal-scroll-mode on' #turns on line wrapping
alias hsf='set horizontal-scroll-mode off' #turns off line wrapping
alias wrapoff='echo -e "\e[?7l\c"' #turns off line wrapping
alias wrapon='echo -e "\e[?7h\c"' #turns on line wrapping
alias ssh='ssh -C'
alias diff='diff -urN'
alias showfuncs='typeset'
alias cdo="eject" #cdo = cd open
alias cdc="eject -t" #cdc = cd close 
alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"
alias mountedinfo='df -hT';
# Alias chmod commands
alias mx='chmod a+x'
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'

# Shows most used commands, cool little hack from:
# http://lifehacker.com/software/how-to/turbocharge-your-terminal-274317.php
alias profileme="history | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"

# shows a quick bandwidth reading for the machine
alias bw="/sbin/ifconfig eth0 | awk '/RX bytes/{print \$2 > \"/tmp/bytes\"}' FS=\"[:(]\" ;\
sleep 2; # Wait for 2 seconds, and then take the second reading..
/sbin/ifconfig eth0 | awk 'BEGIN{getline earlier < \"/tmp/bytes\"}\
/RX bytes/{print \"BW: \"(\$2-earlier)/(1024*2)\" KB/s, \"(\$2-earlier)/(1024*2000)\" MB/s\"}' \
FS=\"[:(]\""


# Terminal Setup ---------------------------------------------------------------
export EDITOR=vim
export VISUAL=vim
## set vi keybindings
set -o vi 
bind "set editing-mode vi"
bind "set keymap vi"
bind "set convert-meta on"
shopt -s expand_aliases #expands aliases for non-interactive shells
shopt -s hostcomplete #attempts to expand hostnames
shopt -s checkwinsize # After each command, resizes term to fit windows size
shopt -s cdspell #correct minor spelling errors in cd commands
shopt -s dotglob #allows files beginning with . to return in tab completion
shopt -s cmdhist #saves multi-line commands in single history entry
set -o noclobber #prevents shell redirection from overwriting files
set -o ignoreeof #prevents Ctrl-D from exiting the shell

stty -ixon #disable XON/XOFF flow control (^s/^q) 

# bash completion settings (actually, these are readline settings)
bind "set completion-ignore-case on" # note: bind used instead of sticking these in .inputrc
bind "set bell-style none" # no bell
bind "set show-all-if-ambiguous On" # show list automatically, without double tab
bind "set visible-stats on" # adds type indicator to completion items
# ^p to check for partial match in history
bind -m vi-insert "\C-p":dynamic-complete-history
# ^n to cycle through the list of partial matches
bind -m vi-insert "\C-n":menu-complete
# ^l to clear the screen
bind -m vi-insert "\C-l":clear-screen

# Turn on advanced bash completion if the file exists
# Get it here: http://www.caliban.org/bash/index.shtml#completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

shopt -s extglob #exglob gives better pattern matching
# Example: rpm -Uvh /usr/src/RPMS/!(*noarch*)
# Can Be Nested: ls -lad !(*.p@(df|s))
# ?(pattern-list)
# Matches zero or one occurrence of the given patterns
# *(pattern-list)
# Matches zero or more occurrences of the given patterns
# +(pattern-list)
# Matches one or more occurrences of the given patterns
# @(pattern-list)
# Matches exactly one of the given patterns
# !(pattern-list)
# Matches anything except one of the given patterns


# Miscellaneous Functions ------------------------------------------------------

#Needs to be changed to function
#alias searchbin="ls /{,usr/,usr/local/}bin/*"

# Simple spin function
spin ()
{
    echo -ne "${RED}-"
    echo -ne "${WHITE}\b|"
    echo -ne "${BLUE}\bx"
    sleep .02
    echo -ne "${RED}\b+${NC}"
}

# Push ssh authorized_keys to specified server
pushssh()
{
  ssh $1 "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub
}

# Push bash and vim configs to specified servers
pushdots()
{
    # Expects the first argument to be the remote username followed by a list
    # of servers to push the files to.
    ARGS=$@
    USER=${ARGS%% *}
    SERVERS=${ARGS##* }

    for SERVER in "$SERVERS"
    do
        scp .bash_profile .bash_logout .bashrc .vimrc $USER@$SERVER:
    done
}

scpsend ()
{
    #TODO: build function to simplify copying over files
    echo ""
}

netinfo ()
{
    echo "--------------- Network Information ---------------"
    echo -e "`/sbin/ifconfig 2>/dev/null | awk '!/127.0.0.1/ {print}' | \
              awk '/inet addr/ {print $2}' | \
              awk -F: '{print \"Net Addr: \"$2}'`"
    echo -e "`/sbin/ifconfig 2>/dev/null | awk '!/127.0.0.1/ {print}' | \
              awk '/Bcast/ {print $3}' | \
              awk -F: '{print \"Broadcast: \"$2}'`"
    echo -e "`/sbin/ifconfig 2>/dev/null | awk '!/127.0.0.1/ {print}' | \
              awk '/inet addr/ {print $4}' | \
              awk -F: '{print \"Netmask: \"$2}'`"
    # /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
}

##Get Load Average
_load ()
{
uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\)/\1/" -e "s/ //g"
}

##Set load color
load ()
{
    #load average stuff
    avg=$(_load) #original: $(_load) | sed 's/\.//')
    avg_int=`echo -n $avg | sed 's/\.//'`
    if [ $avg_int -gt 99 ]
    then
        echo -e ${COLOR_LIGHT_RED}${avg}
    elif [ $avg_int -gt 10 ]
    then
        echo -e ${COLOR_LIGHT_GREEN}${avg}
    else
        echo -e ${avg}
    fi
}

# Get Free RAM
_mem ()
{
free -m | grep 'buffers/cache' | awk '{print $4"M"}'
}

# Show Free RAM with Colored Statuses
mem ()
{
    avail=$(_mem)
    memcount=${avail%%M*}
    if [ "$memcount" -lt 500 ]
    then
        echo -e ${COLOR_PURPLE}${avail}
    elif [ "$memcount" -lt 100 ]
    then
        echo -e ${COLOR_LIGHT_RED}${avail}
    else
        echo -e ${COLOR_GREEN}${avail}
    fi
}

# backup specified file or directory
bu () {
    NAME=`whoami`
    if [ $OS = "Darwin" ] ; then
        HOMEDIR=${HOME}
    else
        HOMEDIR=`getent passwd "$NAME" | cut -d: -f 6`
    fi
    if [ ! -e "$HOMEDIR/.backup" ]
    then
        mkdir $HOMEDIR/.backup
    fi
    for object in "$@"
    do
       cp -r $object $HOMEDIR/.backup/`basename \
             $object`-`date +%Y%m%d%H%M`.backup
    done
}

# prevent exiting from top level shell unless now argument is used
function exit() {
    local -i BASE=1
    if [ $SHLVL -gt $BASE ]
    then
        builtin exit
    else
        if [ "$1" = "now" ]
        then
            builtin exit
        else
            echo "Please use 'exit now' if you want to leave this session!"
        fi
    fi
}

# Greps for a running process
psgrep() {
    if [ ! -z $1 ] ; then
        echo "Grepping for processes matching $1..."
        ps aux | grep $1 | grep -v grep
    else
        echo "!! Need name to grep for"
    fi
}

# Finds a files location and greps inside it
function locategrep
{
  if [ "${#}" != 2 ] ; then
    echo "Usage: locategrep [string to locate] [string to grep]";
    return 1;
  else
    echo "locate -i '${1}' | grep -i '${2}'";
    command locate -i '${1}' | grep -i '${2}';
  fi;
}

_noglob () {
    "$@"
    case "$shopts" in
        *noglob*) ;;
        *) set +f ;;
    esac
    unset shopts
}
alias noglob='shopts="$SHELLOPTS"; set -f; noglob_helper'

# improved version of bash calc
function _calc () {
    if [[ -x `which gawk` ]] ; then
        gawk -v CONVFMT="%12.2f" -v OFMT="%.9g"  "BEGIN { print $*; }"
    elif [[ -x `which bc` ]] ; then
        echo "$*" | bc -l
    else
        echo "Falling back to \$(( expr )), cannot handle floats."
        echo "$(( $* ))"
    fi
}
alias calc='noglob _calc'

# Fancy PWD display function
# The home directory (HOME) is replaced with a ~
# /home/me/stuff          -> ~/stuff               if USER=me
# /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20
bash_prompt_command() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=25
    # Indicate that there has been dir truncation
    local trunc_symbol=".."
    local dir=${PWD##*/}
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
    then
        NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi
}

# Extracts files from nearly any archive (like unfoo).
function extract() {
    echo "Extracting..."
    if [ -f $1 ]
    then
        case $1 in
            *.tbz2)    tar jpvxf $1 ;;
            *.tar.bz2) tar jpvxf $1 ;;
            *.bz2)     bunzip2 $1 ;;
            *.tar.gz)  tar zvxf $1 ;;
            *.gz)      gunzip $1 ;;
            *.tar)     tar vxf $1 ;;
            *.rar)     unrar x $1 ;;
            *.zip)     unzip $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1 ;;
            *)         echo "Don't know how to extract files from '$1'" ;;
        esac
    else
        echo "Usage: extract [filename]"
    fi
}

# point dump to extract since it's easier to type
function dump() {
    if [ -f $1 ]
    then
        extract $1
    else
        echo "Usage: extract [filename]"
    fi
}


# Prompts-----------------------------------------------------------------------

# Primary prompt with time and path (default)
export PS1="\[${COLOR_BROWN}\][\
\[${COLOR_LIGHT_GRAY_U}\]\
\$(date +%H:%M)\[${COLOR_BROWN}\]]\
 \[${COLOR_RED}\]\${NEW_PWD} >\
 \[${COLOR_WHITE}\]"

# Primary prompt with user, host, and path
#export PS1="\[${COLOR_GRAY}\]\u@\h \[${COLOR_GREEN}\]\w > \[${COLOR_NC}\]"

# Primary prompt with time, user, host, and path
#export PS1="\[${COLOR_BLUE}\][\
#\[${COLOR_LIGHT_GRAY}\]\$(date +%H:%M)\
#\[${COLOR_BLUE}\]]\
# \[${COLOR_GRAY}\]\u@\h\
# \[${COLOR_GREEN}\]\w >\
# \[${COLOR_WHITE}\]"

# This runs before the prompt and sets the title of the xterm* window.  If you
# set the title in the prompt weird wrapping errors occur on some systems, so
# this method is superior
export PROMPT_COMMAND='bash_prompt_command; echo -ne "\033]0;${USER}@${HOSTNAME%%.*} ${NEW_PWD}"; echo -ne "\007"'  # user@host path

export PS2='> '    # Secondary prompt
export PS3='#? '   # Prompt 3
export PS4='+'     # Prompt 4

# change the title of your xterm* window
function xtitle {
    if [ $1 = "default" ] ; then
        export PROMPT_COMMAND=$PROMPT_COMMAND_DEFAULT
    else
        PROMPT_COMMAND_DEFAULT=$PROMPT_COMMAND
        unset PROMPT_COMMAND
        echo -ne "\033]0;$1\007" 
    fi
}


# Prompts-----------------------------------------------------------------------

function whimsical_motd ()
{
    echo -en "${COLOR_WHITE}"; cal ;
    # Display fortune at login
    if [ -x /usr/games/fortune ]
    then
        echo ""
        /usr/games/fortune -s
        echo ""
    fi
    #Display the Discordian/Erisian date for the day
    if [ -x /usr/bin/ddate ]
    then
        /usr/bin/ddate
    fi
}

function functional_motd ()
{
    clear
    HOSTNAME="`hostname`"
    WELCOMESTRING="welcome to `hostname`!"
    SEQLEN="`expr \( 78 - ${#WELCOMESTRING} \) / 2`"
    for i in `seq 1 $SEQLEN` ; do spin; done
    echo -ne "${COLOR_WHITE} $WELCOMESTRING ${COLOR_NC}"
    for i in `seq 1 $SEQLEN` ; do spin; done
    echo ""
    echo -ne "${COLOR_LIGHT_GRAY}";netinfo;
    echo -e "${COLOR_WHITE}--------------- Mounted Disk Info -----------------"
    echo -ne "${COLOR_WHITE}"
    mountedinfo
    #echo -en "${COLOR_WHITE}"; cal ;
    echo -e "${COLOR_BROWN}Kernel Information: " `uname -smr`;
    echo -ne "${COLOR_BROWN}Uptime for this computer is ";uptime | awk /'up/ {print $3,$4}'
    GOODBYESTRING="Hello $USER today is `date`"
    SEQLEN="`expr \( 78 - ${#GOODBYESTRING} \) / 2`"
    for i in `seq 1 $SEQLEN`; do spin; done
    echo -ne "${COLOR_WHITE} ${GOODBYESTRING} ${COLOR_NC}";
    for i in `seq 1 $SEQLEN`; do spin; done
    echo "";
}
functional_motd #use functional welcome message
#whimsical_motd #use whimsical welcome message

# Envision Settings ------------------------------------------------------------
alias lef='less /opt/switchlogs/envision/envision.log'
alias log32='tail -f /opt/switchlogs/envision/envision'
alias llog32='less /opt/switchlogs/envision/envision.log'
alias s32='cd /opt/switchapps/env_3-2/bin; sudo ../sbin/ss'
alias k32='cd /opt/switchapps/env_3-2/bin; sudo ../sbin/ks'
# CDPATH sets the search path for the cd command
export CDPATH=.:~:/opt/switchlogs:/opt/switchapps:/opt/switchapps/env_3-2


# ------------------------------------------------------------------------------

