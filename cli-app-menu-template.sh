#!/bin/bash
#
#@ Brief Description
#@ This menu is extremely scaleable and can have nested sub-menus.
#@ Each menu choice simply calls a function in the script.
#@ Add a new menu choice by adding a comment in the script along
#@ with the corresponding function.
#@
#@ Edit History
#@ 2014-12-26 - f_menu_item_valid used case statements for pattern matching.
#@ 2014-12-12 - Create script using rsync_data.sh as template.
#@ After each edit made, update Edit History and version (date stamp string).
#
VERSION="2014-12-26 12:28"
THIS_FILE="cli-app-menu_template.sh"
#
# +----------------------------------------+
# |      Function f_initvars_menu_app      |
# +----------------------------------------+
#
#  Inputs: $1=Until-Loop variable.
#    Uses: X, INITVAR.
# Outputs: APP_NAME, MENU_ITEM, ERROR.
#
f_initvars_menu_app () {
      echo $(tput bold) # Display bold font for all menus.
      ERROR=0        # Initialize to 0 to indicate success at running last
                     # command.
      #
      # Initialize variables to "" or null.
      for INIT_VAR in APP_NAME
      do
          eval $INIT_VAR="" # eval sets the variables to "" or null.
      done
      #
      # Initialize variables to -1 to force looping in until loop(s).
      for INIT_VAR in MENU_ITEM $1
      do
          eval $INIT_VAR=-1 # eval sets the variables to "-1".
      done
      unset X
      #
} # End of function f_initvars_menu_app
#
# +----------------------------------------+
# |         Function f_script_path         |
# +----------------------------------------+
#
#  Inputs: $BASH_SOURCE (System variable).
#    Uses: None.
# Outputs: SCRIPT_PATH.
#
f_script_path () {
      # BASH_SOURCE[0] gives the filename of the script.
      # dirname "{$BASH_SOURCE[0]}" gives the directory of the script
      # Execute commands: cd <script directory> and then pwd
      # to get the directory of the script.
      # NOTE: This code does not work with symlinks in directory path.
      #
      SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
      #
} # End of function f_script_path
#
# +----------------------------------------+
# |      Function f_test_environment       |
# +----------------------------------------+
#
#  Inputs: $BASH_VERSION (System variable).
#    Uses: None.
# Outputs: None.
#
f_test_environment () {
      # Set default colors in case configuration file is not readable
      # or does not exist.
      FCOLOR="Green" ; BCOLOR="Black" ; UCOLOR="" ; ECOLOR="Red"
      #
      # Test the environment. Are you in the BASH environment?
      # $BASH_VERSION is null if you are not in the BASH environment.
      # Typing "sh" at the CLI may invoke a different shell other than BASH.
      if [ "$BASH_VERSION" = '' ]; then
          echo $(tput setaf 1) # Set font to color red.
          echo "Restart this script by typing:"
          echo "\"bash $THIS_FILE\""
          echo "at the command line prompt (without the quotation marks)."
          echo
          echo "This script needs a BASH environment to run properly."
          echo -n $(tput sgr0) # Set font to normal color.
          f_press_enter_key_to_continue
      fi
      #
} # End of function f_test_environment
#
# +----------------------------------------+
# |            Function f_abort            |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: None.
#
f_abort() {
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
    #
} # End of function f_abort
#
# +----------------------------------------+
# | Function f_press_enter_key_to_continue |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: X.
# Outputs: None.
#
f_press_enter_key_to_continue () { # Display message and wait for user input.
      echo
      echo -n "Press '"Enter"' key to continue."
      read X
      unset X  # Throw out this variable.
      #
} # End of function f_press_enter_key_to_continue
#
# +----------------------------------------+
# |          Function f_show_menu          |
# +----------------------------------------+
#
#  Inputs: MENU_TITLE, DELIMITER, MAINMENU_DIR, THIS_FILE, MAX.
#    Uses: X, XNUM, XXSTR, XSTR.
# Outputs: MAX, XNUM.
#
f_show_menu () { # $1=$MENU_TITLE $2=$DELIMITER
      MENU_TITLE=$1 ; DELIMITER=$2
      THIS_DIR=$MAINMENU_DIR  # Set $THIS_DIR to location of Main Menu.
      clear  # Blank the screen.
      echo -n $(tput bold)
      echo "--- $MENU_TITLE ---"
      echo
      if [ "$DELIMITER" = "#AAA" ] ; then #AAA This 3rd field prevents awk from printing this line into menu items.
         echo "0 - Quit to command line prompt." # Option for Main Menu only.
      # Display message for Application Category Menu, Configuration Menu.
      elif [ "$DELIMITER" = "#AAB" ] || [ "$DELIMITER" = "#AAC" ] || [ "$DELIMITER" = "#AAD" ] ; then
         echo "0 - Return to Main Menu." # Option for Application Category, Configuration Menus.
      else
         echo "0 - Return to previous menu." # Option for all other sub-menus.
      fi
      #
      # Calculate $MAX, the number of menu items using grep -c(ount) option.
      # Count number of lines containing special comment marker string to get
      # maximum item number.
      #
      MAX=$(grep $DELIMITER -c $THIS_DIR/$THIS_FILE)
      #
      # Subtract 1 since the line DELIMITER=<string> contains the 
      # special comment marker but is not part of menu display.
      #
      MAX=$((MAX=$MAX-1))
      #
      # Cannot use "MAX=$MAX-1", since if MAX=12 echo $MAX shows "12-1" not "11".
      #
      # The following command awk '{<if condition>{print field}}
      # will print the menu items. The command automatically calculates the
      # menu option numbers for you.
      #
      # if statement conditional "($2&&!$3)":
      # Since the $DELIMITER is the special comment marker, then:
      # if there is 1 marker (2 fields) then awk will print the menu item.
      # if there are 2 markers (3 fields), then awk will not print anything.
      # This prevents the lines of code which set the $ DELIMITER variable from
      # being printed as a menu item, because they purposely have 2 markers.
      #
      # The menu option numbers are incremented using a "let" command.
      # First set XNUM=0 then in the for-loop, let "XNUM++".
      # 
      # Both Application Category Menu and Sofware Module Manager Menu
      # indicate active/inactive modules with the use of differing fonts.
      # However, both menus use the same $DELIMITER="#AAB" with only the menu title changed.
      # All other menus simply use bold font.
      #
      #All other application/sub-menus display menu items in default bold font.
      echo -n $(tput bold)
      awk -F $DELIMITER '{if ($2&&!$3){print 1+XNUM++" -"$2;}}' $THIS_DIR/$THIS_FILE
      #
      f_choice_array  # Create array to handle numeric answer to menu choices.
                      # Caution: Also uses $XNUM which is used in for loop above.
                      #
      case $DELIMITER in
           # Main Menu.
           "#AAA") #AAA This 3rd field prevents awk from printing this line into menu items.
           echo
           echo "'0', (Q)uit, to quit this script."
           ;;
           # Sub-menus called from Main Menu.
           "#AAB" | "#AAC" | "#AAD")
           echo -n $(tput bold)  # Needed if last module in list is in normal (not bold) font.
           echo
           echo "'0', (R)eturn, to go back to the Main Menu."
           ;;
      esac
      echo
      echo -n "Enter 0 to $MAX or letters: " # echo -n supresses line-feed.
      #
} # End of function f_show_menu
#
# +----------------------------------------+
# |         Function f_choice_array        |
# +----------------------------------------+
#
#  Inputs: DELIMITER, THIS_FILE.
#    Uses: XNUM, XSTR
# Outputs: CHOICE[$XNUM]
#
f_choice_array () {
      # Create array to handle numeric answer to menu choices.
      # Array Name[index]=Name of menu item (up to 2 words)
      #     CHOICE[$XNUM]=<1st word><space><2nd word>
      #     CHOICE[1]="First choice"
      #     CHOICE[2]="Second choice"
      #
      # The array elements need only the first one or two words of the
      # application name for function f_menu_item_valid to find a match
      # between the numeric answer to the menu choice and the corresponding
      # application name.
      #
      # declare -A CHOICE  # Commented out; do not need to declare the array.
      #
      unset CHOICE  # Throw out this variable.
      XNUM=1 # Initialize XNUM.
      #
      # 1. The 1st awk:
      #    if-statement conditional "($2&&!$3)":
      #    Since the $DELIMITER is the special comment marker, then:
      #    if there is 1 marker (2 fields) then awk will print the 2nd field.
      #    if there are 2 markers (3 fields), then awk will not print anything.
      #    This prevents the lines of code which set the $ DELIMITER variable
      #    from being printed as a menu item, since they have 2 markers.
      #
      # 2. The 2nd awk:
      #    Prints the name of the menu item but not the description.
      #
      # 3. The 3rd awk:
      #    If the name of the menu item is 2 or more words, just print the
      #    first 2 words into array CHOICE[$XNUM] which is sufficient for case
      #    pattern matching on that menu item choice.
      #
      #    Allow app names consisting of 2 words. i.e. "ip addr", "ip route".
      #    The <space> between the words needs a substitution { print $1"%"$2 }
      #    of a "%" for the <space> so awk will not separate the words into 2
      #    different menu items, rather than 1 menu item having 2 words.
      # 
      #    Set XSTR to first two words (delimited by "%" of menu choice name).
      #    Example: Main menu item, "Help and Features"
      #    If not, CHOICE[n]="Help", CHOICE[n+1]="and"
      #    rather than CHOICE[n]="Help and" (after substituting <space> for "%").
      #                    
      for XSTR in `awk -F $DELIMITER '{ if ( $2&&!$3 ) { print $2 } }' $THIS_DIR/$THIS_FILE | awk -F " - " '{ print $1 }' | awk '{ if ( $2 ) { print $1"%"$2 } else {print $1 } }'` # Use back-ticks to redirect, not single quotes.
      #
      # When creating CHOICE array, example: change XSTR="Help%and" to "Help and".
      do
           XSTR=${XSTR/[%]/ }    # Substitute <space> for "%" to restore name.
           CHOICE[$XNUM]=$XSTR   # 
           XNUM=`expr $XNUM + 1` # Use back-ticks to redirect, not single quotes.
      done
      #
      unset XSTR  # Throw out this variable.
      #
} # End of f_choice_array
#
# +----------------------------------------+
# |      Function f_menu_item_process      |
# +----------------------------------------+
#
#  Inputs: $*, CHOICE[$MENU_ITEM], MAX.
#          Where "$*" is the complete user-entered string passed as a set of arguments.
#    Uses: None.
# Outputs: None.
#
f_menu_item_process () {
      #
      # 1. After menu is displayed, process user-entered string (menu-item selection or any user-input).
      # 2. Did user enter command to exit menu? Yes, exit menu.
      # 4. Is user-input a valid choice (menu item option)? No, trap bad responses and re-display menu.
      # 5. Run function f_<APP_NAME> derived from user-input.
      # 6. Redisplay menu.
      #
      MENU_ITEM=$*  # The complete user-entered string passed as a set of arguments.
                    # i.e. "man <appname>, "<appname> --help" "<web browser><OPTIONS><URL>"
                    #
      case $MENU_ITEM in
           # Main Menu item option "Quit" to exit.
           0 | [Qq] | [Qq][Uu] | [Qq][Uu][Ii] | [Qq][Uu][Ii][Tt])
           if [ "$DELIMITER" = "#AAA" ] ; then  #AAA This 3rd field prevents awk from printing this line into menu items.
              MENU_ITEM=0
           fi
           ;;
           0 | [Rr] | [Rr][Ee] | [Rr][Ee][Tt] | [Rr][Ee][Tt][Uu]*)
           if [ "$DELIMITER" != "#AAA" ] ; then  #AAA This 3rd field prevents awk from printing this line into menu items.
              MENU_ITEM=0
           fi
           ;;
           [1-9] | [1-9][0-9]) # Change MENU_ITEM from a number to an alpha string.
           if [  "$MENU_ITEM" -ge 1 -a "$MENU_ITEM" -le $MAX ] ; then
              MENU_ITEM=${CHOICE[$MENU_ITEM]} #MENU_ITEM now is an alpha string.
           fi
           ;;
      esac
      #
      if [ "$MENU_ITEM" != 0 ] && [ "$MENU_ITEM" != -1 ] && [ -n "$MENU_ITEM" ] ; then
         # Is MENU_ITEM a valid choice?
         f_menu_item_valid # APP_NAME="" for invalid name.
                           # APP_NAME=$MENU_ITEM_NAME for valid name.
         #
         if [ -n "$APP_NAME" ] ; then # if $MENU_ITEM is a valid choice.
            #
            # Run application program.
            f_application_run
            #
            MENU_ITEM_NAME="" # Null so f_application_run is not run twice
            APP_NAME=""       # when trying to exit sub-menus. It's a tricky loop. 
                                # Also prevents checking for Quit Clause.
         fi
      fi
      #
      if [ "$MENU_ITEM" = "0" ] ; then # Force quit from main menu.
         case $DELIMITER in
              "#AAA")  #AAA This 3rd field prevents awk from printing this line into menu items.
              AAA=0
              ;;
              "#BBB")  #BBB This 3rd field prevents awk from printing this line into menu items.
              BBB=0
              ;;
         esac
      fi
      unset X DELIM RUN MENU_ITEM
      #
} # End of function f_menu_item_process
#
# +----------------------------------------+
# |       Function f_menu_item_valid       |
# +----------------------------------------+
#
#  Inputs: DELIMITER, THIS_FILE, MENU_ITEM.
#    Uses: XNUM, MENU_ITEM, MENU_ITEM_NAME.
# Outputs: MENU_ITEM, MENU_ITEM_NAME, APP_NAME. (If invalid, then APPNAME is null).
#
f_menu_item_valid () {
      # Get application name from menu.
      XNUM=1
      APP_NAME="" # Set application name to null value.
      # Cycle through entire CHOICE[$XNUM] array to find matching $MENU_ITEM_NAME.
      while [ $XNUM -ge 1 -a $XNUM -le $MAX ]
      do
            if [[ ! "$MENU_ITEM" == *" -"* ]] ; then
               # Convert to lower-case.
               MENU_ITEM=$(echo $MENU_ITEM | tr '[:upper:]' '[:lower:]')
            fi
            # Set (next) MENU_ITEM_NAME from CHOICE array.
            MENU_ITEM_NAME=${CHOICE[$XNUM]}
            # Convert MENU_ITEM_NAME to lower-case. (Sub-menus choice "MORE..." are in upper-case).
            MENU_ITEM_NAME=$(echo $MENU_ITEM_NAME | tr '[:upper:]' '[:lower:]')
            #
            case $MENU_ITEM in
                 [1-9] | [1-9][1-9]| [1-9][1-9][1-9])
                 # User wants to mark the application as a "Favorite" application.
                 # Put the application as a menu item in the "Favorites" menu.
                 # Valid choice so force exit from While-loop.
                 f_favorite_app_add
                 let XNUM=$MAX+1
                 ;;
                 "sudo "$MENU_ITEM_NAME*)
                 # Valid choice, contains $MENU_ITEM_NAME after "sudo".
                 # This pattern matching statement will allow any other sudo formats
                 # i.e. links web browser:
                 #      "sudo links -width 80 -driver atheos -html-images 0".
                 #
                 APP_NAME=$MENU_ITEM
                 # Valid choice so force exit from While-loop.
                 let XNUM=$MAX+1
                 ;;
                 $MENU_ITEM_NAME" "*)
                 # Does MENU_ITEM contain MENU_ITEM_NAME? 
                 # i.e. "nslookup www.distrowatch.com" contains "nslookup "
                 #                                         ("nslookup"<space>).
                 # i.e. "apt-file" does not contain "apt " ( "apt"<SPACE> ).
                 # elif [[ "$MENU_ITEM" == "$MENU_ITEM_NAME "* ]] ; then 
                 # Valid choice, extract APP_NAME.
                 APP_NAME=$MENU_ITEM
                 let XNUM=$MAX+1  # Valid choice so force exit
                                  # from While-loop.
                 ;;
            esac
            #
            case $MENU_ITEM_NAME in
                 $MENU_ITEM*)
                 # Does MENU_ITEM_NAME contain MENU_ITEM?
                 # i.e. "nslookup" contains "nsl"*.
                 MENU_ITEM=$MENU_ITEM_NAME
                 APP_NAME=$MENU_ITEM_NAME
                 let XNUM=$MAX+1  # Valid choice so force exit
                                  # from While-loop.
                 ;;
            esac
            #
            if [ XNUM != $MAX+1 ] ; then
               let XNUM++  # Not valid, try next menu item, force stay in
                           # menu loop.
            fi
            #
            APP_NAME=${APP_NAME/ /_}    # Substitute "<underscore>" for "<space>" to derive function name.
      done
      #
      export MENU_ITEM MENU_ITEM_NAME APP_NAME
      unset XNUM
      #
} # End of function f_menu_item_valid
#
# +----------------------------------------+
# |       Function f_application_run       |
# +----------------------------------------+
#
#  Inputs: APP_NAME, MENU_ITEM.
#    Uses: ERROR.
# Outputs: MENU_ITEM=-1.
#
f_application_run () {
      #
      # 1. Clear screen.
      # 2. Run application.
      #
      clear # Blank the screen.
      #
      f_$APP_NAME # Set $APP_NAME command with <Application name> <OPTIONS> <PARAMETERS>.
      #
      if [ "$MENU_ITEM" != 0 ] && [ "$MENU_ITEM" != -1 ] && [ -n "$MENU_ITEM" ] ; then
         $APP_NAME  # Run application command.
         #
         f_press_enter_key_to_continue
      fi
      #
      ERROR=$? # Save error flag condition.
      case $ERROR in
           0)  #No error, successful run.
           ;;
           127)  # Error code 127 means application is not installed.
           echo
           echo "***Application is not installed.***"
           echo
           ;;
      esac
      #
      MENU_ITEM=-1 # Force stay in menu until loop.
      # Convert string to integer -1. Also indicates valid menu choice.
      #
} # End of function f_application_run
#
# +----------------------------------------+
# |             Function f_df              |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_df () {
      APP_NAME="df -hT"
      #
} # End of function f_df
#
# +----------------------------------------+
# |               Function f_top           |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_top () {
      APP_NAME="top"
      #
} # End of function f_top
#
# +----------------------------------------+
# |              Function f_cal            |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_cal () {
      APP_NAME="cal"
      #
} # End of function f_cal
#
# +----------------------------------------+
# |             Function f_uname           |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_uname () {
      APP_NAME="uname -a"
      #
} # End of function f_uname
#
# +----------------------------------------+
# |              Function f_who            |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_who () {
      APP_NAME="who"
      #
} # End of function f_who
#
# +----------------------------------------+
# |         Function f_edit_history        |
# +----------------------------------------+
#
#  Inputs: None.
#    Uses: None.
# Outputs: APP_NAME.
#
f_edit_history () {
      clear # Blank the screen.
      # Display Help (all lines beginning with "#@" but do not print "#@").
      # sed substitutes null for "#@" at the beginning of each line
      # so it is not printed.
      # less -P customizes prompt for
      # %f <FILENAME> page <num> of <pages> (Spacebar, PgUp/PgDn . . .)
      sed -n 's/^#@//'p $THIS_DIR/$THIS_FILE | less -P '(Spacebar, PgUp/PgDn, Up/Dn arrows, press q to quit)'
      #
      # Set APP_NAME to no-op "dummy command" so nothing is run after this function is done.
      APP_NAME=":"
      #
} # End of function f_edit_history
#
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
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
# If an error occurs, the f_abort() function will be called.
# trap 'f_abort' 0
# set -e
#
# Set SCRIPT_PATH to directory path of script.
f_script_path
MAINMENU_DIR=$SCRIPT_PATH
#
# Test for BASH environment.
f_test_environment
#
# **************************************
# ***           Main Menu            ***
# **************************************
#
#  Inputs: THIS_FILE, REVISION, REVDATE.
#    Uses: AAA, MAX.
# Outputs: ERROR, MENU_TITLE, DELIMITER.
#
      f_initvars_menu_app "AAA"
      until [ "$AAA" = "0" ]
      do    # Start of Main Menu until loop.
#AAA df   - Display disk partition usage.
#AAA top  - Display processes in real time.
#AAA cal  - Display calendar
#AAA MORE - Sub-Menu of more choices.
            #
            MENU_TITLE="Line-Command Menu Template"
            DELIMITER="#AAA" #AAA This 3rd field prevents awk from printing this line into menu options. 
            f_show_menu "$MENU_TITLE" "$DELIMITER" 
            read AAA
            f_menu_item_process $AAA  # Outputs $MENU_ITEM.
      done  # End of Main Menu until loop.
            #
      unset AAA MENU_ITEM  # Throw out this variable.
      exit 0  # This cleanly closes the process generated by #!bin/bash. 
              # Otherwise every time this script is run, another instance of
              # process /bin/bash is created using up resources.
# all dun dun noodles.
#
