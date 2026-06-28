# ~/.bashrc: executed by bash(1) for non-login shells.


# Source global definitions
if [ -f /etc/bashrc ]
then
	. /etc/bashrc
fi

# AutoScreen --------------------------------------------------------------------
#if [ "$SSH_TTY" ]; then
#  # If this is a remote session, then start screen
#  if [ "$TERM" != "screen" ]; then
#    echo -ne "${XTERM_SET_TITLE}screen for `whoami`@`hostname -s`${XTERM_END}"
#    echo -ne "${ITERM_SET_TAB}[`hostname -s`]${ITERM_END}"
#    screen -xRRU
#    if [ "$?" = "0" ]; then
#      reset
#      exit
#    fi
#  fi
#fi

