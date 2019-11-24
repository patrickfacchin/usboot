RED="\033[1;31m"  
BLUE="\033[1;34m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\33[1;93m"
NORMAL="\033[0;0m"
BOLD="\033[;1m"
banner="
{Y}________________________________________\n
{Y}___/ / / / ___// __ )/ __ \/ __ \/_  __/\n
{Y}__/ / / /\__ \/ ___ / / / / / / / / /   \n
{Y}_/ /_/ /___/ / /_/ / /_/ / /_/ / / /    \n
{Y}_\____//____/_____/\____/\____/ /_/     {G}1.0   {N}\n
{R}_____________________b y ___p a t r i c k____f a c c h i n{N}\n"



function print_banner {
    echo -e $banner |  \
        awk '{ gsub(/{R}/, "'$RED'"); print }'      |\
        awk '{ gsub(/{B}/, "'$BLUE'"); print }'     |\
        awk '{ gsub(/{C}/, "'$CYAN'"); print }'     |\
        awk '{ gsub(/{G}/, "'$GREEN'"); print }'    |\
        awk '{ gsub(/{Y}/, "'$YELLOW'"); print }'   |\
        awk '{ gsub(/{N}/, "'$NORMAL'"); print }'   |\
        awk '{ gsub(/{B}/, "'$BOLD'"); print }'
}


function print_msg {
    echo -e "{R}$1{N}" |  \
        awk '{ gsub(/{R}/, "'$RED'"); print }'      |\
        awk '{ gsub(/{N}/, "'$NORMAL'"); print }'   
}
