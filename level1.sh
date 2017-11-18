#!/bin/bash
drawborder() {
   # Draw top
   tput setf 6
   tput cup $FIRSTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ];
   do
      printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   # Draw sides
   x=$FIRSTROW
   while [ "$x" -le "$LASTROW" ];
   do
      tput cup $x $FIRSTCOL; printf %b "$WALLCHAR"
      tput cup $x $LASTCOL; printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   # Draw bottom
   tput cup $LASTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ];
   do
      printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done
   tput setf 9

}

drawborder2() {
   # Draw top
   tput setf 6
   tput cup $FIRSTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ];
   do
      printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   # Draw sides
   x=$FIRSTROW
   while [ "$x" -le "$LASTROW" ];
   do
      tput cup $x $FIRSTCOL; printf %b "$WALLCHAR"
      tput cup $x $LASTCOL; printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   # Draw bottom
   tput cup $LASTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ];
   do
      printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done
   tput setf 9

#draw obstacles
   tput setf 6
   R1a=9
   C1a=5

   tput cup $R1a $C1a
   x=$C1a
   while [ "$x" -le "$LASTCOL" ];
   do
      printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   R1b=12
   C1b=6
   x=$R1b
   while [ "$x" -le "$LASTROW" ];
   do
      tput cup $x $C1b; printf %b "$WALLCHAR"
      tput cup $x $LASTCOL; printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done

   R1c=3
   C1c=25
   LRc=7
   x=$R1c
   while [ "$x" -le "$LRc" ];
   do
      tput cup $x $C1c; printf %b "$WALLCHAR"
      tput cup $x $LASTCOL; printf %b "$WALLCHAR"
      x=$(( $x + 1 ));
   done
}

TPUT(){ echo -en "\033[${1};${2}H";} 
COLPUT(){ echo -en "\033[${1}G";} 

apple() {
   # Pick coordinates within the game area
   APPLEX=$[( $RANDOM % ( $[ $AREAMAXX - $AREAMINX ] + 1 ) ) + $AREAMINX ]
   APPLEY=$[( $RANDOM % ( $[ $AREAMAXY - $AREAMINY ] + 1 ) ) + $AREAMINY ]
}

