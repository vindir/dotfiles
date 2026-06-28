# ~/.bash_logout                                         -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------

echo -en "\nduration: "
echo -e "`expr $SECONDS / 3600` hours `expr $SECONDS / 60` mins `expr $SECONDS % 60` secs\n"
sleep 5

if [ "$SHLVL" = 1 ] && [ -x /usr/bin/clear_console ]; then
    /usr/bin/clear_console -q
else
    clear
fi
