cli-app-menu-template
=====================

Simple CLI menu template. Scalable, can add sub-menus; add a new menu choice with just 1 comment and 1 function.

Format of menu
<Special menu item marker> <SPACE> #: <Application name> <SPACE> - <SPACE> <Description>.
#AAA df   - Display disk partition usage.
#AAA top  - Display processes in real time.
#AAA cal  - Display calendar
#AAA MORE - Sub-Menu of more choices.

Each Application name when chosen, calls a function f_<Application Name>.
i.e. "top" calls function "f_top".

Format of an application function
# +----------------------------------------+
# |               Function f_top           |
# +----------------------------------------+
#
#  Inputs: APP_NAME.
#    Uses: ERROR, INSTALL_ANS.
# Outputs: MENU_ITEM=-1.
#
f_top () {
      APP_NAME="top"
      #
} # End of function f_top
#


Functions can also be sub-menus

Format of "MORE" Sub-menu
# +----------------------------------------+
# |              Function f_more           |
# +----------------------------------------+
#
#  Inputs: THIS_FILE.
#    Uses: BBB, MAX.
# Outputs: ERROR, MENU_TITLE, DELIMITER.
#
f_more () {
      f_initvars_menu_app "BBB"
      until [ "$BBB" = "0" ]
      do    # Start of Main Menu until loop.
#BBB uname        - Display linux information.
#BBB who          - Display user information.
#BBB Edit History - Display Edit History of this script.
            #
            MENU_TITLE="Line-Command Sub-Menu"
            DELIMITER="#BBB" #BBB is 3rd field prevents awk from printing this line into menu options. 
            f_show_menu "$MENU_TITLE" "$DELIMITER" 
            read BBB
            f_menu_item_process $BBB  # Outputs $MENU_ITEM.
      done  # End of Main Menu until loop.
            #
      unset BBB MENU_ITEM  # Throw out this variable.
      #
} # End of function f_MORE