drawapple() {
   # Check we haven't picked an occupied space
   LASTEL=$(( ${#LASTPOSX[@]} - 1 ))
   x=0
   apple
   while [ "$x" -le "$LASTEL" ];
   do
      if [ "$APPLEX" = "${LASTPOSX[$x]}" ] && [ "$APPLEY" = "${LASTPOSY[$x]}" ];
      then
         # Invalid coords... in use
         x=0
         apple
      else
         x=$(( $x + 1 ))
      fi
   done
   tput setf 4
   tput cup $APPLEY $APPLEX
   printf %b "$APPLECHAR"
   tput setf 9
}

growsnake() {
   # Pad out the arrays with oldest position 3 times to make snake bigger
   LASTPOSX=( ${LASTPOSX[0]} ${LASTPOSX[0]} ${LASTPOSX[0]} ${LASTPOSX[@]} )
   LASTPOSY=( ${LASTPOSY[0]} ${LASTPOSY[0]} ${LASTPOSY[0]} ${LASTPOSY[@]} )
   RET=1
   while [ "$RET" -eq "1" ];
   do
      apple
      RET=$?
   done
   drawapple
}
move2()
{
   case "$DIRECTION" in
      u) POSY=$(( $POSY - 1 ));;
      d) POSY=$(( $POSY + 1 ));;
      l) POSX=$(( $POSX - 1 ));;
      r) POSX=$(( $POSX + 1 ));;
   esac

   # Collision detection
   ( sleep $DELAY && kill -ALRM $$ ) &
   if [ "$POSX" -le "$FIRSTCOL" ] || [ "$POSX" -ge "$LASTCOL" ] ; then
      tput cup $(( $LASTROW + 1 )) 0
      stty echo
      echo " OUCH!! YOU BUMPED INTO A WALL"
      gameover
   elif [ "$POSY" -le "$FIRSTROW" ] || [ "$POSY" -ge "$LASTROW" ] ; then
      tput cup $(( $LASTROW + 1 )) 0
      stty echo
      echo " OUCH!YOU BUMPED INTO A WALL"
      gameover
   elif [ $POSY -eq $R1a ] && [ $POSX -ge $C1a ] ; then
       tput cup $(( $LASTROW + 1 )) 0
         echo "AAAAAHHHHHH!!! YOU BUMPED INTO THE WALL!!!"
         gameover 
   elif [ $POSY -ge $R1b ] && [ $POSX -eq $C1b ] ; then
       tput cup $(( $LASTROW + 1 )) 0
         echo "AAAAAHHHHHH!!! YOU BUMPED INTO THE WALL!!!"
         gameover
   elif [ $POSY -ge $R1c ] && [ $POSX -eq $C1c ] && [ $POSY -le $LRc ] ; then
       tput cup $(( $LASTROW + 1 )) 0
         echo "AAAAAHHHHHH!!! YOU BUMPED INTO THE WALL!!!"
         gameover
      fi
     

    
   # Get Last Element of Array ref
   LASTEL=$(( ${#LASTPOSX[@]} - 1 ))
   #tput cup $ROWS 0
   #printf "LASTEL: $LASTEL"

   x=1 # set starting element to 1 as pos 0 should be undrawn further down (end of tail)
   while [ "$x" -le "$LASTEL" ];
   do
      if [ "$POSX" = "${LASTPOSX[$x]}" ] && [ "$POSY" = "${LASTPOSY[$x]}" ];
      then
         tput cup $(( $LASTROW + 1 )) 0
         echo " YIKES!Looks like you ate yourself!"
         gameover
      fi
      x=$(( $x + 1 ))
   done

   # clear the oldest position on screen
   tput cup ${LASTPOSY[0]} ${LASTPOSX[0]}
   printf " "

   # truncate position history by 1 (get rid of oldest)
   LASTPOSX=( `echo "${LASTPOSX[@]}" | cut -d " " -f 2-` $POSX )
   LASTPOSY=( `echo "${LASTPOSY[@]}" | cut -d " " -f 2-` $POSY )
   tput cup 1 10
   #echo "LASTPOSX array ${LASTPOSX[@]} LASTPOSY array ${LASTPOSY[@]}"
   tput cup 2 10
   echo "SIZE=${#LASTPOSX[@]}"

   # update position history (add last to highest val)
   LASTPOSX[$LASTEL]=$POSX
   LASTPOSY[$LASTEL]=$POSY

   # plot new position
    tput setf 2
   tput cup $POSY $POSX
   printf %b "$SNAKECHAR"
   tput setf 9

   # Check if we hit an apple
   if [ "$POSX" -eq "$APPLEX" ] && [ "$POSY" -eq "$APPLEY" ]; then
      growsnake
      updatescore 10
       
   fi
}

move() {
   case "$DIRECTION" in
      u) POSY=$(( $POSY - 1 ));;
      d) POSY=$(( $POSY + 1 ));;
      l) POSX=$(( $POSX - 1 ));;
      r) POSX=$(( $POSX + 1 ));;
   esac

   # Collision detection
   ( sleep $DELAY && kill -ALRM $$ ) &
   if [ "$POSX" -le "$FIRSTCOL" ] || [ "$POSX" -ge "$LASTCOL" ] ; then
      tput cup $(( $LASTROW + 1 )) 0
      stty echo
      echo " OUCH!! YOU BUMPED INTO A WALL"
      gameover
   elif [ "$POSY" -le "$FIRSTROW" ] || [ "$POSY" -ge "$LASTROW" ] ; then
      tput cup $(( $LASTROW + 1 )) 0
      stty echo
      echo " OUCH!YOU BUMPED INTO A WALL"
      gameover

  fi
   

   # Get Last Element of Array ref
   LASTEL=$(( ${#LASTPOSX[@]} - 1 ))
   #tput cup $ROWS 0
   #printf "LASTEL: $LASTEL"

   x=1 # set starting element to 1 as pos 0 should be undrawn further down (end of tail)
   while [ "$x" -le "$LASTEL" ];
   do
      if [ "$POSX" = "${LASTPOSX[$x]}" ] && [ "$POSY" = "${LASTPOSY[$x]}" ];
      then
         tput cup $(( $LASTROW + 1 )) 0
         echo " YIKES!Looks like you ate yourself!"
         gameover
      fi
      x=$(( $x + 1 ))
   done

   # clear the oldest position on screen
   tput cup ${LASTPOSY[0]} ${LASTPOSX[0]}
   printf " "

   # truncate position history by 1 (get rid of oldest)
   LASTPOSX=( `echo "${LASTPOSX[@]}" | cut -d " " -f 2-` $POSX )
   LASTPOSY=( `echo "${LASTPOSY[@]}" | cut -d " " -f 2-` $POSY )
   tput cup 1 10
   #echo "LASTPOSX array ${LASTPOSX[@]} LASTPOSY array ${LASTPOSY[@]}"
   tput cup 2 10
   echo "SIZE=${#LASTPOSX[@]}"

   # update position history (add last to highest val)
   LASTPOSX[$LASTEL]=$POSX
   LASTPOSY[$LASTEL]=$POSY

   # plot new position
   tput setf 2
   tput cup $POSY $POSX
   printf %b "$SNAKECHAR"
   tput setf 9

   # Check if we hit an apple
   if [ "$POSX" -eq "$APPLEX" ] && [ "$POSY" -eq "$APPLEY" ]; then
      growsnake
      updatescore 10
   fi
}

updatescore() {
   SCORE=$(( $SCORE + $1 ))
   tput cup 2 30
   printf "SCORE: $SCORE"
   if [ $SCORE ==  40 ]
      then
      clear
         echo "CONGRATULATIONS...YOU HAVE CLEARED LEVEL 1."
         sleep 2
      clear

   drawborder2
   drawapple
   move2
   while :
do
   read -s -n 1 key
   case "$key" in
   w)   DIRECTION="u";;
   s)   DIRECTION="d";;
   a)   DIRECTION="l";;
   d)   DIRECTION="r";;
   x)   tput cup $COLS 0
        echo "Quitting..."
        tput cvvis
        stty echo
        tput reset
        printf "Bye Bye!\n"
        trap exit ALRM
        sleep $DELAY
        stty echo
      tput cnorm
        exit 0;;
   esac
done
fi
}
randomchar() {
    [ $# -eq 0 ] && return 1
    n=$(( ($RANDOM % $#) + 1 ))
    eval DIRECTION=\${$n}
}

#function for obstacles
gameover() {
   tput cvvis
   stty echo
   sleep $DELAY
   trap exit ALRM
   tput cup $ROWS 0
   clear
   tput cnorm
   exit
}
 BLACK()
{ 
 echo -en "\033c\033[0;1m\033[37;40m\033[J";
}
SNAKECHAR="Ѳ"                           # Character to use for snake
WALLCHAR="+"                            # Character to use for wall
APPLECHAR="Ȍ"                           # Character to use for apples
#
SNAKESIZE=3                             # Initial Size of array aka snake
DELAY=0.2                               # Timer delay for move function
FIRSTROW=3                              # First row of game area
FIRSTCOL=1                              # First col of game area
LASTCOL=40                              # Last col of game area
LASTROW=20                              # Last row of game area
AREAMAXX=$(( $LASTCOL - 1 ))            # Furthest right play area X
AREAMINX=$(( $FIRSTCOL + 1 ))           # Furthest left play area X
AREAMAXY=$(( $LASTROW - 1 ))            # Lowest play area Y
AREAMINY=$(( $FIRSTROW + 1))            # Highest play area Y
ROWS=`tput lines`                       # Rows in terminal
ORIGINX=$(( $LASTCOL / 2 ))             # Start point X - use bc as it will round
ORIGINY=$(( $LASTROW / 2 ))             # Start point Y - use bc as it will round
POSX=$ORIGINX                           # Set POSX to start pos
POSY=$ORIGINY

ZEROES=`echo |awk '{printf("%0"'"$SNAKESIZE"'"d\n",$1)}' | sed 's/0/0 /g'`
LASTPOSX=( $ZEROES )                    # Pad with zeroes to start with
LASTPOSY=( $ZEROES )                    # Pad with zeroes to start with

SCORE=0                                 # Starting score
setterm -term linux -back <black> -fore <red> -clear
clear 
BLACK

echo "
							Welcome to Nilipede 2.0
			After a long and tiring day, Nilipede has to wander through a maze filled with
			danger and obstacles to collect food for her and her kids. Help her navigate
			by using the following keys:
			W-UP
			A-LEFT
			S-DOWN
			D-RIGHT
					Press Return to continue. Press Q to exit from the game.
"        					

stty -echo
tput civis
read RTN
tput setb 0
tput bold
clear
drawborder
updatescore 0

# Draw the first apple on the screen
# (has collision detection to ensure we don't draw
# over snake)
drawapple
sleep 1
trap move ALRM

# Pick a random direction to start moving in
DIRECTIONS=( u d l r )
randomchar "${DIRECTIONS[@]}"

sleep 1
move
while :
do
   read -s -n 1 key
   case "$key" in
   w)   DIRECTION="u";;
   s)   DIRECTION="d";;
   a)   DIRECTION="l";;
   d)   DIRECTION="r";;
   x)   tput cup $COLS 0
        echo "Quitting..."
        tput cvvis
        stty echo
        tput reset
        printf "Bye Bye!\n"
        trap exit ALRM
        sleep $DELAY
        stty echo
		tput cnorm
        exit 0;;
   esac
done

